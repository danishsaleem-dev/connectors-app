import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'analytics.dart';
import 'auth_result.dart';
import 'auth_state.dart';
import 'chat.dart';
import 'consultant.dart';
import 'consultant_request.dart';
import 'franchising_brand.dart';
import 'location.dart';
import 'message.dart';
import 'oauth_outcome.dart';
import 'profile_data.dart';
import 'property_interest.dart';
import 'upload.dart';
import 'vendor_opportunity.dart';

export 'auth_result.dart' show AuthResult, apiBaseUrl;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static Future<AuthResult> login({
    required String email,
    required String password,
  }) {
    return _postAuth('/api/mobile/auth/login', {
      'email': email,
      'password': password,
    });
  }

  static Future<AuthResult> register({
    required String type,
    required String organizationName,
    required String name,
    required String email,
    required String password,
    String? discipline,
  }) {
    return _postAuth('/api/mobile/auth/register', {
      'type': type,
      'organizationName': organizationName,
      'name': name,
      'email': email,
      'password': password,
      'discipline': ?discipline,
    });
  }

  /// Google/Apple sign-in. Sends the provider's ID token for the server to
  /// verify — see OAuthService for why the app never sends an identity of
  /// its own — and comes back either signed in, or needing the account type
  /// and company name that no provider can tell us.
  static Future<OAuthOutcome> oauthSignIn({
    required String provider,
    required String idToken,
  }) async {
    final json = await _post('/api/mobile/auth/oauth', {
      'provider': provider,
      'idToken': idToken,
    });
    if (json['needsSignup'] == true) {
      return OAuthNeedsSignup(
        pendingToken: json['pendingToken'] as String,
        email: json['email'] as String,
        name: json['name'] as String?,
      );
    }
    return OAuthSignedIn(_authResultFrom(json));
  }

  /// Finishes a first-time Google/Apple signup. `pendingToken` is the
  /// server's own short-lived proof that it verified this identity moments
  /// ago; the email is deliberately never re-sent from here, so it can't be
  /// swapped for someone else's on the way.
  static Future<AuthResult> completeOauthSignup({
    required String pendingToken,
    required String type,
    required String organizationName,
    required String name,
    String? discipline,
  }) async {
    final json = await _post('/api/mobile/auth/oauth/complete', {
      'pendingToken': pendingToken,
      'type': type,
      'organizationName': organizationName,
      'name': name,
      'discipline': ?discipline,
    });
    return _authResultFrom(json);
  }

  static Future<AuthResult> _postAuth(
    String path,
    Map<String, dynamic> body,
  ) async {
    return _authResultFrom(await _post(path, body));
  }

  /// The one shape every "you're signed in now" response has — login,
  /// register and Google/Apple alike, matching the server's own
  /// mobileAuthResponse helper.
  static AuthResult _authResultFrom(Map<String, dynamic> json) {
    return AuthResult(
      name: json['name'] as String,
      isAdmin: json['isAdmin'] as bool,
      sessionToken: json['sessionToken'] as String,
      orgType: json['orgType'] as String?,
      orgName: json['orgName'] as String?,
      handoffToken: json['handoffToken'] as String?,
      onboardingCompletedAt: _parseDate(json['onboardingCompletedAt']),
    );
  }

  static DateTime? _parseDate(Object? value) =>
      value is String ? DateTime.tryParse(value) : null;

  /// Called once on app launch with whatever token SessionStorage has, to
  /// find out whether it's still good before deciding to show Welcome or
  /// Home. Takes the token explicitly rather than reading Auth.session,
  /// since this runs *before* anything is signed in — it's what decides
  /// whether to call Auth.signIn in the first place.
  static Future<AuthResult> checkSession(String storedToken) async {
    final json = await _get('/api/mobile/auth/me', token: storedToken);
    return AuthResult(
      name: json['name'] as String,
      isAdmin: json['isAdmin'] as bool,
      sessionToken: storedToken,
      orgType: json['orgType'] as String?,
      orgName: json['orgName'] as String?,
      onboardingCompletedAt: _parseDate(json['onboardingCompletedAt']),
    );
  }

  /// Mints a fresh handoff token for the currently signed-in session — the
  /// one from login/register is single-use and long expired by the time
  /// someone taps "Open the portal" from a session that was restored on a
  /// later launch rather than just created.
  static Future<String> requestHandoff() async {
    final json = await _post('/api/mobile/auth/handoff', {});
    return json['handoffToken'] as String;
  }

  /// Submits one of the four enquiry wizards. `source` is "brand",
  /// "franchise", "landlord" or "investor" — the API route maps that to the
  /// database's enum values itself.
  static Future<void> submitEnquiry(
    String source,
    Map<String, dynamic> fields,
  ) {
    return _post('/api/mobile/enquiries', {'source': source, ...fields});
  }

  /// The signed-in org's saved profile — organization core fields plus its
  /// type-specific profile row. Whatever was saved from the website's own
  /// onboarding wizard shows up here too; it's the same data.
  static Future<ProfileData> fetchProfile() async {
    final json = await _get('/api/mobile/profile');
    return ProfileData.fromJson(json);
  }

  /// Saves whatever's currently filled in — every call is a partial save,
  /// nothing here requires the whole form to be complete. `organizationName`
  /// /`phone`/`country` are organization-level (not part of `fields`, which
  /// is only the type-specific profile table's own columns — see
  /// profile_fields.dart's _organizationStep doc comment for why those
  /// three are split out). `complete: true` additionally flips
  /// onboardingCompletedAt server-side, same as finishing the website's
  /// onboarding wizard.
  static Future<void> saveProfile({
    String? organizationName,
    String? phone,
    String? country,
    Map<String, Object?> fields = const {},
    bool complete = false,
  }) {
    return _post('/api/mobile/profile', {
      'organizationName': ?organizationName,
      'phone': ?phone,
      'country': ?country,
      if (complete) 'complete': true,
      'fields': fields,
    });
  }

  /// The org's one thread with the Connectors team — see /api/mobile/
  /// messages's doc comment. Oldest first, same order the website renders.
  static Future<List<Message>> fetchMessages() async {
    final json = await _get('/api/mobile/messages');
    final list = (json['messages'] as List).cast<Map<String, dynamic>>();
    return list.map(Message.fromJson).toList();
  }

  static Future<void> sendMessage(String body) {
    return _post('/api/mobile/messages', {'body': body});
  }

  /// Marks every admin-authored message in the thread as read — see
  /// MessagesStore.markRead's doc comment for when this is called.
  static Future<void> markMessagesRead() {
    return _post('/api/mobile/messages/read', {});
  }

  /// Connectors AI's opening state — greeting plus suggested questions.
  static Future<ChatIntro> fetchChatIntro() async {
    final json = await _get('/api/mobile/chat');
    return ChatIntro.fromJson(json);
  }

  /// Asks a free-text question. Pass [entryId] instead when the question
  /// came from a suggested chip — answers it directly rather than
  /// re-running its own label back through the matcher.
  static Future<ChatReply> askChat({String? question, String? entryId}) async {
    final json = await _post('/api/mobile/chat', {
      'question': ?question,
      'entryId': ?entryId,
    });
    return ChatReply.fromJson(json);
  }

  /// Brands actively franchising — the same data the website's public
  /// /for-franchise page already shows anonymous visitors, not new
  /// exposure. Backs the Opportunities tab's "Brands" and "Franchise
  /// Opportunities" categories.
  static Future<List<FranchisingBrand>> fetchFranchisingBrands() async {
    final json = await _get('/api/mobile/opportunities/brands');
    final list = (json['brands'] as List).cast<Map<String, dynamic>>();
    return list.map(FranchisingBrand.fromJson).toList();
  }

  /// Brand-only — the endpoint itself enforces this (403s otherwise), same
  /// access rule the website's /available-locations page already has.
  static Future<List<Location>> fetchLocations() async {
    final json = await _get('/api/mobile/opportunities/locations');
    final list = (json['locations'] as List).cast<Map<String, dynamic>>();
    return list.map(Location.fromJson).toList();
  }

  /// A landlord/developer's own listed properties — 403s for any account
  /// type that doesn't list properties (see the route's doc comment).
  static Future<List<Location>> fetchMyProperties() async {
    final json = await _get('/api/mobile/properties/mine');
    final list = (json['locations'] as List).cast<Map<String, dynamic>>();
    return list.map(Location.fromJson).toList();
  }

  /// The org's saved locations — backs the Saved tab.
  static Future<List<Location>> fetchFavorites() async {
    final json = await _get('/api/mobile/favorites');
    final list = (json['locations'] as List).cast<Map<String, dynamic>>();
    return list.map(Location.fromJson).toList();
  }

  /// Toggles one location's saved state; returns the new state.
  static Future<bool> toggleFavorite(String propertyId) async {
    final json = await _post('/api/mobile/favorites/toggle', {
      'propertyId': propertyId,
    });
    return json['favorited'] as bool;
  }

  /// Admin-released leads from the public consultants page — empty (never
  /// an error) for any org type that isn't a consultant, same reasoning as
  /// fetchInterests.
  static Future<List<ConsultantRequest>> fetchConsultantRequests() async {
    final json = await _get('/api/mobile/consultant-requests');
    final list = (json['requests'] as List).cast<Map<String, dynamic>>();
    return list.map(ConsultantRequest.fromJson).toList();
  }

  /// What admin has flagged as interested in this org's own properties —
  /// empty (never an error) for any org type that doesn't own properties,
  /// since the server just scopes to properties the caller owns.
  static Future<List<PropertyInterest>> fetchInterests() async {
    final json = await _get('/api/mobile/interests');
    final list = (json['interests'] as List).cast<Map<String, dynamic>>();
    return list.map(PropertyInterest.fromJson).toList();
  }

  /// Admin-authored briefs handed to this vendor — empty (never an error)
  /// for any org type that isn't a vendor, same reasoning as
  /// fetchConsultantRequests.
  static Future<List<VendorOpportunity>> fetchVendorOpportunities() async {
    final json = await _get('/api/mobile/vendor-opportunities');
    final list = (json['opportunities'] as List).cast<Map<String, dynamic>>();
    return list.map(VendorOpportunity.fromJson).toList();
  }

  /// The published consultant roster — public, no session required, same
  /// as the website's own /consultants page.
  static Future<List<Consultant>> fetchConsultants() async {
    final json = await _get('/api/mobile/consultants');
    final list = (json['consultants'] as List).cast<Map<String, dynamic>>();
    return list.map(Consultant.fromJson).toList();
  }

  /// Real, org-scoped activity numbers for the Analytics screen — see
  /// OrgAnalytics's doc comment for what is and isn't tracked yet.
  static Future<OrgAnalytics> fetchAnalytics() async {
    final json = await _get('/api/mobile/analytics');
    return OrgAnalytics.fromJson(json['analytics'] as Map<String, dynamic>);
  }

  /// Uploads one file (a profile photo, or a document attachment) and
  /// returns the private Storage path plus a signed URL ready to render
  /// immediately — the same two purposes /api/upload has always issued
  /// signed-upload tokens for on the web, just server-side here (see the
  /// mobile route's doc comment for why that's fine on this side).
  ///
  /// `path` is what every other save call sends back to the server (as
  /// `fields: {'photo': path}`, or inside a repeatable entry, or as an
  /// enquiry attachment) — never the raw bytes twice, and never `url`,
  /// which is a temporary signed link only good for immediately previewing
  /// what was just picked.
  static Future<UploadResult> uploadFile(
    File file, {
    UploadPurpose purpose = UploadPurpose.photo,
  }) async {
    http.StreamedResponse streamed;
    try {
      final request =
          http.MultipartRequest(
              'POST',
              Uri.parse('$apiBaseUrl/api/mobile/upload'),
            )
            ..headers.addAll(_headers()..remove('Content-Type'))
            ..fields['purpose'] = purpose.wireValue
            ..files.add(
              await http.MultipartFile.fromPath(
                'file',
                file.path,
                // Without this, MultipartFile defaults to
                // application/octet-stream, which the server's type allowlist
                // (UPLOAD_ALLOWED_TYPES / UPLOAD_PURPOSES) always rejects —
                // guess it from the extension instead of leaving it unset.
                contentType: MediaType.parse(
                  lookupMimeType(file.path) ?? 'application/octet-stream',
                ),
              ),
            );
      streamed = await request.send().timeout(const Duration(seconds: 60));
    } catch (_) {
      throw ApiException(
        "Couldn't reach Connectors — check your connection and try again.",
      );
    }
    final response = await http.Response.fromStream(streamed);
    final json = _decode(response);
    return UploadResult(
      path: json['path'] as String,
      url: json['url'] as String?,
    );
  }

  /// `token` pins an explicit bearer value (checkSession, called with a
  /// stored token before anything is signed in yet). Omitting it falls back
  /// to whatever's currently signed in — which is exactly nothing for
  /// login/register, so those two naturally send no Authorization header
  /// without needing a special case here.
  static Map<String, String> _headers({String? token}) {
    final resolved = token ?? Auth.session.value?.sessionToken;
    return {
      'Content-Type': 'application/json',
      if (resolved != null) 'Authorization': 'Bearer $resolved',
    };
  }

  static Future<Map<String, dynamic>> _get(String path, {String? token}) async {
    http.Response response;
    try {
      response = await http
          .get(Uri.parse('$apiBaseUrl$path'), headers: _headers(token: token))
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      throw ApiException(
        "Couldn't reach Connectors — check your connection and try again.",
      );
    }
    return _decode(response);
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('$apiBaseUrl$path'),
            headers: _headers(),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      throw ApiException(
        "Couldn't reach Connectors — check your connection and try again.",
      );
    }
    return _decode(response);
  }

  static Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException('Something went wrong. Please try again.');
    }

    if (json['ok'] != true) {
      throw ApiException(
        (json['error'] as String?) ?? 'Something went wrong. Please try again.',
      );
    }
    return json;
  }
}

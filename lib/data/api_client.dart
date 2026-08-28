import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_result.dart';
import 'auth_state.dart';
import 'franchising_brand.dart';
import 'location.dart';
import 'message.dart';
import 'profile_data.dart';

export 'auth_result.dart' show AuthResult, apiBaseUrl;

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();

  static Future<AuthResult> login({required String email, required String password}) {
    return _postAuth('/api/mobile/auth/login', {'email': email, 'password': password});
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

  static Future<AuthResult> _postAuth(String path, Map<String, dynamic> body) async {
    final json = await _post(path, body);
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
  static Future<void> submitEnquiry(String source, Map<String, dynamic> fields) {
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
      throw ApiException("Couldn't reach Connectors — check your connection and try again.");
    }
    return _decode(response);
  }

  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    http.Response response;
    try {
      response = await http
          .post(Uri.parse('$apiBaseUrl$path'), headers: _headers(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      throw ApiException("Couldn't reach Connectors — check your connection and try again.");
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
      throw ApiException((json['error'] as String?) ?? 'Something went wrong. Please try again.');
    }
    return json;
  }
}

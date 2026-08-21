import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_result.dart';
import 'auth_state.dart';

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
    );
  }

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

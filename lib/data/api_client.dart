import 'dart:convert';
import 'package:http/http.dart' as http;

/// Base URL for every backend call — the live Next.js site's own API
/// routes under src/app/api/mobile/*, not a separate backend. One place to
/// change if this ever needs to point at a staging deploy.
const String apiBaseUrl = 'https://connectors.group';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class AuthResult {
  final String name;
  final bool isAdmin;
  final String handoffToken;

  AuthResult({required this.name, required this.isAdmin, required this.handoffToken});

  /// The one-time link that actually signs the user into a real browser —
  /// see the website's /portal/handoff route. Opened via url_launcher in an
  /// external browser, not an in-app webview, so the resulting session
  /// persists like any other browser tab.
  String get handoffUrl => '$apiBaseUrl/portal/handoff?token=$handoffToken';
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
      handoffToken: json['handoffToken'] as String,
    );
  }

  /// Submits one of the four enquiry wizards. `source` is "brand",
  /// "franchise", "landlord" or "investor" — the API route maps that to the
  /// database's enum values itself.
  static Future<void> submitEnquiry(String source, Map<String, dynamic> fields) {
    return _post('/api/mobile/enquiries', {'source': source, ...fields});
  }

  static Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('$apiBaseUrl$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
    } catch (_) {
      throw ApiException("Couldn't reach Connectors — check your connection and try again.");
    }

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

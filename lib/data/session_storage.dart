import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The one thing persisted to disk across app restarts — everything else
/// about who's signed in (name, org type) is re-read fresh from the server
/// on launch via ApiClient.checkSession, rather than cached, so a token that
/// outlives its account's real state can never show stale info.
class SessionStorage {
  SessionStorage._();

  static const _key = 'session_token';
  static const _onboardingKey = 'onboarding_seen';
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) => _storage.write(key: _key, value: token);

  static Future<String?> readToken() => _storage.read(key: _key);

  static Future<void> clearToken() => _storage.delete(key: _key);

  /// Whether the swipeable onboarding carousel has already been shown —
  /// it's a first-launch introduction, not something to repeat every time
  /// someone signs out.
  static Future<bool> hasSeenOnboarding() async {
    final value = await _storage.read(key: _onboardingKey);
    return value == 'true';
  }

  static Future<void> markOnboardingSeen() => _storage.write(key: _onboardingKey, value: 'true');
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// The one thing persisted to disk across app restarts — everything else
/// about who's signed in (name, org type) is re-read fresh from the server
/// on launch via ApiClient.checkSession, rather than cached, so a token that
/// outlives its account's real state can never show stale info.
class SessionStorage {
  SessionStorage._();

  static const _key = 'session_token';
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) => _storage.write(key: _key, value: token);

  static Future<String?> readToken() => _storage.read(key: _key);

  static Future<void> clearToken() => _storage.delete(key: _key);
}

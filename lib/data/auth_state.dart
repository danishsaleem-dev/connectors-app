import 'package:flutter/foundation.dart';
import 'auth_result.dart';
import 'session_storage.dart';

/// Who is signed in, for the app's in-memory lifetime — plus the on-disk
/// token that lets a later launch restore it (see main.dart's boot check,
/// which calls ApiClient.checkSession with whatever SessionStorage has
/// before deciding whether to show Welcome or go straight to Home).
class Auth {
  Auth._();

  static final ValueNotifier<AuthResult?> session = ValueNotifier<AuthResult?>(null);

  static bool get isSignedIn => session.value != null;

  /// Fire-and-forget on the storage write — a failure to persist (a rare
  /// platform storage issue) shouldn't block getting the user into the app
  /// they just signed into; worst case, the next launch just doesn't
  /// restore the session.
  static void signIn(AuthResult result) {
    session.value = result;
    SessionStorage.saveToken(result.sessionToken);
  }

  static void signOut() {
    session.value = null;
    SessionStorage.clearToken();
  }
}

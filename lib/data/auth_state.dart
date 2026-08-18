import 'package:flutter/foundation.dart';
import 'api_client.dart';

/// Who is signed in, for the lifetime of this app run.
///
/// Deliberately not persisted to disk. The mobile API's login/register
/// responses carry a name, an admin flag and a *one-time* handoff token —
/// there is no durable session token to store, so writing this to disk
/// would only fake a signed-in state the app couldn't actually act on.
/// Persisting a real session needs the website to issue a refreshable
/// token first.
class Auth {
  Auth._();

  static final ValueNotifier<AuthResult?> session = ValueNotifier<AuthResult?>(null);

  static bool get isSignedIn => session.value != null;

  static void signIn(AuthResult result) => session.value = result;

  static void signOut() => session.value = null;
}

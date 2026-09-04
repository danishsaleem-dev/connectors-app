import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Runs the native Google/Apple sign-in sheets and hands back the provider's
/// ID token — nothing more.
///
/// Deliberately the *only* thing this returns. The app never decides who
/// someone is: the token goes to /api/mobile/auth/oauth, which verifies it
/// against Google's or Apple's own signing keys before trusting a single
/// claim inside it. Anything this file read out of the token locally (an
/// email, a name) and posted separately would be attacker-controlled, since
/// an APK can be decompiled and its requests replayed.
///
/// Returns null when the person simply backed out of the sheet, which is a
/// normal outcome and not an error — the caller shows nothing.
class OAuthService {
  OAuthService._();

  /// Client IDs are compiled in via --dart-define rather than committed:
  /// they're not secrets (they ship inside the app either way), but keeping
  /// them out of the repo means a fork or a screenshot of the source doesn't
  /// hand someone a working client, and staging/production can differ
  /// without a code change. See README.md's "Google & Apple sign-in" notes.
  ///
  /// `serverClientId` is the *Web* OAuth client ID, and it matters more than
  /// it looks: on Android the ID token is minted with that as its audience,
  /// so it must match one of the server's GOOGLE_OAUTH_CLIENT_IDS or
  /// verification fails.
  static const _googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
  static const _googleIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

  static bool get googleConfigured => _googleServerClientId.isNotEmpty;

  /// Apple's sheet is only offered where it actually works natively. On
  /// Android it would need a web redirect flow through a Services ID, which
  /// isn't set up — and Apple only *requires* the button on its own
  /// platforms anyway (App Store guideline 4.8).
  static bool get appleAvailable => !kIsWeb && (Platform.isIOS || Platform.isMacOS);

  static bool _googleInitialized = false;

  static Future<String?> googleIdToken() async {
    if (!_googleInitialized) {
      await GoogleSignIn.instance.initialize(
        clientId: _googleIosClientId.isEmpty ? null : _googleIosClientId,
        serverClientId: _googleServerClientId.isEmpty ? null : _googleServerClientId,
      );
      _googleInitialized = true;
    }

    try {
      final account = await GoogleSignIn.instance.authenticate();
      return account.authentication.idToken;
    } on GoogleSignInException catch (err) {
      if (err.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
  }

  static Future<String?> appleIdToken() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        // Apple sends the name only on the very first authorization, and
        // never again — asking for it here is what makes it available to
        // pre-fill the signup step. After that it's email-only, which is
        // why the server persists the name the first time it sees it.
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      return credential.identityToken;
    } on SignInWithAppleAuthorizationException catch (err) {
      if (err.code == AuthorizationErrorCode.canceled) return null;
      rethrow;
    }
  }
}

import 'package:flutter/material.dart';
import '../screens/oauth_signup_screen.dart';
import 'api_client.dart';
import 'auth_state.dart';
import 'oauth_outcome.dart';
import 'oauth_service.dart';

/// The whole Google/Apple sign-in journey, in one place because three
/// screens offer it (Login, Signup and Welcome) and they should behave
/// identically — a difference between them would only ever be a bug.
///
/// Sequence: native sheet → provider ID token → our server verifies it →
/// either signed in, or on to the account-type step for a first-timer.
///
/// [setBusy] lets the caller show its own spinner without this needing to
/// know anything about the screen it was called from.
Future<void> startOAuthSignIn(
  BuildContext context, {
  required String provider,
  required void Function(bool busy) setBusy,
}) async {
  final label = provider == 'google' ? 'Google' : 'Apple';
  final messenger = ScaffoldMessenger.of(context);
  final navigator = Navigator.of(context);

  setBusy(true);
  try {
    final idToken = provider == 'google'
        ? await OAuthService.googleIdToken()
        : await OAuthService.appleIdToken();

    // Backing out of the provider's sheet is a normal thing to do, not an
    // error — say nothing and leave the screen exactly as it was.
    if (idToken == null) {
      setBusy(false);
      return;
    }

    final outcome = await ApiClient.oauthSignIn(provider: provider, idToken: idToken);
    if (!context.mounted) return;

    switch (outcome) {
      case OAuthSignedIn(:final result):
        Auth.signIn(result);
        // AppRoot is already listening to Auth.session and has rebuilt the
        // signed-in shell underneath, so this just clears the auth screens.
        navigator.popUntil((route) => route.isFirst);
      case OAuthNeedsSignup():
        setBusy(false);
        navigator.push(
          MaterialPageRoute(
            builder: (_) => OAuthSignupScreen(pending: outcome, providerLabel: label),
          ),
        );
    }
  } catch (err) {
    setBusy(false);
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          err is ApiException ? err.message : "Couldn't sign in with $label. Please try again.",
        ),
      ),
    );
  }
}

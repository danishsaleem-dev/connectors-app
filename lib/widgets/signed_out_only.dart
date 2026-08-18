import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../data/auth_state.dart';

/// Hides its child once someone is signed in — wraps the "create an
/// account" / "become a vendor" style calls to action, which are noise to
/// a user who already has an account.
class SignedOutOnly extends StatelessWidget {
  final Widget child;

  const SignedOutOnly({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthResult?>(
      valueListenable: Auth.session,
      builder: (context, session, _) =>
          session == null ? child : const SizedBox.shrink(),
    );
  }
}

import 'auth_result.dart';

/// What a Google/Apple sign-in can come back as.
///
/// Two outcomes rather than one because a provider can tell us who someone
/// is, but not what kind of account they want: an organization needs a type
/// (brand, landlord, investor…) and a company name, and neither is anywhere
/// in a Google or Apple token. So a first-time sign-in creates nothing and
/// returns [OAuthNeedsSignup] instead, and the app collects the rest.
sealed class OAuthOutcome {
  const OAuthOutcome();
}

/// The verified email already had an account — nothing else to ask.
class OAuthSignedIn extends OAuthOutcome {
  final AuthResult result;

  const OAuthSignedIn(this.result);
}

/// First time here. [pendingToken] is the server's signed, short-lived proof
/// that it verified this identity — it's what the completion call sends
/// instead of the email, so the account can only be created for the person
/// who actually signed in.
class OAuthNeedsSignup extends OAuthOutcome {
  final String pendingToken;
  final String email;

  /// Apple sends this only on the very first authorization and never again,
  /// so it's a pre-fill, not a guarantee — the signup step lets it be
  /// edited, and requires it when the provider sent nothing.
  final String? name;

  const OAuthNeedsSignup({
    required this.pendingToken,
    required this.email,
    required this.name,
  });
}

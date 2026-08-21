const String apiBaseUrl = 'https://connectors.group';

/// Its own file, not defined inside api_client.dart or auth_state.dart —
/// both of those need this type, and api_client.dart also needs to read the
/// current session (to attach it to outgoing requests), so this type can't
/// live in either of theirs without the two files importing each other.
class AuthResult {
  final String name;
  final bool isAdmin;
  final String sessionToken;

  /// One of the seven org types (brand/franchisee/landlord/developer/
  /// investor/vendor/consultant) — null for an admin account, which has no
  /// organization. Picks which tab/home content the app shows.
  final String? orgType;
  final String? orgName;

  /// Only ever set right after a fresh login/register response — a session
  /// restored from storage on a later launch has no still-valid one (they
  /// expire in 120 seconds by design). Request a fresh one via
  /// ApiClient.requestHandoff() when actually opening the portal instead of
  /// holding onto this.
  final String? handoffToken;

  const AuthResult({
    required this.name,
    required this.isAdmin,
    required this.sessionToken,
    this.orgType,
    this.orgName,
    this.handoffToken,
  });

  String? get handoffUrl =>
      handoffToken == null ? null : '$apiBaseUrl/portal/handoff?token=$handoffToken';

  AuthResult copyWith({String? handoffToken}) => AuthResult(
        name: name,
        isAdmin: isAdmin,
        sessionToken: sessionToken,
        orgType: orgType,
        orgName: orgName,
        handoffToken: handoffToken ?? this.handoffToken,
      );
}

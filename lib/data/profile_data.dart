/// The response shape of GET /api/mobile/profile — organization core
/// fields plus whatever's saved in that org type's own profile table.
class ProfileData {
  final String? orgType;
  final String? organizationName;
  final String? phone;
  final String? country;
  final DateTime? onboardingCompletedAt;

  /// Raw per-type profile row, straight off the JSON response — key names
  /// match ProfileField.key exactly (see profile_fields.dart), so seeding
  /// ProfileDraft is a matter of running each value through
  /// coerceProfileValue, not a field-by-field mapping here.
  final Map<String, dynamic> profile;

  const ProfileData({
    this.orgType,
    this.organizationName,
    this.phone,
    this.country,
    this.onboardingCompletedAt,
    required this.profile,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    final org = json['organization'] as Map<String, dynamic>? ?? const {};
    final completedRaw = org['onboardingCompletedAt'] as String?;
    return ProfileData(
      orgType: json['orgType'] as String?,
      organizationName: org['name'] as String?,
      phone: org['phone'] as String?,
      country: org['country'] as String?,
      onboardingCompletedAt: completedRaw == null ? null : DateTime.tryParse(completedRaw),
      profile: (json['profile'] as Map<String, dynamic>?) ?? const {},
    );
  }
}

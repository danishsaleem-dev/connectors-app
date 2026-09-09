/// One row from the published consultant roster — GET /api/mobile/
/// consultants, the same isPublished-gated rows the website's own
/// /consultants page shows, so this is public data, not something scoped
/// to the signed-in org.
class Consultant {
  final String id;
  final String slug;
  final String name;
  final String? title;
  final String? photoUrl;
  final List<String> industries;
  final List<String> expertise;
  final int? yearsExperience;

  const Consultant({
    required this.id,
    required this.slug,
    required this.name,
    required this.title,
    required this.photoUrl,
    required this.industries,
    required this.expertise,
    required this.yearsExperience,
  });

  factory Consultant.fromJson(Map<String, dynamic> json) => Consultant(
    id: json['id'] as String,
    slug: json['slug'] as String,
    name: json['name'] as String,
    title: json['title'] as String?,
    photoUrl: json['photoUrl'] as String?,
    industries: (json['industries'] as List).cast<String>(),
    expertise: (json['expertise'] as List).cast<String>(),
    yearsExperience: json['yearsExperience'] as int?,
  );
}

/// One admin-authored work brief handed to this vendor org — GET
/// /api/mobile/vendor-opportunities. Free-form (see the server's
/// vendorOpportunities schema comment): a title, an optional longer
/// description, and an optional attachment link — not tied to any
/// property or brand request a vendor could otherwise browse.
class VendorOpportunity {
  final String id;
  final String title;
  final String? description;
  final String? attachmentUrl;
  final DateTime createdAt;

  const VendorOpportunity({
    required this.id,
    required this.title,
    required this.description,
    required this.attachmentUrl,
    required this.createdAt,
  });

  factory VendorOpportunity.fromJson(Map<String, dynamic> json) =>
      VendorOpportunity(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        attachmentUrl: json['attachmentUrl'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}

/// One admin-released lead from the public consultants page's inquiry
/// form — GET /api/mobile/consultant-requests. Unlike PropertyInterest,
/// this genuinely carries the inquirer's own contact details: they
/// submitted this specifically to reach this consultant, the same as
/// emailing them directly would (see the server's consultantInquiryStatus
/// Enum doc comment for the full reasoning).
class ConsultantRequest {
  final String id;
  final String name;
  final String email;
  final String message;
  final DateTime createdAt;

  const ConsultantRequest({
    required this.id,
    required this.name,
    required this.email,
    required this.message,
    required this.createdAt,
  });

  factory ConsultantRequest.fromJson(Map<String, dynamic> json) => ConsultantRequest(
    id: json['id'] as String,
    name: json['name'] as String,
    email: json['email'] as String,
    message: json['message'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );
}

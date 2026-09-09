/// One admin-flagged "org X is interested in your property Y" row — GET
/// /api/mobile/interests. Deliberately carries no contact details for the
/// interested org (see the server's propertyInterests schema comment) —
/// following up always goes through Connectors, via Messages, not a
/// direct channel this screen would otherwise imply.
class PropertyInterest {
  final String id;
  final String? note;
  final DateTime createdAt;
  final String propertyId;
  final String propertyTitle;
  final String propertyCity;
  final String organizationName;
  final String organizationType;

  const PropertyInterest({
    required this.id,
    required this.note,
    required this.createdAt,
    required this.propertyId,
    required this.propertyTitle,
    required this.propertyCity,
    required this.organizationName,
    required this.organizationType,
  });

  factory PropertyInterest.fromJson(Map<String, dynamic> json) => PropertyInterest(
    id: json['id'] as String,
    note: json['note'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    propertyId: json['propertyId'] as String,
    propertyTitle: json['propertyTitle'] as String,
    propertyCity: json['propertyCity'] as String,
    organizationName: json['organizationName'] as String,
    organizationType: json['organizationType'] as String,
  );
}

const _orgTypeLabels = {'brand': 'Brand', 'franchisee': 'Franchisee', 'investor': 'Investor'};

String orgTypeLabel(String type) => _orgTypeLabels[type] ?? type;

/// One franchise opportunity an admin has matched to this franchisee org —
/// GET /api/mobile/franchise-opportunities. Real opportunity fields (city,
/// territory, investment range), not a re-typed summary — the franchisee
/// never browses franchise_opportunities directly (see the server's
/// franchiseOpportunityInterests schema comment), this matched subset is
/// the entire feed.
class FranchiseOpportunity {
  final String id;
  final String title;
  final String brandName;
  final String city;
  final String? country;
  final String? territory;
  final int? investmentMin;
  final int? investmentMax;
  final String currency;
  final int? spaceRequiredSqft;
  final String status;
  final String? description;
  final String? note;
  final DateTime createdAt;

  const FranchiseOpportunity({
    required this.id,
    required this.title,
    required this.brandName,
    required this.city,
    required this.country,
    required this.territory,
    required this.investmentMin,
    required this.investmentMax,
    required this.currency,
    required this.spaceRequiredSqft,
    required this.status,
    required this.description,
    required this.note,
    required this.createdAt,
  });

  factory FranchiseOpportunity.fromJson(Map<String, dynamic> json) =>
      FranchiseOpportunity(
        id: json['id'] as String,
        title: json['title'] as String,
        brandName: json['brandName'] as String,
        city: json['city'] as String,
        country: json['country'] as String?,
        territory: json['territory'] as String?,
        investmentMin: json['investmentMin'] as int?,
        investmentMax: json['investmentMax'] as int?,
        currency: json['currency'] as String,
        spaceRequiredSqft: json['spaceRequiredSqft'] as int?,
        status: json['status'] as String,
        description: json['description'] as String?,
        note: json['note'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  /// e.g. "PKR 500,000 – 1,000,000" — a single-sided amount when only one
  /// bound is set, null when neither is. Same comma-grouping as Location's
  /// rentDisplay.
  String? get investmentDisplay {
    if (investmentMin == null && investmentMax == null) return null;
    String format(int n) => n.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => ',',
    );
    if (investmentMin != null && investmentMax != null) {
      return '$currency ${format(investmentMin!)} – ${format(investmentMax!)}';
    }
    return '$currency ${format((investmentMin ?? investmentMax)!)}';
  }
}

const franchiseStatusLabels = {
  'available': 'Available',
  'reserved': 'Reserved',
  'awarded': 'Awarded',
  'withdrawn': 'Withdrawn',
};

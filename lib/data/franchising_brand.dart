/// One row from GET /api/mobile/opportunities/brands — brands actively
/// franchising. Same query and the same fields the website's own public
/// /for-franchise page already shows anonymous visitors (see that route's
/// doc comment) — nothing here is new exposure.
class FranchisingBrand {
  final String organizationId;
  final String name;
  final String? country;
  final String? logoUrl;
  final String? industry;
  final String? description;
  final int? outletCount;
  final List<String> countriesPresent;
  final int? franchiseInvestmentMin;
  final int? franchiseInvestmentMax;
  final int? franchiseFee;
  final String currency;

  const FranchisingBrand({
    required this.organizationId,
    required this.name,
    required this.country,
    required this.logoUrl,
    required this.industry,
    required this.description,
    required this.outletCount,
    required this.countriesPresent,
    required this.franchiseInvestmentMin,
    required this.franchiseInvestmentMax,
    required this.franchiseFee,
    required this.currency,
  });

  factory FranchisingBrand.fromJson(Map<String, dynamic> json) {
    return FranchisingBrand(
      organizationId: json['organizationId'] as String,
      name: json['name'] as String,
      country: json['country'] as String?,
      logoUrl: json['logoUrl'] as String?,
      industry: json['industry'] as String?,
      description: json['description'] as String?,
      outletCount: json['outletCount'] as int?,
      countriesPresent: (json['countriesPresent'] as List?)?.cast<String>() ?? const [],
      franchiseInvestmentMin: json['franchiseInvestmentMin'] as int?,
      franchiseInvestmentMax: json['franchiseInvestmentMax'] as int?,
      franchiseFee: json['franchiseFee'] as int?,
      currency: json['currency'] as String? ?? 'GBP',
    );
  }

  String? get investmentDisplay {
    if (franchiseInvestmentMin == null && franchiseInvestmentMax == null) return null;
    final min = franchiseInvestmentMin != null ? _money(franchiseInvestmentMin!) : null;
    final max = franchiseInvestmentMax != null ? _money(franchiseInvestmentMax!) : null;
    if (min != null && max != null) return '$min – $max';
    return min ?? max;
  }

  String? get feeDisplay => franchiseFee == null ? null : '${_money(franchiseFee!)} fee';

  String _money(int amount) {
    final symbol = switch (currency) {
      'USD' => '\$',
      'GBP' => '£',
      'EUR' => '€',
      _ => '$currency ',
    };
    final thousands = amount ~/ 1000;
    return thousands > 0 ? '$symbol${thousands}K' : '$symbol$amount';
  }
}

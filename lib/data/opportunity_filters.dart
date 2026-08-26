import 'opportunity.dart';

/// Same shape as location_filters.dart's LocationFilters — query plus a
/// handful of exact-match/bucket fields, applied in-memory over the
/// category's mock list.
class OpportunityFilters {
  final String query;
  final String? country;
  final String? industry;
  final String? brandType;
  final String? investmentBucket;
  final String? feeBucket;
  final String? sizeBucket;

  const OpportunityFilters({
    this.query = '',
    this.country,
    this.industry,
    this.brandType,
    this.investmentBucket,
    this.feeBucket,
    this.sizeBucket,
  });

  bool get isActive =>
      query.isNotEmpty ||
      country != null ||
      industry != null ||
      brandType != null ||
      investmentBucket != null ||
      feeBucket != null ||
      sizeBucket != null;

  OpportunityFilters copyWith({
    String? query,
    String? Function()? country,
    String? Function()? industry,
    String? Function()? brandType,
    String? Function()? investmentBucket,
    String? Function()? feeBucket,
    String? Function()? sizeBucket,
  }) {
    return OpportunityFilters(
      query: query ?? this.query,
      country: country != null ? country() : this.country,
      industry: industry != null ? industry() : this.industry,
      brandType: brandType != null ? brandType() : this.brandType,
      investmentBucket: investmentBucket != null ? investmentBucket() : this.investmentBucket,
      feeBucket: feeBucket != null ? feeBucket() : this.feeBucket,
      sizeBucket: sizeBucket != null ? sizeBucket() : this.sizeBucket,
    );
  }

  bool matches(OpportunityListing item) {
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      final haystack = '${item.title} ${item.city} ${item.country}'.toLowerCase();
      if (!haystack.contains(q)) return false;
    }
    if (country != null && item.country != country) return false;
    if (industry != null && item.industry != industry) return false;
    if (brandType != null && item.brandType != brandType) return false;
    if (investmentBucket != null) {
      final bucket = _findBucket(investmentBuckets, investmentBucket!);
      if (bucket != null && !bucket.test(item.investmentMax ?? item.investmentMin)) return false;
    }
    if (feeBucket != null) {
      final bucket = _findBucket(feeBuckets, feeBucket!);
      if (bucket != null && !bucket.test(item.franchiseFee)) return false;
    }
    if (sizeBucket != null) {
      final bucket = _findBucket(sizeBuckets, sizeBucket!);
      if (bucket != null && !bucket.test(item.sizeSqft)) return false;
    }
    return true;
  }
}

RangeBucket? _findBucket(List<RangeBucket> buckets, String value) {
  for (final b in buckets) {
    if (b.value == value) return b;
  }
  return null;
}

import 'location.dart';

/// Ported from the website's src/lib/location-filters.ts — same size
/// buckets, same matching rules, applied in-memory over the already-
/// fetched list rather than as separate server queries, exactly like the
/// website's own /available-locations page does it.
class SizeBucket {
  final String value;
  final String label;
  final bool Function(int? sqft) test;

  const SizeBucket({required this.value, required this.label, required this.test});
}

final sizeBuckets = [
  SizeBucket(value: 'under-2000', label: 'Under 2,000 sq ft', test: (s) => s != null && s < 2000),
  SizeBucket(
    value: '2000-5000',
    label: '2,000 – 5,000 sq ft',
    test: (s) => s != null && s >= 2000 && s < 5000,
  ),
  SizeBucket(
    value: '5000-10000',
    label: '5,000 – 10,000 sq ft',
    test: (s) => s != null && s >= 5000 && s < 10000,
  ),
  SizeBucket(value: '10000-plus', label: '10,000+ sq ft', test: (s) => s != null && s >= 10000),
];

class LocationFilters {
  final String query;
  final String? status;
  final String? propertyType;
  final String? city;
  final String? sizeBucket;

  const LocationFilters({
    this.query = '',
    this.status,
    this.propertyType,
    this.city,
    this.sizeBucket,
  });

  bool get isActive =>
      query.isNotEmpty || status != null || propertyType != null || city != null || sizeBucket != null;

  LocationFilters copyWith({
    String? query,
    String? Function()? status,
    String? Function()? propertyType,
    String? Function()? city,
    String? Function()? sizeBucket,
  }) {
    return LocationFilters(
      query: query ?? this.query,
      status: status != null ? status() : this.status,
      propertyType: propertyType != null ? propertyType() : this.propertyType,
      city: city != null ? city() : this.city,
      sizeBucket: sizeBucket != null ? sizeBucket() : this.sizeBucket,
    );
  }

  bool matches(Location location) {
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      final haystack = '${location.title} ${location.city} ${location.area ?? ''}'.toLowerCase();
      if (!haystack.contains(q)) return false;
    }
    if (status != null && location.status != status) return false;
    if (propertyType != null && location.propertyType != propertyType) return false;
    if (city != null && location.city != city) return false;
    if (sizeBucket != null) {
      final bucket = sizeBuckets.where((b) => b.value == sizeBucket).firstOrNull;
      if (bucket != null && !bucket.test(location.sizeSqft)) return false;
    }
    return true;
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

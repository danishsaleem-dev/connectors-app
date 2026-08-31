/// One listing from GET /api/mobile/opportunities/locations (or the
/// landlord/developer-scoped /api/mobile/properties/mine — same shape) —
/// same shape the website's own /available-locations page renders,
/// brand-only access enforced server-side (see that endpoint's doc
/// comment). Deliberately carries nothing that identifies who owns the
/// listing — no party in the portal contacts another directly, only
/// through Connectors.
class Location {
  final String id;
  final String title;
  final String propertyType;
  final String city;
  final String? country;
  final String? area;
  final int? sizeSqft;
  final String? dimensions;
  final String? floorLevel;
  final bool parkingAvailable;
  final int? rentAmount;
  final String? rentPeriod;
  final String currency;
  final String? availableFrom;
  final String status;
  final bool featured;
  final String? description;
  final bool isFavorited;
  final List<String> photoUrls;

  const Location({
    required this.id,
    required this.title,
    required this.propertyType,
    required this.city,
    required this.country,
    required this.area,
    required this.sizeSqft,
    required this.dimensions,
    required this.floorLevel,
    required this.parkingAvailable,
    required this.rentAmount,
    required this.rentPeriod,
    required this.currency,
    required this.availableFrom,
    required this.status,
    required this.featured,
    required this.description,
    this.isFavorited = false,
    required this.photoUrls,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as String,
      title: json['title'] as String,
      propertyType: json['propertyType'] as String,
      city: json['city'] as String,
      country: json['country'] as String?,
      area: json['area'] as String?,
      sizeSqft: json['sizeSqft'] as int?,
      dimensions: json['dimensions'] as String?,
      floorLevel: json['floorLevel'] as String?,
      parkingAvailable: json['parkingAvailable'] as bool? ?? false,
      rentAmount: json['rentAmount'] as int?,
      rentPeriod: json['rentPeriod'] as String?,
      currency: json['currency'] as String? ?? 'GBP',
      availableFrom: json['availableFrom'] as String?,
      status: json['status'] as String,
      featured: json['featured'] as bool? ?? false,
      description: json['description'] as String?,
      isFavorited: json['isFavorited'] as bool? ?? false,
      photoUrls: (json['photoUrls'] as List?)?.cast<String>() ?? const [],
    );
  }

  Location copyWith({bool? isFavorited}) => Location(
        id: id,
        title: title,
        propertyType: propertyType,
        city: city,
        country: country,
        area: area,
        sizeSqft: sizeSqft,
        dimensions: dimensions,
        floorLevel: floorLevel,
        parkingAvailable: parkingAvailable,
        rentAmount: rentAmount,
        rentPeriod: rentPeriod,
        currency: currency,
        availableFrom: availableFrom,
        status: status,
        featured: featured,
        description: description,
        isFavorited: isFavorited ?? this.isFavorited,
        photoUrls: photoUrls,
      );

  /// e.g. "PKR 500,000 / month" — null when no rent is set (some listings
  /// are "POA", price on application, same as the website shows it).
  String? get rentDisplay {
    if (rentAmount == null) return null;
    final amount = rentAmount!.toString().replaceAllMapped(
          RegExp(r'\B(?=(\d{3})+(?!\d))'),
          (m) => ',',
        );
    return '$currency $amount / ${rentPeriod ?? 'month'}';
  }
}

/// Same labels as the website's PROPERTY_TYPE_LABEL (src/lib/portal/domain.ts)
/// — kept in sync by hand.
const propertyTypeLabels = {
  'retail_shop': 'Retail shop',
  'commercial_unit': 'Commercial unit',
  'food_court': 'Food court',
  'standalone_building': 'Standalone building',
  'kiosk': 'Kiosk',
  'showroom': 'Showroom',
  'office': 'Office',
  'mixed_use': 'Mixed use',
};

/// Which propertyType values back the Opportunities tab's "Retail Spaces"
/// and "Commercial Projects" category cards — a grouping of the 8 real
/// property types into the two marketing-facing buckets those cards
/// promise, not a distinction the backend itself makes. Worth confirming
/// with the business if any of these feel misplaced.
const retailPropertyTypes = {'retail_shop', 'kiosk', 'showroom', 'food_court'};
const commercialPropertyTypes = {'commercial_unit', 'standalone_building', 'office', 'mixed_use'};

/// Same labels as the website's PROPERTY_STATUS_LABEL.
const propertyStatusLabels = {
  'available': 'Available',
  'under_offer': 'Under offer',
  'leased': 'Leased',
  'withdrawn': 'Withdrawn',
};

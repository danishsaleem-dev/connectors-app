import 'package:flutter/material.dart';
import '../theme/colors.dart';

const _coverPalette = [
  [AppColors.violet700, AppColors.violet600],
  [AppColors.violet600, AppColors.violet400],
  [AppColors.ink, AppColors.violet900],
  [AppColors.violet900, AppColors.violet700],
];

/// One listing shown under the Opportunities tab for "Investors" — the one
/// category still mock. Locations/Retail/Commercial (live `properties`
/// rows, see location.dart) and Brands/Franchise Opportunities (live
/// franchising organizations, see BrandsScreen) both moved to real data.
///
/// Investors staying mock isn't a technical gap — it's that showing real
/// investor org data would mean exposing one account type's data to
/// another with no existing access rule for it, unlike Brands/Franchise,
/// which already have public precedent via the website's own
/// /for-franchise page (see ApiClient.fetchFranchisingBrands's doc
/// comment). Kept mock until that's actually decided.
class OpportunityListing {
  final String id;
  final String category;
  final String title;
  final String city;
  final String country;
  final String? industry;
  final String? brandType;
  final int? investmentMin;
  final int? investmentMax;
  final int? franchiseFee;
  final int? sizeSqft;
  final String description;
  final bool featured;

  const OpportunityListing({
    required this.id,
    required this.category,
    required this.title,
    required this.city,
    required this.country,
    required this.description,
    this.industry,
    this.brandType,
    this.investmentMin,
    this.investmentMax,
    this.franchiseFee,
    this.sizeSqft,
    this.featured = false,
  });

  String? get investmentDisplay {
    if (investmentMin == null && investmentMax == null) return null;
    final min = investmentMin != null ? _money(investmentMin!) : null;
    final max = investmentMax != null ? _money(investmentMax!) : null;
    if (min != null && max != null) return '$min – $max';
    return min ?? max;
  }

  String? get feeDisplay =>
      franchiseFee == null ? null : '${_money(franchiseFee!)} fee';

  /// No real photos behind this mock data, so each card/detail page gets a
  /// deterministic gradient cover instead of plain text running straight
  /// into the page background — stable per listing (keyed off `id`, not
  /// random) so it doesn't flicker between a different pair on rebuild.
  /// Stays inside the brand's existing violet/ink palette.
  List<Color> get coverColors =>
      _coverPalette[id.hashCode.abs() % _coverPalette.length];

  String? get sizeDisplay => sizeSqft == null ? null : '$sizeSqft sq ft';
}

String _money(int amount) {
  final thousands = amount ~/ 1000;
  return thousands > 0 ? '\$${thousands}K' : '\$$amount';
}

/// A named bucket over a numeric field — same shape as the website/app's
/// existing size-bucket filters (see location_filters.dart), reused here
/// for investment range and franchise fee.
class RangeBucket {
  final String value;
  final String label;
  final bool Function(int? amount) test;

  const RangeBucket({
    required this.value,
    required this.label,
    required this.test,
  });
}

// Not const: each bucket's `test` closure is built by calling a helper
// function (_under/_between/_atLeast), and a function call can't be
// evaluated in a const context even though the resulting closure itself
// is a plain, stable function value.
final investmentBuckets = [
  RangeBucket(value: 'under-50k', label: 'Under \$50K', test: _under(50000)),
  RangeBucket(
    value: '50k-200k',
    label: '\$50K – \$200K',
    test: _between(50000, 200000),
  ),
  RangeBucket(
    value: '200k-500k',
    label: '\$200K – \$500K',
    test: _between(200000, 500000),
  ),
  RangeBucket(value: '500k-plus', label: '\$500K+', test: _atLeast(500000)),
];

final feeBuckets = [
  RangeBucket(value: 'under-10k', label: 'Under \$10K', test: _under(10000)),
  RangeBucket(
    value: '10k-30k',
    label: '\$10K – \$30K',
    test: _between(10000, 30000),
  ),
  RangeBucket(value: '30k-plus', label: '\$30K+', test: _atLeast(30000)),
];

final sizeBuckets = [
  RangeBucket(
    value: 'under-2000',
    label: 'Under 2,000 sq ft',
    test: _under(2000),
  ),
  RangeBucket(
    value: '2000-5000',
    label: '2,000 – 5,000 sq ft',
    test: _between(2000, 5000),
  ),
  RangeBucket(value: '5000-plus', label: '5,000+ sq ft', test: _atLeast(5000)),
];

bool Function(int?) _under(int max) =>
    (v) => v != null && v < max;
bool Function(int?) _between(int min, int max) =>
    (v) => v != null && v >= min && v < max;
bool Function(int?) _atLeast(int min) =>
    (v) => v != null && v >= min;

const countries = ['United Kingdom', 'United States', 'Pakistan'];
const industries = [
  'Food & Beverage',
  'Retail',
  'Fitness & Wellness',
  'Beauty',
  'Education',
];
const brandTypes = ['Single Unit', 'Multi-Unit', 'Master Franchise'];

/// One of the six categories under Opportunities. `filters` names which of
/// the shared filter fields actually apply — Franchise Fee doesn't mean
/// anything for a commercial project, Property Size doesn't mean anything
/// for an investor, etc.
class OpportunityCategoryConfig {
  final String key;
  final String label;
  final IconData icon;
  final String description;
  final List<String> filters;

  const OpportunityCategoryConfig({
    required this.key,
    required this.label,
    required this.icon,
    required this.description,
    required this.filters,
  });
}

const opportunityCategories = [
  OpportunityCategoryConfig(
    key: 'brands',
    label: 'Brands',
    icon: Icons.storefront_rounded,
    description: 'Brands actively expanding right now.',
    filters: ['country', 'industry', 'brandType'],
  ),
  OpportunityCategoryConfig(
    key: 'franchise',
    label: 'Franchise Opportunities',
    icon: Icons.handshake_rounded,
    description: 'Concepts open for new territories.',
    filters: ['country', 'industry', 'investment', 'fee'],
  ),
  OpportunityCategoryConfig(
    key: 'investors',
    label: 'Investors',
    icon: Icons.trending_up_rounded,
    description: 'Investors backing franchise growth.',
    filters: ['country', 'investment'],
  ),
  OpportunityCategoryConfig(
    key: 'locations',
    label: 'Locations',
    icon: Icons.location_city_rounded,
    description: 'Retail and commercial space for lease.',
    filters: ['country', 'size'],
  ),
  OpportunityCategoryConfig(
    key: 'retail',
    label: 'Retail Spaces',
    icon: Icons.shopping_bag_rounded,
    description: 'Shop and showroom units in prime spots.',
    filters: ['country', 'size'],
  ),
  OpportunityCategoryConfig(
    key: 'commercial',
    label: 'Commercial Projects',
    icon: Icons.apartment_rounded,
    description: 'Office and mixed-use developments.',
    filters: ['country', 'size'],
  ),
];

OpportunityCategoryConfig categoryFor(String key) =>
    opportunityCategories.firstWhere((c) => c.key == key);

/// Which categories a given account type sees — a first pass at "the
/// opportunities show up according to role," since the doc didn't specify
/// the exact mapping. Worth confirming/adjusting once this is reviewed.
///
/// landlord/developer/consultant/vendor/franchisee have no entry at all:
/// none of them browse this category hub — see OpportunitiesScreen, which
/// shows each of them their own real content instead and never calls
/// categoriesForRole for them.
///
/// "Investors" is deliberately never listed for any role — it's still
/// defined above (and OpportunityListScreen/OpportunityDetailScreen still
/// render it) so the screen isn't thrown away, but every account type it
/// showed for used mock listings with no real data source (see
/// OpportunityListing's doc comment), so it's hidden from navigation until
/// that access-control decision is actually made.
const _categoriesByRole = {
  'brand': ['locations', 'retail', 'commercial'],
  'investor': ['brands', 'franchise'],
};

/// Brands/Franchise are real for every role — the safe fallback for an org
/// type with no explicit entry above (there shouldn't be one; this only
/// guards against orgType being null or a future new type), so it never
/// silently lands on "investors" or the brand-only property categories.
const _fallbackCategoryKeys = ['brands', 'franchise'];

List<OpportunityCategoryConfig> categoriesForRole(String? orgType) {
  final keys = _categoriesByRole[orgType] ?? _fallbackCategoryKeys;
  return opportunityCategories.where((c) => keys.contains(c.key)).toList();
}

/// Fictional listings, clearly not real brands — enough field variety for
/// the filters to have something to do. Only "investors" is still here —
/// "brands"/"franchise" moved to real data (see BrandsScreen).
const mockOpportunities = [
  // Investors
  OpportunityListing(
    id: 'i1',
    category: 'investors',
    title: 'Alden Capital Partners',
    city: 'London',
    country: 'United Kingdom',
    investmentMin: 500000,
    investmentMax: 2000000,
    description:
        'Backing multi-unit F&B and fitness operators across the UK and Europe.',
    featured: true,
  ),
  OpportunityListing(
    id: 'i2',
    category: 'investors',
    title: 'Meridian Growth Fund',
    city: 'New York',
    country: 'United States',
    investmentMin: 250000,
    investmentMax: 1000000,
    description:
        'Early-stage capital for retail and wellness franchise operators.',
  ),
  OpportunityListing(
    id: 'i3',
    category: 'investors',
    title: 'Sahil Ventures',
    city: 'Lahore',
    country: 'Pakistan',
    investmentMin: 100000,
    investmentMax: 400000,
    description:
        'Regional investor group focused on master franchise deals in South Asia.',
  ),
];

List<OpportunityListing> opportunitiesFor(String category) =>
    mockOpportunities.where((o) => o.category == category).toList();

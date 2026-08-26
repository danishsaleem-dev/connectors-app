import 'package:flutter/material.dart';

/// One listing shown under the Opportunities tab. **Mock data throughout —
/// nothing here is fetched from a backend.** The real property browsing
/// feature (search/filter over live `properties` rows) already exists as
/// `LocationsScreen`, brand-only; this is a separate, UI-only preview of
/// the fuller catalogue the business-logic doc describes across all seven
/// account types, deliberately kept mock rather than quietly exposing new
/// real data or new access rules no one has signed off on.
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

  String? get feeDisplay => franchiseFee == null ? null : '${_money(franchiseFee!)} fee';

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

  const RangeBucket({required this.value, required this.label, required this.test});
}

// Not const: each bucket's `test` closure is built by calling a helper
// function (_under/_between/_atLeast), and a function call can't be
// evaluated in a const context even though the resulting closure itself
// is a plain, stable function value.
final investmentBuckets = [
  RangeBucket(value: 'under-50k', label: 'Under \$50K', test: _under(50000)),
  RangeBucket(value: '50k-200k', label: '\$50K – \$200K', test: _between(50000, 200000)),
  RangeBucket(value: '200k-500k', label: '\$200K – \$500K', test: _between(200000, 500000)),
  RangeBucket(value: '500k-plus', label: '\$500K+', test: _atLeast(500000)),
];

final feeBuckets = [
  RangeBucket(value: 'under-10k', label: 'Under \$10K', test: _under(10000)),
  RangeBucket(value: '10k-30k', label: '\$10K – \$30K', test: _between(10000, 30000)),
  RangeBucket(value: '30k-plus', label: '\$30K+', test: _atLeast(30000)),
];

final sizeBuckets = [
  RangeBucket(value: 'under-2000', label: 'Under 2,000 sq ft', test: _under(2000)),
  RangeBucket(value: '2000-5000', label: '2,000 – 5,000 sq ft', test: _between(2000, 5000)),
  RangeBucket(value: '5000-plus', label: '5,000+ sq ft', test: _atLeast(5000)),
];

bool Function(int?) _under(int max) => (v) => v != null && v < max;
bool Function(int?) _between(int min, int max) => (v) => v != null && v >= min && v < max;
bool Function(int?) _atLeast(int min) => (v) => v != null && v >= min;

const countries = ['United Kingdom', 'United States', 'Pakistan'];
const industries = ['Food & Beverage', 'Retail', 'Fitness & Wellness', 'Beauty', 'Education'];
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
    description: 'Brands actively expanding and open to new partners.',
    filters: ['country', 'industry', 'brandType'],
  ),
  OpportunityCategoryConfig(
    key: 'franchise',
    label: 'Franchise Opportunities',
    icon: Icons.handshake_rounded,
    description: 'Franchise concepts open for new territories.',
    filters: ['country', 'industry', 'investment', 'fee'],
  ),
  OpportunityCategoryConfig(
    key: 'investors',
    label: 'Investors',
    icon: Icons.trending_up_rounded,
    description: 'Investors backing multi-unit and master franchise deals.',
    filters: ['country', 'investment'],
  ),
  OpportunityCategoryConfig(
    key: 'locations',
    label: 'Locations',
    icon: Icons.location_city_rounded,
    description: 'Retail and commercial space available for lease.',
    filters: ['country', 'size'],
  ),
  OpportunityCategoryConfig(
    key: 'retail',
    label: 'Retail Spaces',
    icon: Icons.shopping_bag_rounded,
    description: 'Shop and showroom units in prime retail locations.',
    filters: ['country', 'size'],
  ),
  OpportunityCategoryConfig(
    key: 'commercial',
    label: 'Commercial Projects',
    icon: Icons.apartment_rounded,
    description: 'Office, mixed-use and standalone commercial developments.',
    filters: ['country', 'size'],
  ),
];

OpportunityCategoryConfig categoryFor(String key) =>
    opportunityCategories.firstWhere((c) => c.key == key);

/// Which categories a given account type sees — a first pass at "the
/// opportunities show up according to role," since the doc didn't specify
/// the exact mapping. Worth confirming/adjusting once this is reviewed.
const _categoriesByRole = {
  'brand': ['investors', 'locations', 'retail', 'commercial'],
  'franchisee': ['brands', 'franchise'],
  'landlord': ['brands', 'franchise'],
  'developer': ['brands', 'franchise'],
  'investor': ['brands', 'franchise', 'investors'],
};

List<OpportunityCategoryConfig> categoriesForRole(String? orgType) {
  final keys = _categoriesByRole[orgType];
  if (keys == null) return opportunityCategories;
  return opportunityCategories.where((c) => keys.contains(c.key)).toList();
}

/// Fictional listings, clearly not real brands — enough per category and
/// enough field variety for the filters to have something to do.
const mockOpportunities = [
  // Brands
  OpportunityListing(
    id: 'b1',
    category: 'brands',
    title: 'Verona Kitchens',
    city: 'London',
    country: 'United Kingdom',
    industry: 'Food & Beverage',
    brandType: 'Multi-Unit',
    description: 'A fast-casual Italian concept expanding across the UK, seeking partners in secondary cities.',
    featured: true,
  ),
  OpportunityListing(
    id: 'b2',
    category: 'brands',
    title: 'Northbridge Coffee Co.',
    city: 'Austin',
    country: 'United States',
    industry: 'Food & Beverage',
    brandType: 'Single Unit',
    description: 'Specialty coffee roaster looking for its first franchised locations outside Texas.',
  ),
  OpportunityListing(
    id: 'b3',
    category: 'brands',
    title: 'Solace Wellness Spa',
    city: 'Lahore',
    country: 'Pakistan',
    industry: 'Beauty',
    brandType: 'Master Franchise',
    description: 'Boutique spa brand offering master franchise rights across South Asia.',
  ),
  OpportunityListing(
    id: 'b4',
    category: 'brands',
    title: 'Rapid Fit Studios',
    city: 'Manchester',
    country: 'United Kingdom',
    industry: 'Fitness & Wellness',
    brandType: 'Multi-Unit',
    description: '30-minute HIIT studio format, 40 units open, targeting the North of England next.',
  ),

  // Franchise Opportunities
  OpportunityListing(
    id: 'f1',
    category: 'franchise',
    title: 'Bloom & Co. Florists',
    city: 'Leeds',
    country: 'United Kingdom',
    industry: 'Retail',
    investmentMin: 45000,
    investmentMax: 80000,
    franchiseFee: 8000,
    description: 'Established florist franchise with a low-overhead retail format.',
  ),
  OpportunityListing(
    id: 'f2',
    category: 'franchise',
    title: 'Turlington Menswear',
    city: 'Chicago',
    country: 'United States',
    industry: 'Retail',
    investmentMin: 180000,
    investmentMax: 320000,
    franchiseFee: 25000,
    description: 'Made-to-measure menswear, mall and high-street formats available.',
    featured: true,
  ),
  OpportunityListing(
    id: 'f3',
    category: 'franchise',
    title: 'Crestline Learning Centres',
    city: 'Karachi',
    country: 'Pakistan',
    industry: 'Education',
    investmentMin: 60000,
    investmentMax: 150000,
    franchiseFee: 12000,
    description: 'After-school tutoring centre network, single and multi-unit territories open.',
  ),
  OpportunityListing(
    id: 'f4',
    category: 'franchise',
    title: 'Pacific Grill House',
    city: 'San Diego',
    country: 'United States',
    industry: 'Food & Beverage',
    investmentMin: 400000,
    investmentMax: 750000,
    franchiseFee: 40000,
    description: 'Full-service casual dining concept, established supply chain and training programme.',
  ),

  // Investors
  OpportunityListing(
    id: 'i1',
    category: 'investors',
    title: 'Alden Capital Partners',
    city: 'London',
    country: 'United Kingdom',
    investmentMin: 500000,
    investmentMax: 2000000,
    description: 'Backing multi-unit F&B and fitness operators across the UK and Europe.',
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
    description: 'Early-stage capital for retail and wellness franchise operators.',
  ),
  OpportunityListing(
    id: 'i3',
    category: 'investors',
    title: 'Sahil Ventures',
    city: 'Lahore',
    country: 'Pakistan',
    investmentMin: 100000,
    investmentMax: 400000,
    description: 'Regional investor group focused on master franchise deals in South Asia.',
  ),

  // Locations
  OpportunityListing(
    id: 'l1',
    category: 'locations',
    title: 'Riverside Walk Unit 4',
    city: 'Bristol',
    country: 'United Kingdom',
    sizeSqft: 1800,
    description: 'Ground-floor retail unit on a high-footfall pedestrian route.',
  ),
  OpportunityListing(
    id: 'l2',
    category: 'locations',
    title: 'Midtown Plaza Suite 210',
    city: 'Dallas',
    country: 'United States',
    sizeSqft: 3200,
    description: 'Second-floor commercial suite in a mixed-use development.',
  ),
  OpportunityListing(
    id: 'l3',
    category: 'locations',
    title: 'Gulberg Corner Plot',
    city: 'Lahore',
    country: 'Pakistan',
    sizeSqft: 2600,
    description: 'Corner-facing plot in an established commercial district.',
    featured: true,
  ),

  // Retail Spaces
  OpportunityListing(
    id: 'r1',
    category: 'retail',
    title: 'Harborview Mall Kiosk 12',
    city: 'Liverpool',
    country: 'United Kingdom',
    sizeSqft: 220,
    description: 'High-traffic kiosk near the food court entrance.',
  ),
  OpportunityListing(
    id: 'r2',
    category: 'retail',
    title: 'Sunset Boulevard Showroom',
    city: 'Los Angeles',
    country: 'United States',
    sizeSqft: 4100,
    description: 'Flagship-scale showroom on a major retail strip.',
  ),
  OpportunityListing(
    id: 'r3',
    category: 'retail',
    title: 'DHA Phase 6 Shop 3B',
    city: 'Karachi',
    country: 'Pakistan',
    sizeSqft: 950,
    description: 'Shop unit in an established residential-commercial district.',
  ),

  // Commercial Projects
  OpportunityListing(
    id: 'c1',
    category: 'commercial',
    title: 'The Anchorage Development',
    city: 'Leeds',
    country: 'United Kingdom',
    sizeSqft: 12000,
    description: 'New-build mixed-use development, pre-leasing office and retail floors.',
    featured: true,
  ),
  OpportunityListing(
    id: 'c2',
    category: 'commercial',
    title: 'Summit Business Park, Block C',
    city: 'Houston',
    country: 'United States',
    sizeSqft: 8600,
    description: 'Standalone commercial building suited to a flagship or HQ tenant.',
  ),
  OpportunityListing(
    id: 'c3',
    category: 'commercial',
    title: 'Bahria Town Commercial Tower',
    city: 'Islamabad',
    country: 'Pakistan',
    sizeSqft: 15000,
    description: 'Multi-floor commercial tower with office and retail podium.',
  ),
];

List<OpportunityListing> opportunitiesFor(String category) =>
    mockOpportunities.where((o) => o.category == category).toList();

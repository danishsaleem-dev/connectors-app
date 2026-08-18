/// Ported from the website's src/lib/content/company.ts — the real corporate
/// narrative content, not invented copy. Deliberately no stats/testimonial
/// data here: the site itself ships no fabricated numbers ("Inventing
/// credibility statistics... is a real-world misrepresentation") and its
/// testimonials are explicit fictional placeholders, so neither belongs in
/// a real build of this app either.
class Feature {
  final String title;
  final String body;

  const Feature({required this.title, required this.body});
}

class CompanyData {
  CompanyData._();

  static const mission =
      'To create a powerful business network that connects brands, '
      'investors, franchisees, landlords and commercial projects together '
      'for sustainable growth and long-term success.';

  static const vision =
      'To become the leading global business connectivity platform for '
      'retail expansion, franchise development and commercial growth.';

  static const about =
      'Connectors bridges the gap between brands, franchisees, investors, '
      'mall owners, landlords and project developers — a growth partner, '
      'not just a consultant, so every side of an expansion moves through '
      'one ecosystem instead of five disconnected vendors.';

  static const values = [
    Feature(title: 'Integrity', body: 'Transparent, ethical business relationships.'),
    Feature(title: 'Innovation', body: 'Modern business and technology solutions.'),
    Feature(title: 'Growth', body: 'Helping every partner scale successfully.'),
    Feature(title: 'Partnerships', body: 'Long-term strategic relationships.'),
    Feature(title: 'Excellence', body: 'Premium service, measurable results.'),
  ];

  static const whyChoose = [
    Feature(title: 'One ecosystem', body: 'Location, capital, marketing and tech — one platform.'),
    Feature(title: 'Real network', body: 'Existing ties to brands, investors, malls and landlords.'),
    Feature(title: 'Built on tech', body: 'Modern systems that scale without losing control.'),
    Feature(title: 'End-to-end', body: 'From location sourcing to franchise sales, handled.'),
  ];

  static const valueCreation = [
    'Connecting opportunities',
    'Accelerating expansion',
    'Reducing operational challenges',
    'Enhancing visibility',
    'Improving investment access',
    'Building sustainable growth networks',
  ];

  static const industries = [
    'Food & Beverage',
    'Fashion & Apparel',
    'Beauty & Cosmetics',
    'Retail Chains',
    'Fitness & Wellness',
    'Entertainment',
    'Healthcare',
    'Education',
    'Technology',
    'Lifestyle Brands',
    'Luxury Retail',
    'Hospitality',
  ];
}

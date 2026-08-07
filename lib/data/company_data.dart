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

  static const whyChoose = [
    Feature(
      title: 'One complete ecosystem',
      body:
          'Location, franchise, capital, marketing and technology under a '
          'single platform — not five vendors who have never spoken to '
          'each other.',
    ),
    Feature(
      title: 'Powerful network',
      body:
          'Strong existing relationships with brands, investors, malls, '
          'landlords and franchise operators.',
    ),
    Feature(
      title: 'Technology driven',
      body: 'Modern systems built for networks that need to scale without losing control.',
    ),
    Feature(
      title: 'End-to-end solutions',
      body:
          'From location sourcing to franchise sales and marketing — we '
          'manage the complete growth journey.',
    ),
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

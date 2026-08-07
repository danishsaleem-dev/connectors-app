/// Ported from the website's src/lib/site.ts — same office details, contact
/// emails and audience copy, so the app never says something the site
/// doesn't (or vice versa).
class Office {
  final String label;
  final String phoneDisplay;
  final String phoneHref;
  final String address;

  const Office({
    required this.label,
    required this.phoneDisplay,
    required this.phoneHref,
    required this.address,
  });
}

class Audience {
  final String slug;
  final String nav;
  final String title;
  final String lead;

  const Audience({
    required this.slug,
    required this.nav,
    required this.title,
    required this.lead,
  });
}

class SiteData {
  SiteData._();

  static const name = 'Connectors';
  static const tagline = 'Connecting Growth Through Opportunities';
  static const promise = "We Don't Just Connect Businesses — We Create Growth.";
  static const description =
      'Connectors is a business expansion, franchise development, retail '
      'leasing and investment facilitation company. We connect brands with '
      'locations, franchisees and investors — and connect landlords with the '
      'brands that fill their space.';

  static const generalEmail = 'info@connectors.group';

  static const offices = [
    Office(
      label: 'UK Office',
      phoneDisplay: '+44 7894 560314',
      phoneHref: 'tel:+447894560314',
      address: '26-28 Mount Row, London W1K 3SQ, United Kingdom',
    ),
    Office(
      label: 'US Office',
      phoneDisplay: '+1 702 964 1853',
      phoneHref: 'tel:+17029641853',
      address: '8870 S Maryland Pkwy, Suite 130, Las Vegas NV 89123, United States',
    ),
    Office(
      label: 'Pakistan Office',
      phoneDisplay: '+92 300 6885680',
      phoneHref: 'tel:+923006885680',
      address: '23 Hunza Block, Allama Iqbal Town, Lahore, Pakistan',
    ),
  ];

  /// Same four doors as the website nav/homepage.
  static const audiences = [
    Audience(
      slug: 'for-brands',
      nav: 'For Brands',
      title: 'Brands',
      lead:
          'Expand into the right locations, turn your business into a '
          'franchise, and meet investors ready to back it.',
    ),
    Audience(
      slug: 'for-franchise',
      nav: 'For Franchisees',
      title: 'Franchisees',
      lead:
          'Find a franchise matched to your budget, territory and '
          'experience — with the training and systems to run it.',
    ),
    Audience(
      slug: 'for-landlords',
      nav: 'For Landlords',
      title: 'Landlords & Developers',
      lead:
          'Fill vacant retail, mall and commercial space with established '
          'brands actively looking to expand.',
    ),
    Audience(
      slug: 'for-investors',
      nav: 'For Investors',
      title: 'Investors',
      lead:
          'Access proven business models, expansion-ready brands and '
          'multi-unit franchise opportunities.',
    ),
  ];

  static Audience audienceBySlug(String slug) =>
      audiences.firstWhere((a) => a.slug == slug);
}

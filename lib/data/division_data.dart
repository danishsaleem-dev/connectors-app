/// Ported from src/lib/content/divisions.ts — same seven divisions, same
/// per-audience relevance list, so "how we work with you" never drifts
/// between the site and the app.
class Division {
  final String navLabel;
  final String short;
  final List<String> audiences;

  const Division({required this.navLabel, required this.short, required this.audiences});
}

class DivisionData {
  DivisionData._();

  static const all = [
    Division(
      navLabel: 'Brand Expansion',
      short: 'Find, evaluate and secure high-potential retail locations.',
      audiences: ['for-brands', 'for-landlords'],
    ),
    Division(
      navLabel: 'Franchise Development',
      short: 'Turn a proven business into a scalable franchise — and sell it well.',
      audiences: ['for-brands', 'for-franchise'],
    ),
    Division(
      navLabel: 'Investor Connections',
      short: 'Introduce brands to capital, and investors to verified opportunities.',
      audiences: ['for-brands', 'for-investors'],
    ),
    Division(
      navLabel: 'Mall & Project Support',
      short: 'Bring recognised brands into malls and commercial developments.',
      audiences: ['for-landlords'],
    ),
    Division(
      navLabel: 'Landlord Services',
      short: 'Submit a space and we match it to brands actively expanding.',
      audiences: ['for-landlords'],
    ),
    Division(
      navLabel: 'Marketing & Branding',
      short: '360° marketing — digital, commercial, outdoor and everything between.',
      audiences: ['for-brands', 'for-franchise'],
    ),
    Division(
      navLabel: 'Technology',
      short: 'The franchise management software that runs the whole network.',
      audiences: ['for-brands', 'for-franchise'],
    ),
  ];

  static List<Division> forAudience(String slug) =>
      all.where((d) => d.audiences.contains(slug)).toList();
}

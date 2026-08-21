/// Ported from src/lib/content/divisions.ts — same seven divisions. Used by
/// ServicesScreen as the full catalog; no longer filtered per audience (see
/// audience_screen.dart) since that filtered view was dropped in favour of
/// putting the enquiry form first on those screens.
class Division {
  final String navLabel;
  final String short;

  const Division({required this.navLabel, required this.short});
}

class DivisionData {
  DivisionData._();

  static const all = [
    Division(
      navLabel: 'Brand Expansion',
      short: 'Find, evaluate and secure high-potential retail locations.',
    ),
    Division(
      navLabel: 'Franchise Development',
      short: 'Turn a proven business into a scalable franchise — and sell it well.',
    ),
    Division(
      navLabel: 'Investor Connections',
      short: 'Introduce brands to capital, and investors to verified opportunities.',
    ),
    Division(
      navLabel: 'Mall & Project Support',
      short: 'Bring recognised brands into malls and commercial developments.',
    ),
    Division(
      navLabel: 'Landlord Services',
      short: 'Submit a space and we match it to brands actively expanding.',
    ),
    Division(
      navLabel: 'Marketing & Branding',
      short: '360° marketing — digital, commercial, outdoor and everything between.',
    ),
    Division(
      navLabel: 'Technology',
      short: 'The franchise management software that runs the whole network.',
    ),
  ];
}

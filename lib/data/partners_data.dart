/// Partners Program content — ported from the website's
/// src/lib/content/partners.ts, trimmed to what a phone screen needs.
class PartnerDiscipline {
  final String key;
  final String title;
  final String body;

  const PartnerDiscipline({required this.key, required this.title, required this.body});
}

class PartnerBenefit {
  final String title;
  final String body;

  const PartnerBenefit({required this.title, required this.body});
}

class PartnersData {
  PartnersData._();

  /// Keys match the vendor account type's discipline values.
  static const disciplines = [
    PartnerDiscipline(
      key: 'designer',
      title: 'Designers',
      body: 'Brand identity, store concept and the visual language a rollout repeats.',
    ),
    PartnerDiscipline(
      key: 'architect',
      title: 'Architects',
      body: 'Drawings, approvals and the technical package a landlord and council will accept.',
    ),
    PartnerDiscipline(
      key: 'interior',
      title: 'Interior Specialists',
      body: 'Fit-out, joinery, lighting and the finish that makes a unit feel like the brand.',
    ),
    PartnerDiscipline(
      key: 'agency',
      title: 'Agencies',
      body: 'Launch campaigns, local marketing and the opening that gets noticed.',
    ),
    PartnerDiscipline(
      key: 'consultant',
      title: 'Consultants',
      body: 'Feasibility, operations, supply chain and franchise structuring.',
    ),
    PartnerDiscipline(
      key: 'contractor',
      title: 'Contractors',
      body: 'Build, site management and handing over on the date you said you would.',
    ),
  ];

  /// Trimmed from the website's six to the three that matter most on a
  /// first screen — no fee, private profile, and repeat work.
  static const benefits = [
    PartnerBenefit(
      title: 'Briefed work, not cold leads',
      body: 'We introduce you with the site, scope and timeline already agreed.',
    ),
    PartnerBenefit(
      title: 'Private, not public',
      body: 'Your profile is only ever seen by the Connectors team.',
    ),
    PartnerBenefit(
      title: 'No fee to join',
      body: "We're paid on the project, never for access to the bench.",
    ),
  ];
}

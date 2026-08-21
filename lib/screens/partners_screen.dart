import 'package:flutter/material.dart';
import '../data/partners_data.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/enquire_cta.dart';
import '../widgets/info_list.dart';
import '../widgets/reveal.dart';
import '../widgets/section_intro.dart';

const _icons = {
  'designer': Icons.brush_rounded,
  'architect': Icons.architecture_rounded,
  'interior': Icons.chair_alt_rounded,
  'agency': Icons.campaign_rounded,
  'consultant': Icons.insights_rounded,
  'contractor': Icons.construction_rounded,
};

/// Thin Scaffold wrapper for when this is reached by pushing from the Menu.
/// A signed-in vendor reaches the same content directly as PartnersBody —
/// their nav tab — with no second AppBar nested under the app shell's own.
class PartnersScreen extends StatelessWidget {
  const PartnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partners Program')),
      body: const SafeArea(child: SingleChildScrollView(child: PartnersBody())),
    );
  }
}

/// The vendor side of the business — designers, architects, agencies and
/// contractors joining the bench Connectors places on real projects.
/// Condensed from the website's /partners: the "why it exists" pitch, the
/// six disciplines, three of the six benefits, then straight to signup.
class PartnersBody extends StatelessWidget {
  const PartnersBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.sm,
        AppSpacing.page,
        AppSpacing.section,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'The people who actually build the openings we broker.',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'A vetted bench of designers, architects, interior '
            'specialists, agencies, consultants and contractors we can '
            'put in front of a brand the day the lease is signed.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
          ),
          const SizedBox(height: AppSpacing.section),
          const SectionIntro(eyebrow: 'Six disciplines', title: 'One bench, every trade.'),
          const SizedBox(height: AppSpacing.sm),
          InfoList(
            items: [
              for (final d in PartnersData.disciplines)
                InfoItem(icon: _icons[d.key] ?? Icons.circle, title: d.title, body: d.body),
            ],
          ),
          const SizedBox(height: AppSpacing.section),
          const SectionIntro(eyebrow: 'What you get', title: 'Why vendors stay on the bench.'),
          const SizedBox(height: AppSpacing.heading),
          for (var i = 0; i < PartnersData.benefits.length; i++) ...[
            if (i > 0) const SizedBox(height: AppSpacing.lg),
            Reveal(index: i, child: _BenefitRow(benefit: PartnersData.benefits[i])),
          ],
          const SizedBox(height: AppSpacing.section),
          const EnquireCta(message: 'Questions before you apply? Email our team.'),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  final PartnerBenefit benefit;

  const _BenefitRow({required this.benefit});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(Icons.check_rounded, color: AppColors.violet600, size: 18),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(benefit.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 3),
              Text(
                benefit.body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

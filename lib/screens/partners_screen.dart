import 'package:flutter/material.dart';
import '../data/partners_data.dart';
import '../theme/colors.dart';
import '../widgets/enquire_cta.dart';
import '../widgets/reveal.dart';
import '../widgets/section_intro.dart';
import '../widgets/tile_grid.dart';
import 'signup_screen.dart';

const _icons = {
  'designer': Icons.brush_rounded,
  'architect': Icons.architecture_rounded,
  'interior': Icons.chair_alt_rounded,
  'agency': Icons.campaign_rounded,
  'consultant': Icons.insights_rounded,
  'contractor': Icons.construction_rounded,
};

/// The vendor side of the business — designers, architects, agencies and
/// contractors joining the bench Connectors places on real projects.
/// Condensed from the website's /partners: the "why it exists" pitch, the
/// six disciplines, three of the six benefits, then straight to signup.
class PartnersScreen extends StatelessWidget {
  const PartnersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partners Program')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The people who actually build the openings we broker.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 10),
              Text(
                'A vetted bench of designers, architects, interior '
                'specialists, agencies, consultants and contractors we can '
                "put in front of a brand the day the lease is signed.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
              ),
              const SizedBox(height: 24),
              const SectionIntro(eyebrow: 'Six disciplines', title: 'One bench, every trade.'),
              const SizedBox(height: 16),
              TileGrid(
                items: [
                  for (final d in PartnersData.disciplines)
                    TileItem(icon: _icons[d.key] ?? Icons.circle, title: d.title, body: d.body),
                ],
              ),
              const SizedBox(height: 32),
              const SectionIntro(eyebrow: 'What you get', title: "Why vendors stay on the bench."),
              const SizedBox(height: 16),
              for (var i = 0; i < PartnersData.benefits.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                Reveal(index: i, child: _BenefitRow(benefit: PartnersData.benefits[i])),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignupScreen(initialType: 'vendor')),
                  ),
                  child: const Text('Become a vendor'),
                ),
              ),
              const SizedBox(height: 12),
              const EnquireCta(message: 'Questions before you apply? Email our team.'),
            ],
          ),
        ),
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
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.violet50, shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: AppColors.violet600, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(benefit.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  benefit.body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

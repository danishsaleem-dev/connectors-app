import 'package:flutter/material.dart';
import '../data/partners_data.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../widgets/eyebrow.dart';
import '../widgets/reveal.dart';
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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
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
              const Eyebrow('Six disciplines'),
              const SizedBox(height: 12),
              for (var row = 0; row < PartnersData.disciplines.length; row += 2) ...[
                if (row > 0) const SizedBox(height: 10),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _DisciplineTile(index: row)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: row + 1 < PartnersData.disciplines.length
                            ? _DisciplineTile(index: row + 1)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 28),
              const Eyebrow('What you get'),
              const SizedBox(height: 12),
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
            ],
          ),
        ),
      ),
    );
  }
}

class _DisciplineTile extends StatelessWidget {
  final int index;

  const _DisciplineTile({required this.index});

  @override
  Widget build(BuildContext context) {
    final discipline = PartnersData.disciplines[index];
    return Reveal(
      index: index,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: cardShadow(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_icons[discipline.key] ?? Icons.circle, color: AppColors.violet600, size: 20),
            const SizedBox(height: 10),
            Text(discipline.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              discipline.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
            ),
          ],
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
        const Padding(
          padding: EdgeInsets.only(top: 4),
          child: Icon(Icons.check_circle_rounded, color: AppColors.violet600, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
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
      ],
    );
  }
}

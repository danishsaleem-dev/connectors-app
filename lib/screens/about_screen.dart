import 'package:flutter/material.dart';
import '../data/company_data.dart';
import '../data/division_data.dart';
import '../data/site_data.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../widgets/enquire_cta.dart';
import '../widgets/reveal.dart';
import '../widgets/section_intro.dart';
import '../widgets/tile_grid.dart';

/// Ported from the website's story/values narrative — reworded into the
/// numbers-free "what we stand for" it already was, plus a small facts row
/// (office count, division count, value count) computed from the app's own
/// data rather than typed in, so it can't drift or read as a performance
/// stat the way a fabricated "500+ deals closed" claim would.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _valueIcons = [
    Icons.verified_rounded,
    Icons.auto_awesome_rounded,
    Icons.trending_up_rounded,
    Icons.handshake_rounded,
    Icons.workspace_premium_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Connectors')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We built the bridge that expansion kept falling through.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                CompanyData.about,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
              ),
              const SizedBox(height: 24),
              Reveal(
                child: Row(
                  children: [
                    _FactTile(value: '${SiteData.offices.length}', label: 'Global offices'),
                    const SizedBox(width: 10),
                    _FactTile(value: '${DivisionData.all.length}', label: 'Service divisions'),
                    const SizedBox(width: 10),
                    _FactTile(value: '${CompanyData.values.length}', label: 'Core values'),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(child: _StatementCard(label: 'Mission', body: CompanyData.mission)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatementCard(label: 'Vision', body: CompanyData.vision)),
                ],
              ),
              const SizedBox(height: 32),
              const SectionIntro(eyebrow: 'What we stand for', title: 'Five values, everywhere we operate.'),
              const SizedBox(height: 16),
              TileGrid(
                flat: true,
                items: [
                  for (var i = 0; i < CompanyData.values.length; i++)
                    TileItem(
                      icon: _valueIcons[i % _valueIcons.length],
                      title: CompanyData.values[i].title,
                      body: CompanyData.values[i].body,
                    ),
                ],
              ),
              const SizedBox(height: 32),
              const EnquireCta(message: 'Want to know more? Email our team.'),
            ],
          ),
        ),
      ),
    );
  }
}

class _FactTile extends StatelessWidget {
  final String value;
  final String label;

  const _FactTile({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(color: AppColors.violet50, borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.violet600),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatementCard extends StatelessWidget {
  final String label;
  final String body;

  const _StatementCard({required this.label, required this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: cardShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.violet600),
          ),
          const SizedBox(height: 8),
          Text(body, style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),
    );
  }
}

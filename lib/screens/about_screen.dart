import 'package:flutter/material.dart';
import '../data/company_data.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../widgets/eyebrow.dart';
import '../widgets/reveal.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Connectors')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
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
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(child: _StatementCard(label: 'Mission', body: CompanyData.mission)),
                  const SizedBox(width: 12),
                  Expanded(child: _StatementCard(label: 'Vision', body: CompanyData.vision)),
                ],
              ),
              const SizedBox(height: 32),
              const Eyebrow('What we stand for'),
              const SizedBox(height: 10),
              Text('Five values, everywhere we operate.', style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 16),
              for (var row = 0; row < CompanyData.values.length; row += 2) ...[
                if (row > 0) const SizedBox(height: 12),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: _ValueTile(feature: CompanyData.values[row], index: row)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: row + 1 < CompanyData.values.length
                            ? _ValueTile(feature: CompanyData.values[row + 1], index: row + 1)
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
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

class _ValueTile extends StatelessWidget {
  final Feature feature;
  final int index;

  const _ValueTile({required this.feature, required this.index});

  @override
  Widget build(BuildContext context) {
    return Reveal(
      index: index,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.grey50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              (index + 1).toString().padLeft(2, '0'),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.violet400),
            ),
            const SizedBox(height: 8),
            Text(feature.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              feature.body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }
}

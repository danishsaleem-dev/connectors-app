import 'package:flutter/material.dart';
import '../data/site_data.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_hero.dart';
import '../widgets/enquire_cta.dart';
import '../widgets/eyebrow.dart';
import '../widgets/reveal.dart';

/// Main screen — a compact promise banner straight into the "four doors"
/// split, which is the screen's entire job. Company narrative ("Why
/// Connectors", industries) now lives on About, and office contact details
/// have their own screen off the Menu — both were content to scroll past
/// before reaching anything you could actually do, which is what made this
/// screen feel like a landing page rather than an app.
class HomeScreen extends StatelessWidget {
  final void Function(int tabIndex) onSelectAudience;

  const HomeScreen({super.key, required this.onSelectAudience});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppHero(
            eyebrow: 'Business Expansion',
            title: SiteData.promise,
            body: SiteData.description,
          ),
          const SizedBox(height: AppSpacing.section),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Who we serve'),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Where do you fit?',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.heading),
                for (var i = 0; i < SiteData.audiences.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.md),
                  Reveal(
                    index: i,
                    child: _AudienceCard(
                      audience: SiteData.audiences[i],
                      onTap: () => onSelectAudience(i + 1),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                const EnquireCta(message: "Not sure where you fit? Email our team."),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AudienceCard extends StatelessWidget {
  final Audience audience;
  final VoidCallback onTap;

  const _AudienceCard({required this.audience, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: cardShadow(),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.violet50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(audience.icon, color: AppColors.violet600, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(audience.title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 4),
                    Text(
                      audience.lead,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.grey500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.grey50,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.violet600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

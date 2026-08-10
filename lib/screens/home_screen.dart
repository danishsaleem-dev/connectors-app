import 'package:flutter/material.dart';
import '../data/company_data.dart';
import '../data/site_data.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../widgets/app_hero.dart';
import '../widgets/enquire_cta.dart';
import '../widgets/eyebrow.dart';
import '../widgets/feature_rows.dart';
import '../widgets/marquee_strip.dart';
import '../widgets/offices_section.dart';
import '../widgets/reveal.dart';

/// Main screen — a compact promise banner, the "four doors" split (the
/// screen's actual job), a glanceable trust grid, an industries marquee and
/// office contact details. Tapping an audience card switches the app's
/// bottom-nav tab rather than navigating to a route.
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
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Who we serve'),
                const SizedBox(height: 10),
                Text(
                  'Where do you fit?',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 18),
                for (var i = 0; i < SiteData.audiences.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  Reveal(
                    index: i,
                    child: _AudienceCard(
                      audience: SiteData.audiences[i],
                      onTap: () => onSelectAudience(i + 1),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Why Connectors'),
                const SizedBox(height: 10),
                Text('One ecosystem.', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 16),
                FeatureRows(features: CompanyData.whyChoose),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Industries'),
                const SizedBox(height: 10),
                Text(
                  'Wherever retail happens.',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          MarqueeStrip(items: CompanyData.industries),
          const SizedBox(height: 36),
          const OfficesSection(),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: EnquireCta(message: "Not sure where you fit? Email our team."),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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

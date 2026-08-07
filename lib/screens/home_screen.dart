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

const _audienceIcons = {
  'for-brands': Icons.storefront_rounded,
  'for-franchise': Icons.handshake_rounded,
  'for-landlords': Icons.apartment_rounded,
  'for-investors': Icons.trending_up_rounded,
};

/// Main screen — the promise line + description from the website hero, the
/// "four doors" split, real "why Connectors" and "what we create" content
/// from the site's own copy, an industries marquee, and real office contact
/// details. Tapping an audience card switches the app's bottom-nav tab
/// rather than navigating to a route.
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
            big: true,
            eyebrow: 'Business Expansion · Franchise Development · Retail Leasing',
            title: SiteData.promise,
            body: SiteData.description,
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Who we serve'),
                const SizedBox(height: 10),
                Text(
                  'Four doors into the same network.',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 20),
                for (var i = 0; i < SiteData.audiences.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
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
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Why Connectors'),
                const SizedBox(height: 10),
                Text('Built as one ecosystem.', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 20),
                FeatureRows(features: CompanyData.whyChoose),
              ],
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Industries we serve'),
                const SizedBox(height: 10),
                Text(
                  'Wherever retail happens.',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          MarqueeStrip(items: CompanyData.industries),
          const SizedBox(height: 44),
          const OfficesSection(),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: EnquireCta(
              title: 'Not sure where you fit? Just tell us.',
              body:
                  'Send a short note about what you\'re trying to do, and our '
                  'team will point you to the right place.',
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
                child: Icon(
                  _audienceIcons[audience.slug] ?? Icons.arrow_forward_rounded,
                  color: AppColors.violet600,
                  size: 24,
                ),
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

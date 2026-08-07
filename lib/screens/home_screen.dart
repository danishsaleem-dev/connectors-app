import 'package:flutter/material.dart';
import '../data/site_data.dart';
import '../theme/colors.dart';
import '../widgets/app_hero.dart';
import '../widgets/enquire_cta.dart';
import '../widgets/eyebrow.dart';

const _audienceIcons = {
  'for-brands': Icons.storefront_rounded,
  'for-franchise': Icons.handshake_rounded,
  'for-landlords': Icons.apartment_rounded,
  'for-investors': Icons.trending_up_rounded,
};

/// Main screen — the promise line + description from the website hero, then
/// the same "four doors" split (Brands/Franchisees/Landlords/Investors) that
/// opens the homepage, except tapping one switches the app's bottom-nav tab
/// instead of navigating to a route. Cards use the same icon set as the
/// bottom nav rather than photo thumbnails, so the app has one consistent
/// icon vocabulary instead of two visual languages.
class HomeScreen extends StatelessWidget {
  final void Function(int tabIndex) onSelectAudience;

  const HomeScreen({super.key, required this.onSelectAudience});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppHero(
            eyebrow: 'Business Expansion · Franchise Development · Retail Leasing',
            title: SiteData.promise,
            body: SiteData.description,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 8),
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
                  _AudienceCard(
                    audience: SiteData.audiences[i],
                    onTap: () => onSelectAudience(i + 1),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 28),
          EnquireCta(
            title: 'Not sure where you fit? Just tell us.',
            body:
                'Send a short note about what you\'re trying to do, and our '
                'team will point you to the right place.',
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
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.grey200),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.violet50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  _audienceIcons[audience.slug] ?? Icons.arrow_forward_rounded,
                  color: AppColors.violet600,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
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
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.violet600),
            ],
          ),
        ),
      ),
    );
  }
}

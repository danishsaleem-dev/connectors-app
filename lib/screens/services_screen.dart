import 'package:flutter/material.dart';
import '../data/division_data.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../widgets/reveal.dart';

/// The seven divisions from the website's Solutions menu, as a scannable
/// catalog. Each division gets a full page on the website; here it's one
/// card — a phone screen that already has the divisions on the four
/// audience tabs doesn't need a second copy of that depth.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const _icons = [
    Icons.storefront_rounded,
    Icons.handshake_rounded,
    Icons.trending_up_rounded,
    Icons.apartment_rounded,
    Icons.real_estate_agent_rounded,
    Icons.campaign_rounded,
    Icons.hub_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Our Services')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          itemCount: DivisionData.all.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final division = DivisionData.all[i];
            return Reveal(
              index: i,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: cardShadow(),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: AppColors.violet50,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(_icons[i % _icons.length], color: AppColors.violet600, size: 22),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(division.navLabel, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 4),
                          Text(
                            division.short,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.grey500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

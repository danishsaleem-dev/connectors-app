import 'package:flutter/material.dart';
import '../data/company_data.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import 'reveal.dart';

/// "Why Connectors" feature cards — real copy from the site's whyChoose
/// content, each on its own elevated card rather than a plain bulleted list.
class FeatureRows extends StatelessWidget {
  final List<Feature> features;

  const FeatureRows({super.key, required this.features});

  static const _icons = [
    Icons.hub_rounded,
    Icons.diversity_3_rounded,
    Icons.bolt_rounded,
    Icons.route_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < features.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          Reveal(
            index: i,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
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
                    child: Icon(
                      _icons[i % _icons.length],
                      color: AppColors.violet600,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(features[i].title, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 6),
                        Text(
                          features[i].body,
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
          ),
        ],
      ],
    );
  }
}

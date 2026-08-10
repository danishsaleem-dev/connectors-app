import 'package:flutter/material.dart';
import '../data/company_data.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import 'reveal.dart';

/// "Why Connectors" as a glanceable 2-column grid of icon + short label —
/// trust badges, not marketing paragraphs, so this reads as an app screen
/// rather than a scrolled-down website section.
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
        for (var row = 0; row < features.length; row += 2) ...[
          if (row > 0) const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _Tile(feature: features[row], icon: _icons[row % _icons.length], index: row)),
                const SizedBox(width: 12),
                Expanded(
                  child: row + 1 < features.length
                      ? _Tile(
                          feature: features[row + 1],
                          icon: _icons[(row + 1) % _icons.length],
                          index: row + 1,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final Feature feature;
  final IconData icon;
  final int index;

  const _Tile({required this.feature, required this.icon, required this.index});

  @override
  Widget build(BuildContext context) {
    return Reveal(
      index: index,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: cardShadow(),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.violet50,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: AppColors.violet600, size: 18),
            ),
            const SizedBox(height: 12),
            Text(feature.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              feature.body,
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

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import 'reveal.dart';

class StatItem {
  final String value;
  final String label;

  const StatItem({required this.value, required this.label});
}

/// A row of figures divided by hairlines rather than sat in tinted boxes.
/// Labels are single words on purpose — "Global offices" wrapped to two
/// lines while its neighbours stayed on one, which made the middle tile
/// taller than the others and threw the whole row out of alignment.
class StatStrip extends StatelessWidget {
  final List<StatItem> items;

  const StatStrip({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Reveal(
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0)
                const VerticalDivider(width: 1, thickness: 1, color: AppColors.grey200),
              Expanded(
                child: Padding(
                  // Flush to the page margin on the left so the row lines up
                  // with the headline above it.
                  padding: EdgeInsets.only(
                    left: i == 0 ? 0.0 : AppSpacing.lg,
                    right: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        items[i].value,
                        style: Theme.of(context)
                            .textTheme
                            .displaySmall
                            ?.copyWith(color: AppColors.violet600),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        items[i].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: AppColors.grey500, letterSpacing: 1.2),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

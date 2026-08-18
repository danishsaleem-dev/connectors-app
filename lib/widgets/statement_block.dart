import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import 'reveal.dart';

/// A labelled paragraph with a violet rule down its left edge — used for
/// Mission and Vision.
///
/// These were previously two cards side by side, which gave each paragraph
/// about 160pt of width: the text broke to two or three words per line and
/// the two cards ended at wildly different heights. Full-width stacked
/// blocks let each paragraph set properly, and the rule carries the accent
/// the card was there for without adding another box.
class StatementBlock extends StatelessWidget {
  final String label;
  final String body;
  final int index;

  const StatementBlock({
    super.key,
    required this.label,
    required this.body,
    this.index = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Reveal(
      index: index,
      child: Container(
        padding: const EdgeInsets.only(left: AppSpacing.lg),
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: AppColors.violet200, width: 2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: AppColors.violet600, letterSpacing: 1.6),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(body, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}

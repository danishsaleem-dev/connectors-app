import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import 'eyebrow.dart';

/// The eyebrow + heading (+ optional lead paragraph) that opens most
/// sections on the site — pulled out once so every screen frames its
/// sections the same considered way instead of a heading style per screen.
class SectionIntro extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? lead;
  final Color eyebrowColor;

  const SectionIntro({
    super.key,
    required this.eyebrow,
    required this.title,
    this.lead,
    this.eyebrowColor = AppColors.violet600,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Eyebrow(eyebrow, color: eyebrowColor),
        const SizedBox(height: AppSpacing.sm),
        Text(title, style: Theme.of(context).textTheme.displaySmall),
        if (lead != null) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(lead!, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500)),
        ],
      ],
    );
  }
}

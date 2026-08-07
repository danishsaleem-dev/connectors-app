import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// The small uppercase tracked-out label above every heading on the site —
/// "For Brands", "How we work with you", etc.
class Eyebrow extends StatelessWidget {
  final String text;
  final Color color;

  const Eyebrow(this.text, {super.key, this.color = AppColors.violet600});

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: color,
            letterSpacing: 1.6,
          ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'eyebrow.dart';

/// Banner used at the top of every screen — a violet gradient, not a photo:
/// no network image to fail or wash out the text underneath, and a fixed
/// brand surface reads more like an app and less like a web page banner
/// dropped into a phone screen. The logo itself lives once in the app bar,
/// not repeated here on every screen.
class AppHero extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? body;

  const AppHero({super.key, required this.eyebrow, required this.title, this.body});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.violet900, AppColors.violet700, AppColors.ink],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(eyebrow, color: AppColors.violet200),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppColors.white),
          ),
          if (body != null) ...[
            const SizedBox(height: 10),
            Text(
              body!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.72),
                  ),
            ),
          ],
        ],
      ),
    );
  }
}

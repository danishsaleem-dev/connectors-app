import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'eyebrow.dart';
import 'orbit_field.dart';

/// The Home tab's own banner, carrying the brand's orbit-sphere motif — kept
/// off every other screen on purpose (see PageHeader), so it reads as the
/// app's one branded moment rather than a marketing hero repeated on every
/// tap, which is what made the app feel like a scrolled-down website.
class AppHero extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? body;

  const AppHero({super.key, required this.eyebrow, required this.title, this.body});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 26),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.violet900, AppColors.violet700, AppColors.ink],
          ),
        ),
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            // Pushed into the corner and clipped mostly off-canvas so it
            // reads as a faint brand flourish, not a globe sitting behind
            // the headline — the previous 260px version overlapped the
            // text directly, which is what made it feel distracting.
            Positioned(
              right: -60,
              bottom: -60,
              child: IgnorePointer(
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: OrbitField(
                    color: AppColors.white.withValues(alpha: 0.05),
                    count: 16,
                    accent: false,
                    animate: false,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Eyebrow(eyebrow, color: AppColors.violet200),
                const SizedBox(height: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.white),
                ),
                if (body != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    body!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.68),
                        ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

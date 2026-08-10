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
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.violet900, AppColors.violet700, AppColors.ink],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -60,
              top: -40,
              child: IgnorePointer(
                child: SizedBox(
                  width: 260,
                  height: 260,
                  // Dim — this sits directly behind the title, and a bright
                  // mark there reads as visual noise clashing with the text.
                  child: OrbitField(
                    color: AppColors.white.withValues(alpha: 0.08),
                    count: 22,
                    animate: false,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 32, height: 3, color: AppColors.violet400),
                const SizedBox(height: 14),
                Eyebrow(eyebrow, color: AppColors.violet200),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(color: AppColors.white),
                ),
                if (body != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    body!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.white.withValues(alpha: 0.72),
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

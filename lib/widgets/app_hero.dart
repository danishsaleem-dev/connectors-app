import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'eyebrow.dart';
import 'orbit_field.dart';

/// Banner used at the top of every screen — a violet gradient carrying the
/// brand's own orbit-sphere motif (not a photo, not a generic gradient
/// blob), rounded into the content below rather than a hard rectangle.
class AppHero extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? body;
  final bool big;

  const AppHero({
    super.key,
    required this.eyebrow,
    required this.title,
    this.body,
    this.big = false,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(28),
        bottomRight: Radius.circular(28),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(24, big ? 12 : 20, 24, big ? 40 : 30),
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
                  child: OrbitField(color: AppColors.white.withValues(alpha: 0.9), count: 22),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 32, height: 3, color: AppColors.violet400),
                const SizedBox(height: 16),
                Eyebrow(eyebrow, color: AppColors.violet200),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: (big
                          ? Theme.of(context).textTheme.displayLarge
                          : Theme.of(context).textTheme.displayMedium)
                      ?.copyWith(color: AppColors.white),
                ),
                if (body != null) ...[
                  const SizedBox(height: 14),
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

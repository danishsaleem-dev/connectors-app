import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// The one shared "entrance" background — Splash, Welcome, and the
/// Login/Signup shell all continue the same branded moment, so the
/// gradient recipe lives in one place instead of being copied three
/// times. A layered gradient (an unevenly-stopped diagonal wash plus two
/// soft off-canvas radial glows) reads as considered rather than the flat
/// single-diagonal wash it replaced, while staying entirely inside the
/// brand's existing violet/ink palette — no new hues introduced just to
/// look "modern."
class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.violet950,
            AppColors.violet700,
            AppColors.violet600,
            AppColors.ink,
          ],
          stops: [0, 0.35, 0.64, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: Align(
              alignment: const Alignment(1.25, -1.2),
              child: Container(
                width: 420,
                height: 420,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.violet400.withValues(alpha: 0.32),
                      AppColors.violet400.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: const Alignment(-1.2, 1.3),
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.ink.withValues(alpha: 0.6),
                      AppColors.ink.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// A light-toned counterpart to [GradientBackground] — same layered-wash
/// idea (diagonal base plus two soft off-canvas glows), but built from the
/// palette's lightest tokens so dark text/icons stay legible on it. For
/// screens that want a bit of depth behind them without adopting the dark,
/// white-text "entrance" look Splash/Welcome/AuthShell share — Onboarding's
/// four welcome slides being the first case, currently flat white.
class LightGradientBackground extends StatelessWidget {
  final Widget child;

  const LightGradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.white, AppColors.violet50, AppColors.white],
          stops: [0, 0.55, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          IgnorePointer(
            child: Align(
              alignment: const Alignment(1.2, -1.1),
              child: Container(
                width: 380,
                height: 380,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.violet200.withValues(alpha: 0.5),
                      AppColors.violet200.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          IgnorePointer(
            child: Align(
              alignment: const Alignment(-1.3, 1.2),
              child: Container(
                width: 340,
                height: 340,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.violet400.withValues(alpha: 0.14),
                      AppColors.violet400.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

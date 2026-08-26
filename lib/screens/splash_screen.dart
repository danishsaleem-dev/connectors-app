import 'package:flutter/material.dart';
import '../data/site_data.dart';
import '../theme/colors.dart';
import '../widgets/gradient_background.dart';
import '../widgets/orbit_field.dart';

/// The very first thing shown, while AppRoot checks a stored session
/// against the server. Same layered gradient as WelcomeScreen/AuthShell —
/// this is a continuation of that one branded moment, not a second one.
/// The orbit mark is centered and much more visible here (it's the entire
/// point of the screen) and spins fast enough — 12s a turn, versus the 90s
/// ambient drift used everywhere else it appears — to actually read as
/// motion over a splash-length view. The small spinner below is what
/// signals "loading."
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 5),
              const SizedBox(
                width: 120,
                height: 120,
                child: OrbitField(
                  color: AppColors.white,
                  count: 22,
                  duration: Duration(seconds: 12),
                ),
              ),
              const SizedBox(height: 28),
              Text(
                SiteData.name.toUpperCase(),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                SiteData.tagline,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.white.withValues(alpha: 0.68),
                    ),
              ),
              const Spacer(flex: 4),
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

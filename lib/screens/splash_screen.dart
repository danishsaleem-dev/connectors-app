import 'package:flutter/material.dart';
import '../data/site_data.dart';
import '../theme/colors.dart';
import '../widgets/orbit_field.dart';

/// The very first thing shown, while AppRoot checks a stored session
/// against the server. Same violet gradient as WelcomeScreen — this is a
/// continuation of that one branded moment, not a second one — but the
/// orbit mark is centered and much more visible here (it's the entire
/// point of the screen), and static rather than animated: its rotation is
/// a deliberate 90 seconds per turn, so over a 1-2 second splash it
/// wouldn't read as motion anyway. The small spinner below is what
/// actually signals "loading."
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.violet900, AppColors.violet700, AppColors.ink],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 5),
              const SizedBox(
                width: 120,
                height: 120,
                child: OrbitField(color: AppColors.white, count: 22, animate: false),
              ),
              const SizedBox(height: 28),
              Text(
                SiteData.name.toUpperCase(),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.white,
                      letterSpacing: 4,
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

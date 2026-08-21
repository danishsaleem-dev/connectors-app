import 'package:flutter/material.dart';
import '../data/site_data.dart';
import '../theme/colors.dart';
import '../widgets/orbit_field.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

/// The app's front door — shown whenever there's no signed-in session
/// (first launch, or a stored one that turned out to be expired). Own
/// branding and colours, not the reference PDF's: full-bleed gradient is a
/// deliberate one-off here, the app's single moment to make an entrance,
/// distinct from every screen after it which stays white with violet as an
/// accent only.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

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
        child: Stack(
          children: [
            Positioned(
              right: -80,
              top: -60,
              child: IgnorePointer(
                child: SizedBox(
                  width: 320,
                  height: 320,
                  child: OrbitField(
                    color: AppColors.white.withValues(alpha: 0.07),
                    count: 22,
                    animate: false,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      SiteData.name.toUpperCase(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppColors.white,
                            letterSpacing: 3,
                          ),
                    ),
                    const Spacer(flex: 3),
                    Text(
                      SiteData.tagline,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: AppColors.white,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      SiteData.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.white.withValues(alpha: 0.72),
                          ),
                    ),
                    const Spacer(flex: 4),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.violet700,
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                        child: const Text('Sign in'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.white,
                          side: const BorderSide(color: AppColors.white, width: 1.4),
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignupScreen()),
                        ),
                        child: const Text('Create an account'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

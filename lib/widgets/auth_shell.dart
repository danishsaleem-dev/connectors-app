import 'package:flutter/material.dart';
import '../data/site_data.dart';
import '../theme/colors.dart';
import 'orbit_field.dart';

/// Shared chrome for Login and Signup — the same violet gradient entrance
/// as WelcomeScreen/SplashScreen, continued rather than dropped back to a
/// plain white AppBar screen once the visitor taps through. Both screens
/// bring their own headline and form; this owns the background, the back
/// control (there's no AppBar here to supply one), and the brand mark.
class AuthShell extends StatelessWidget {
  final Widget child;

  const AuthShell({super.key, required this.child});

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
              right: -100,
              top: -80,
              child: IgnorePointer(
                child: SizedBox(
                  width: 300,
                  height: 300,
                  child: OrbitField(
                    color: AppColors.white.withValues(alpha: 0.06),
                    count: 22,
                    animate: false,
                  ),
                ),
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Material(
                          color: AppColors.white.withValues(alpha: 0.1),
                          shape: const CircleBorder(),
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: () => Navigator.of(context).pop(),
                            child: const Padding(
                              padding: EdgeInsets.all(10),
                              child: Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        SizedBox(
                          width: 26,
                          height: 26,
                          child: OrbitField(
                            color: AppColors.white,
                            count: 16,
                            duration: const Duration(seconds: 24),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          SiteData.name.toUpperCase(),
                          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.white,
                                letterSpacing: 1.4,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    child,
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

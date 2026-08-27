import 'package:flutter/material.dart';
import '../data/site_data.dart';
import '../theme/colors.dart';
import '../widgets/gradient_background.dart';
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
      body: GradientBackground(
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
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(28, 24, 28, 32),
                  // Content is pinned top/bottom with Spacers between on any
                  // screen tall enough to fit it (matching every design
                  // reference); ConstrainedBox + IntrinsicHeight lets it
                  // fall back to scrolling instead of overflowing on a
                  // short device now that the CTA block has grown (search +
                  // alt sign-in row + sign-up link, versus just two
                  // buttons before).
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 56,
                    ),
                    child: IntrinsicHeight(
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
                      "Let's Get Started",
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w800,
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
                          backgroundColor: AppColors.ink,
                          foregroundColor: AppColors.white,
                        ),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LoginScreen()),
                        ),
                        child: const Text('Sign In'),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Row(
                      children: [
                        Expanded(child: Divider(color: AppColors.white.withValues(alpha: 0.24))),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'OR SIGN IN WITH',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.55),
                                  letterSpacing: 1.2,
                                ),
                          ),
                        ),
                        Expanded(child: Divider(color: AppColors.white.withValues(alpha: 0.24))),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _AltSignInButton(icon: Icons.mail_outline_rounded, context: context),
                        const SizedBox(width: 16),
                        _AltSignInButton(icon: Icons.smartphone_rounded, context: context),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignupScreen()),
                        ),
                        child: Text.rich(
                          TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppColors.white.withValues(alpha: 0.68),
                                ),
                            children: [
                              const TextSpan(text: "Didn't have an account?  "),
                              TextSpan(
                                text: 'Sign up now',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// UI-only for now — the app has one sign-in method (email + password), so
/// these don't gate any real alt-auth flow yet. A tap says so rather than
/// doing nothing, so it reads as "not built yet" instead of "broken."
class _AltSignInButton extends StatelessWidget {
  final IconData icon;
  final BuildContext context;

  const _AltSignInButton({required this.icon, required this.context});

  @override
  Widget build(BuildContext _) {
    return Material(
      color: AppColors.white.withValues(alpha: 0.08),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Coming soon')),
        ),
        child: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.white.withValues(alpha: 0.3)),
          ),
          child: Icon(icon, color: AppColors.white, size: 22),
        ),
      ),
    );
  }
}

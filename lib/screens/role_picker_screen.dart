import 'package:flutter/material.dart';
import '../data/auth_result.dart';
import '../data/auth_state.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/feature_card.dart';
import '../widgets/orbit_field.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'signup_screen.dart';

/// TEMPORARY — replaces real login for this preview build so every role's
/// screens can be checked without a real account for each one, or signing
/// in/out repeatedly. Sign-in is entirely fake: no network call, nothing
/// persisted (Auth.signIn(..., persist: false)), so it never touches the
/// real API and a restart lands back on Welcome. To restore real login,
/// point WelcomeScreen's "Sign In" button back at LoginScreen — that
/// screen is untouched and still fully works.
class RolePickerScreen extends StatelessWidget {
  const RolePickerScreen({super.key});

  void _enterAs(BuildContext context, _Role role) {
    Auth.signIn(
      AuthResult(
        name: 'Preview User',
        isAdmin: false,
        sessionToken: 'demo-${role.orgType}',
        orgType: role.orgType,
        orgName: 'Preview ${role.label}',
      ),
      persist: false,
    );
    // AppRoot is listening to Auth.session and has already rebuilt to the
    // signed-in app shell underneath this screen — popping back to it is
    // all that's left to do, same as the real login/signup screens do.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          children: [
            SizedBox(
              width: 44,
              height: 44,
              child: OrbitField(
                color: AppColors.violet600,
                count: 18,
                duration: const Duration(seconds: 40),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Preview as…',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Pick a role to explore its screens — no account needed for '
              'this preview build.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: 26),
            for (var i = 0; i < _roles.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              FeatureCard(
                title: _roles[i].label,
                body: _roles[i].description,
                onTap: () => _enterAs(context, _roles[i]),
              ),
            ],
            const SizedBox(height: AppSpacing.section),
            Text(
              'SEE THE REAL SCREENS',
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: AppColors.grey500, letterSpacing: 1.1),
            ),
            const SizedBox(height: 4),
            Text(
              "These are the screens a real user gets. They're fully "
              "designed — they just aren't in the preview path above.",
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              radius: 16,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  _LinkRow(
                    icon: Icons.login_rounded,
                    title: 'Login screen',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                  ),
                  const Divider(height: 1),
                  _LinkRow(
                    icon: Icons.person_add_alt_rounded,
                    title: 'Sign up screen',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SignupScreen()),
                    ),
                  ),
                  const Divider(height: 1),
                  _LinkRow(
                    icon: Icons.view_carousel_outlined,
                    title: 'Onboarding screens',
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (routeContext) => OnboardingScreen(
                          onGetStarted: () => Navigator.of(routeContext).pop(),
                          onLogin: () => Navigator.of(routeContext).pop(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _LinkRow({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.violet600),
            const SizedBox(width: AppSpacing.lg),
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
            const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.grey300),
          ],
        ),
      ),
    );
  }
}

class _Role {
  final String orgType;
  final String label;
  final String description;

  const _Role({required this.orgType, required this.label, required this.description});
}

const _roles = [
  _Role(
    orgType: 'brand',
    label: 'Brand',
    description: 'Expansion, franchisees, investors, marketing & IT.',
  ),
  _Role(
    orgType: 'franchisee',
    label: 'Franchisee',
    description: 'Explore brands and apply for a franchise.',
  ),
  _Role(
    orgType: 'landlord',
    label: 'Landlord',
    description: 'Submit space and see interested brands.',
  ),
  _Role(
    orgType: 'developer',
    label: 'Mall / Developer',
    description: 'Request brand placement for your development.',
  ),
  _Role(
    orgType: 'investor',
    label: 'Investor',
    description: 'Explore and track investment opportunities.',
  ),
  _Role(
    orgType: 'vendor',
    label: 'Vendor',
    description: 'The Partners Program for vendors.',
  ),
  _Role(
    orgType: 'consultant',
    label: 'Consultant',
    description: 'The consultants roster.',
  ),
];

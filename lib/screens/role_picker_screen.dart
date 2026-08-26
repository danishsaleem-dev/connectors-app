import 'package:flutter/material.dart';
import '../data/auth_result.dart';
import '../data/auth_state.dart';
import '../theme/colors.dart';
import '../widgets/auth_shell.dart';
import '../widgets/feature_card.dart';

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
    return AuthShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview as...',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Pick a role to explore its screens — no account needed for '
            'this preview build.',
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppColors.white.withValues(alpha: 0.72)),
          ),
          const SizedBox(height: 28),
          for (var i = 0; i < _roles.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            FeatureCard(
              title: _roles[i].label,
              body: _roles[i].description,
              onTap: () => _enterAs(context, _roles[i]),
            ),
          ],
        ],
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

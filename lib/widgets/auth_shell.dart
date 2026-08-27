import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'orbit_field.dart';

/// Shared chrome for the auth screens — white, not the violet gradient it
/// used to be.
///
/// The gradient stays on Splash/Welcome/Onboarding, where it's a brand
/// moment. Auth is a form: white gives the inputs somewhere to sit, keeps
/// contrast high while typing, and makes the violet primary button the one
/// thing on screen competing for attention.
class AuthShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const AuthShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 46,
                height: 46,
                child: OrbitField(
                  color: AppColors.violet600,
                  count: 18,
                  duration: const Duration(seconds: 40),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                title,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
              ),
              const SizedBox(height: 30),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// The rounded, grey-filled input used across every auth screen.
InputDecoration authInput({
  required IconData icon,
  required String hint,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    prefixIcon: Icon(icon, color: AppColors.grey300, size: 20),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: AppColors.grey50,
    hintStyle: const TextStyle(color: AppColors.grey300),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.grey200),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.grey200),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: AppColors.violet600, width: 1.5),
    ),
  );
}

/// The "or continue with" divider plus provider buttons, shared by Login
/// and Signup. Google/Apple come from the doc's login-options list; none
/// of them are wired to a provider yet.
class AuthProviderRow extends StatelessWidget {
  final List<({IconData icon, String label, VoidCallback onTap})> providers;

  const AuthProviderRow({super.key, required this.providers});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider(color: AppColors.grey200)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or continue with',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.grey300),
              ),
            ),
            const Expanded(child: Divider(color: AppColors.grey200)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            for (var i = 0; i < providers.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.grey200, width: 1.2),
                  ),
                  onPressed: providers[i].onTap,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(providers[i].icon, size: 18, color: AppColors.ink),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          providers[i].label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge
                              ?.copyWith(color: AppColors.ink),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

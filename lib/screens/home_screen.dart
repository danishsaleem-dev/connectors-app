import 'package:flutter/material.dart';
import '../data/account_type_config.dart';
import '../data/api_client.dart';
import '../data/auth_state.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_hero.dart';
import '../widgets/enquire_cta.dart';

/// Home is personalized now, not a menu of four doors — every account is
/// exactly one type (see AccountTypeConfig), so by the time someone reaches
/// this screen the app already knows which one thing they're here to do.
/// Tapping the primary action switches to that tab (index 1) rather than
/// pushing a new route, same IndexedStack-preserves-state reasoning the
/// bottom nav already relies on.
class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenPrimaryAction;

  const HomeScreen({super.key, required this.onOpenPrimaryAction});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthResult?>(
      valueListenable: Auth.session,
      builder: (context, session, _) {
        final config = configFor(session?.orgType);
        final nameParts = session?.name.trim().split(' ') ?? const [];
        final firstName = nameParts.isNotEmpty ? nameParts.first : 'there';

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppHero(
                eyebrow: session?.orgName ?? 'Connectors',
                title: 'Welcome back, $firstName.',
                body: 'Everything about your expansion, in one place.',
              ),
              const SizedBox(height: AppSpacing.section),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _PrimaryActionCard(config: config, onTap: onOpenPrimaryAction),
                    const SizedBox(height: AppSpacing.xl),
                    const EnquireCta(message: "Need something else? Email our team."),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PrimaryActionCard extends StatelessWidget {
  final AccountTypeConfig config;
  final VoidCallback onTap;

  const _PrimaryActionCard({required this.config, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.violet600,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: cardShadow(opacity: 0.16),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(config.homeIcon, color: AppColors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      config.homeTitle,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      config.homeBody,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.white.withValues(alpha: 0.78)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

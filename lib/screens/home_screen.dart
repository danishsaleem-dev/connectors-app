import 'package:flutter/material.dart';
import '../data/account_type_config.dart';
import '../data/api_client.dart';
import '../data/auth_state.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/eyebrow.dart';
import '../widgets/reveal.dart';
import 'chat_screen.dart';

const _roleLabels = {
  'brand': 'Brand',
  'franchisee': 'Franchisee',
  'landlord': 'Landlord',
  'developer': 'Mall / Developer',
  'investor': 'Investor',
  'vendor': 'Vendor',
  'consultant': 'Consultant',
};

/// Home leads with who's signed in and what they can do — no banner, no app
/// bar branding, both removed per feedback that they were empty ceremony
/// ahead of anything useful. Just a profile row (who you are), a chat
/// entry point, and the action cards that matter for this account type.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthResult?>(
      valueListenable: Auth.session,
      builder: (context, session, _) {
        final config = configFor(session?.orgType);
        final roleLabel = session?.isAdmin == true
            ? 'Connectors team'
            : (_roleLabels[session?.orgType] ?? 'Member');

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            110,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.violet600,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      (session?.name.trim().isNotEmpty ?? false)
                          ? session!.name.trim()[0].toUpperCase()
                          : '?',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: AppColors.white),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session?.name ?? '',
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          roleLabel,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.grey500),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: AppColors.violet50,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).push(ChatScreen.route()),
                      child: const Padding(
                        padding: EdgeInsets.all(11),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.violet600,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.section),
              const Eyebrow('Get started'),
              const SizedBox(height: AppSpacing.sm),
              Text(
                config.homeActions.length > 1
                    ? 'What would you like to do?'
                    : config.homeActions.first.title,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: AppSpacing.heading),
              for (var i = 0; i < config.homeActions.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                Reveal(index: i, child: _ActionRow(action: config.homeActions[i])),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ActionRow extends StatelessWidget {
  final HomeAction action;

  const _ActionRow({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => action.hasOwnScaffold
                ? action.buildScreen()
                : Scaffold(
                    appBar: AppBar(title: Text(action.title)),
                    body: SafeArea(child: SingleChildScrollView(child: action.buildScreen())),
                  ),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: cardShadow(),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.violet50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(action.icon, color: AppColors.violet600, size: 21),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(action.title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      action.body,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.grey500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right_rounded, color: AppColors.grey300),
            ],
          ),
        ),
      ),
    );
  }
}

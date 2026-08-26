import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/api_client.dart';
import '../data/auth_state.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/feature_card.dart';
import '../widgets/info_list.dart';
import '../widgets/reveal.dart';
import 'contact_screen.dart';

/// The account tab — no session param, unlike a pushed screen would need:
/// it's only ever shown once AppRoot has already confirmed someone's signed
/// in, so it reads Auth.session directly rather than trusting whatever was
/// passed in from wherever it was reached.
class AccountBody extends StatelessWidget {
  const AccountBody({super.key});

  Future<void> _openPortal(BuildContext context) async {
    String handoffUrl;
    try {
      final handoffToken = await ApiClient.requestHandoff();
      handoffUrl = '$apiBaseUrl/portal/handoff?token=$handoffToken';
    } catch (err) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err is ApiException ? err.message : "Couldn't open the portal."),
        ),
      );
      return;
    }

    final ok = await launchUrl(Uri.parse(handoffUrl), mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open the browser. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthResult?>(
      valueListenable: Auth.session,
      builder: (context, session, _) {
        if (session == null) return const SizedBox.shrink();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.section,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Reveal(index: 0, child: _ProfileCard(session: session)),
              const SizedBox(height: AppSpacing.lg),
              Reveal(
                index: 1,
                child: FeatureCard(
                  title: 'Open the Portal',
                  body: 'Your dashboard, documents and requests, already signed in.',
                  onTap: () => _openPortal(context),
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              Reveal(
                index: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: cardShadow(opacity: 0.05),
                  ),
                  child: InfoList(
                    items: [
                      InfoItem(
                        icon: Icons.call_outlined,
                        title: 'Contact',
                        body: 'Our three offices, and how to reach them.',
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const ContactScreen()),
                        ),
                      ),
                      InfoItem(
                        icon: Icons.logout_rounded,
                        title: 'Sign out',
                        body: "You'll need to sign in again next time.",
                        onTap: Auth.signOut,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A premium identity moment for a screen that's otherwise all utility —
/// the same violet-gradient language as Home's promo banner, but built
/// around who's signed in rather than what they can do.
class _ProfileCard extends StatelessWidget {
  final AuthResult session;

  const _ProfileCard({required this.session});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.violet700, AppColors.violet600],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.white, shape: BoxShape.circle),
            child: Text(
              session.name.trim().isEmpty ? '?' : session.name.trim()[0].toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: AppColors.violet600),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 3),
                Text(
                  session.orgName ?? (session.isAdmin ? 'Connectors team' : 'Signed in'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.white.withValues(alpha: 0.78)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

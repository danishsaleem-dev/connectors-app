import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/api_client.dart';
import '../data/auth_state.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/feature_card.dart';
import '../widgets/info_list.dart';
import '../widgets/reveal.dart';
import 'analytics_screen.dart';
import 'contact_screen.dart';
import 'edit_profile_screen.dart';
import 'locations_screen.dart';
import 'settings_screen.dart';
import 'verification_screen.dart';

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
          content: Text(
            err is ApiException ? err.message : "Couldn't open the portal.",
          ),
        ),
      );
      return;
    }

    final ok = await launchUrl(
      Uri.parse(handoffUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Couldn't open the browser. Please try again."),
        ),
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
                  body:
                      'Your dashboard, documents and requests, already signed in.',
                  onTap: () => _openPortal(context),
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              const _GroupLabel('Your account'),
              Reveal(
                index: 2,
                child: _MenuCard(
                  items: [
                    InfoItem(
                      icon: Icons.person_outline_rounded,
                      title: 'Edit profile',
                      body: 'Your name, company and contact details.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(session: session),
                        ),
                      ),
                    ),
                    // Saving is a location thing, and only brand accounts
                    // ever see a location to save one — same gate as the
                    // Opportunities tab's own Locations category.
                    if (session.orgType == 'brand')
                      InfoItem(
                        icon: Icons.bookmark_border_rounded,
                        title: 'Saved',
                        body: "Listings you've shortlisted.",
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LocationsScreen(
                              appBarTitle: 'Saved',
                              fetch: ApiClient.fetchFavorites,
                              emptyMessage:
                                  'Nothing saved yet — tap the heart on a listing to save it here.',
                            ),
                          ),
                        ),
                      ),
                    InfoItem(
                      icon: Icons.verified_user_outlined,
                      title: 'Verification',
                      body: 'Verify your business to build trust.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const VerificationScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _GroupLabel('Growth'),
              Reveal(
                index: 3,
                child: _MenuCard(
                  items: [
                    InfoItem(
                      icon: Icons.insights_outlined,
                      title: 'Analytics',
                      body: 'Your messages and saved-listing activity.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AnalyticsScreen(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const _GroupLabel('Support'),
              Reveal(
                index: 4,
                child: _MenuCard(
                  items: [
                    InfoItem(
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      body: 'Notifications and preferences.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SettingsScreen(),
                        ),
                      ),
                    ),
                    InfoItem(
                      icon: Icons.call_outlined,
                      title: 'Contact',
                      body: 'Our three offices, and how to reach them.',
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ContactScreen(),
                        ),
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
            ],
          ),
        );
      },
    );
  }
}

class _GroupLabel extends StatelessWidget {
  final String text;

  const _GroupLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.grey500,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final List<InfoItem> items;

  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: InfoList(items: items),
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
            decoration: const BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              session.name.trim().isEmpty
                  ? '?'
                  : session.name.trim()[0].toUpperCase(),
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(color: AppColors.violet600),
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
                  style: Theme.of(
                    context,
                  ).textTheme.headlineMedium?.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 3),
                Text(
                  session.orgName ??
                      (session.isAdmin ? 'Connectors team' : 'Signed in'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.white.withValues(alpha: 0.78),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

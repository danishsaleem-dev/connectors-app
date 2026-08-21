import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/api_client.dart';
import '../data/auth_state.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/info_list.dart';

/// The account tab — no session param, unlike the AccountScreen wrapper
/// below: it's only ever shown once AppRoot has already confirmed someone's
/// signed in, so it reads Auth.session directly rather than trusting
/// whatever was passed in from wherever it was reached.
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
            AppSpacing.sm,
            AppSpacing.page,
            AppSpacing.section,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.violet600,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      session.name.trim().isEmpty ? '?' : session.name.trim()[0].toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: AppColors.white),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(session.name, style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 2),
                        Text(
                          session.orgName ??
                              (session.isAdmin ? 'Connectors team' : 'Signed in'),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.grey500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Your dashboard, documents and requests live on the '
                'Connectors portal — this opens it in your browser, already '
                'signed in.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _openPortal(context),
                  child: const Text('Open the portal'),
                ),
              ),
              const SizedBox(height: AppSpacing.section),
              InfoList(
                items: [
                  InfoItem(
                    icon: Icons.logout_rounded,
                    title: 'Sign out',
                    body: "You'll need to sign in again next time.",
                    onTap: Auth.signOut,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Thin Scaffold wrapper — nothing currently pushes this as its own route
/// (Account is a nav tab now), kept for the same cheap-optionality reason
/// as MoreScreen's wrapper.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: const SafeArea(child: AccountBody()),
    );
  }
}

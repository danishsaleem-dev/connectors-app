import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/api_client.dart';
import '../data/auth_state.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/info_list.dart';

/// Where the app bar's person icon goes once someone is signed in, in place
/// of the login screen. There's no in-app dashboard by design, so this is a
/// short account card plus the handoff into the real portal.
class AccountScreen extends StatelessWidget {
  final AuthResult session;

  const AccountScreen({super.key, required this.session});

  Future<void> _openPortal(BuildContext context) async {
    final ok = await launchUrl(
      Uri.parse(session.handoffUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open the browser. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: SafeArea(
        child: SingleChildScrollView(
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
                          session.isAdmin ? 'Connectors team' : 'Signed in',
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
                    body: 'You can sign back in at any time.',
                    onTap: () {
                      Auth.signOut();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

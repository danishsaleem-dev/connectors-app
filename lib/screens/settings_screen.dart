import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/auth_result.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_card.dart';

/// Preferences the business-logic doc implies (push notifications, email
/// updates) plus the standard legal/about rows every app needs.
///
/// The switches hold real local state so the screen behaves correctly when
/// you tap them, but nothing is persisted and no preference is wired to a
/// backend — there's no notification infrastructure to configure yet.
/// Privacy policy opens the real page now that one exists; Terms of
/// service still has no destination — there's genuinely no policy written
/// yet, so it stays honest rather than linking to something that doesn't
/// exist.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _push = true;
  bool _email = true;
  bool _newOpportunities = true;
  bool _productUpdates = false;

  void _notWired() => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Coming soon')),
      );

  Future<void> _openPrivacyPolicy() async {
    final ok = await launchUrl(
      Uri.parse('$apiBaseUrl/privacy'),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open the browser. Please try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.section,
          ),
          children: [
            const _SectionLabel('Notifications'),
            AppCard(
              radius: 16,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
              child: Column(
                children: [
                  _SwitchRow(
                    title: 'Push notifications',
                    body: 'Alerts on this device.',
                    value: _push,
                    onChanged: (v) => setState(() => _push = v),
                  ),
                  const Divider(height: 1),
                  _SwitchRow(
                    title: 'Email updates',
                    body: 'Summaries and replies by email.',
                    value: _email,
                    onChanged: (v) => setState(() => _email = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _SectionLabel('What to notify me about'),
            AppCard(
              radius: 16,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
              child: Column(
                children: [
                  _SwitchRow(
                    title: 'New opportunities',
                    body: 'Listings matching your criteria.',
                    value: _newOpportunities,
                    onChanged: (v) => setState(() => _newOpportunities = v),
                  ),
                  const Divider(height: 1),
                  _SwitchRow(
                    title: 'Product updates',
                    body: 'New features and announcements.',
                    value: _productUpdates,
                    onChanged: (v) => setState(() => _productUpdates = v),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _SectionLabel('About'),
            AppCard(
              radius: 16,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  _LinkRow(title: 'Privacy policy', onTap: _openPrivacyPolicy),
                  const Divider(height: 1),
                  _LinkRow(title: 'Terms of service', onTap: _notWired),
                  const Divider(height: 1),
                  const _LinkRow(title: 'App version', trailingText: '1.0.0'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context)
            .textTheme
            .labelMedium
            ?.copyWith(color: AppColors.grey500, letterSpacing: 1.1),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final String title;
  final String body;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.title,
    required this.body,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.grey500),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.violet600,
          ),
        ],
      ),
    );
  }
}

class _LinkRow extends StatelessWidget {
  final String title;
  final String? trailingText;
  final VoidCallback? onTap;

  const _LinkRow({required this.title, this.trailingText, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Row(
          children: [
            Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
            if (trailingText != null)
              Text(
                trailingText!,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.grey500),
              )
            else
              const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.grey300),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../data/profile_fields.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/profile_field_input.dart';

/// Editing the account's own details — the same field definitions and the
/// same [ProfileDraft] the completion flow uses, so whichever route
/// someone takes to fill these in, it's one save path, not two that can
/// drift apart. Organization name/phone/country are in here too (as the
/// completion flow's own first step), not as a separate name field —
/// there's no backend for renaming the *user* (display name comes from
/// the account itself, not something either surface lets you change), so
/// this only offers to edit what's actually saveable.
class EditProfileScreen extends StatefulWidget {
  final AuthResult session;

  const EditProfileScreen({super.key, required this.session});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    final values = Map<String, Object>.from(ProfileDraft.values.value);
    final organizationName = values.remove('organizationName') as String?;
    final phone = values.remove('phone') as String?;
    final country = values.remove('country') as String?;
    try {
      await ApiClient.saveProfile(
        organizationName: organizationName,
        phone: phone,
        country: country,
        fields: values,
      );
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved.')),
      );
    } catch (err) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err is ApiException ? err.message : "Couldn't save. Please try again."),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.section,
          ),
          children: [
            Center(
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.violet600,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      widget.session.name.trim().isEmpty
                          ? '?'
                          : widget.session.name.trim()[0].toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(color: AppColors.white),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(widget.session.name, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
            // The doc's per-role required information, rendered from the
            // same definitions the completion flow uses — so whichever
            // route someone takes to fill these in, it's one field list
            // and one draft, not two that can drift apart.
            for (final step in profileStepsFor(widget.session.orgType)) ...[
              const SizedBox(height: AppSpacing.xl),
              Text(step.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              AppCard(
                radius: 16,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    for (var i = 0; i < step.fields.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.lg),
                      ProfileFieldInput(field: step.fields[i]),
                    ],
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                      )
                    : const Text('Save changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

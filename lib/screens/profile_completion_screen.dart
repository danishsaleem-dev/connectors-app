import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../data/auth_state.dart';
import '../data/profile_fields.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/profile_field_input.dart';

/// The doc's profile-creation flow, as short themed steps rather than one
/// long form.
///
/// Every step is skippable and the whole thing is exitable — the account
/// already works without this, and blocking someone out of the app until
/// they've filled eleven fields is how a signup becomes an abandoned
/// signup. Progress is kept in [ProfileDraft] (in memory, seeded from the
/// server on sign-in — see AppShell), and saved back to
/// ApiClient.saveProfile on every step advance, on Skip, and on Finish —
/// so leaving halfway and coming back keeps what was entered on the
/// server, not just in this session.
class ProfileCompletionScreen extends StatefulWidget {
  final String? orgType;

  const ProfileCompletionScreen({super.key, required this.orgType});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _pageController = PageController();
  int _index = 0;
  bool _saving = false;

  late final List<ProfileStep> _steps = profileStepsFor(widget.orgType);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _steps.length - 1;

  /// organizationName/phone/country live on the organization itself, not
  /// the per-type profile table — split out of the flat draft here rather
  /// than in ProfileDraft, which stays a plain field-key map for every
  /// other purpose (completion count, seeding, Edit Profile).
  Future<void> _persist({required bool complete}) {
    final values = Map<String, Object>.from(ProfileDraft.values.value);
    final organizationName = values.remove('organizationName') as String?;
    final phone = values.remove('phone') as String?;
    final country = values.remove('country') as String?;
    return ApiClient.saveProfile(
      organizationName: organizationName,
      phone: phone,
      country: country,
      fields: values,
      complete: complete,
    );
  }

  void _skip() {
    _persist(complete: false).catchError((_) {});
    Navigator.of(context).pop();
  }

  Future<void> _next() async {
    if (_isLast) {
      await _finish();
      return;
    }
    _persist(complete: false).catchError((_) {});
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      await _persist(complete: true);
      if (!mounted) return;
      if (Auth.session.value != null) {
        Auth.session.value = Auth.session.value!.copyWith(onboardingCompletedAt: DateTime.now());
      }
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile saved.')),
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
      appBar: AppBar(
        title: Text('Step ${_index + 1} of ${_steps.length}'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _skip,
            child: Text(
              'Skip',
              style: Theme.of(context)
                  .textTheme
                  .labelLarge
                  ?.copyWith(color: AppColors.grey500),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
              child: Row(
                children: [
                  for (var i = 0; i < _steps.length; i++) ...[
                    if (i > 0) const SizedBox(width: 4),
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: i <= _index ? AppColors.violet600 : AppColors.grey200,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: _steps.length,
                itemBuilder: (context, i) => _StepPage(step: _steps[i]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.md,
                AppSpacing.page,
                AppSpacing.lg,
              ),
              child: Row(
                children: [
                  if (_index > 0) ...[
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saving ? null : _next,
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white),
                            )
                          : Text(_isLast ? 'Finish' : 'Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepPage extends StatelessWidget {
  final ProfileStep step;

  const _StepPage({required this.step});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        AppSpacing.xl,
        AppSpacing.page,
        AppSpacing.xl,
      ),
      children: [
        Text(step.title, style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 6),
        Text(
          step.subtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
        ),
        const SizedBox(height: AppSpacing.xl),
        for (var i = 0; i < step.fields.length; i++) ...[
          if (i > 0) const SizedBox(height: AppSpacing.lg),
          ProfileFieldInput(field: step.fields[i]),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
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
/// signup. Progress is kept in [ProfileDraft] (in memory), so leaving
/// halfway and coming back from Home or Edit Profile keeps what was
/// entered.
class ProfileCompletionScreen extends StatefulWidget {
  final String? orgType;

  const ProfileCompletionScreen({super.key, required this.orgType});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _pageController = PageController();
  int _index = 0;

  late final List<ProfileStep> _steps = profileStepsFor(widget.orgType);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isLast => _index == _steps.length - 1;

  void _next() {
    if (_isLast) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved for this session — syncing is coming soon')),
      );
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Complete profile')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Text(
              "There's nothing extra to collect for this account type yet.",
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.grey500),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_index + 1} of ${_steps.length}'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
                      onPressed: _next,
                      child: Text(_isLast ? 'Finish' : 'Continue'),
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

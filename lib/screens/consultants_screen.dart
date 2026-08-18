import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/enquire_cta.dart';
import '../widgets/info_list.dart';
import '../widgets/process_steps.dart';
import '../widgets/section_intro.dart';
import '../widgets/signed_out_only.dart';
import 'signup_screen.dart';

const _audiences = [
  InfoItem(
    icon: Icons.storefront_rounded,
    title: 'Brands',
    body: 'Market entry, site selection and franchise structuring for your next opening.',
  ),
  InfoItem(
    icon: Icons.handshake_rounded,
    title: 'Franchisees',
    body: 'Feasibility and operational planning before you commit capital to a territory.',
  ),
  InfoItem(
    icon: Icons.apartment_rounded,
    title: 'Landlords',
    body: 'Positioning a space, and reading which brands it will actually attract.',
  ),
];

const _steps = [
  ProcessStep(
    title: 'Tell us what you need',
    body: 'A short brief on your expansion, site or challenge.',
  ),
  ProcessStep(
    title: 'We match the right consultant',
    body: 'From our in-house team, based on your industry and stage.',
  ),
  ProcessStep(
    title: 'Start the engagement',
    body: 'Direct access and real recommendations — no lengthy procurement process.',
  ),
];

/// Connectors' own in-house consultancy — not the Partners Program. This
/// screen is deliberately static (no live roster): browsing individual
/// consultant profiles needs a public API the website doesn't expose yet,
/// so for now the app explains the service and routes both directions —
/// hire one, or join the roster.
class ConsultantsScreen extends StatelessWidget {
  const ConsultantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultants')),
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
              Text(
                'Advice from people who do this for a living.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Site selection, feasibility and franchise structuring — '
                "Connectors' own consultancy, available whether or not "
                "you're already working with us on an expansion.",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
              ),
              const SizedBox(height: AppSpacing.section),
              const SectionIntro(eyebrow: 'Who we help', title: 'Wherever you sit in the deal.'),
              const SizedBox(height: AppSpacing.sm),
              const InfoList(items: _audiences),
              const SizedBox(height: AppSpacing.section),
              const SectionIntro(eyebrow: 'How it works', title: 'Three steps to an engagement.'),
              const SizedBox(height: AppSpacing.heading),
              const ProcessSteps(steps: _steps),
              const SizedBox(height: AppSpacing.section),
              SignedOutOnly(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SignupScreen(initialType: 'consultant'),
                        ),
                      ),
                      child: const Text('Join the consultants roster'),
                    ),
                  ),
                ),
              ),
              const EnquireCta(message: 'Need a consultant? Email our team.'),
            ],
          ),
        ),
      ),
    );
  }
}

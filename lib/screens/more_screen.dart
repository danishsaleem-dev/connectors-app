import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/info_list.dart';
import '../widgets/section_intro.dart';
import 'about_screen.dart';
import 'consultants_screen.dart';
import 'login_screen.dart';
import 'partners_screen.dart';
import 'services_screen.dart';
import 'vendor_services_screen.dart';

/// Everything that isn't one of the five primary tabs — a sixth bottom-nav
/// item would crowd the bar, so secondary destinations live behind one
/// "Menu" icon in the app bar instead, same idiom as Uber/Airbnb's "More"
/// tab.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
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
              const SectionIntro(eyebrow: 'Explore', title: 'Everything about Connectors.'),
              const SizedBox(height: AppSpacing.sm),
              InfoList(
                items: [
                  InfoItem(
                    icon: Icons.info_outline_rounded,
                    title: 'About Connectors',
                    body: 'Our story, mission and values.',
                    onTap: () => _push(context, const AboutScreen()),
                  ),
                  InfoItem(
                    icon: Icons.hub_outlined,
                    title: 'Our Services',
                    body: 'Seven divisions, one ecosystem.',
                    onTap: () => _push(context, const ServicesScreen()),
                  ),
                  InfoItem(
                    icon: Icons.groups_outlined,
                    title: 'Consultants',
                    body: 'In-house advisory for your expansion.',
                    onTap: () => _push(context, const ConsultantsScreen()),
                  ),
                  InfoItem(
                    icon: Icons.diversity_3_outlined,
                    title: 'Partners Program',
                    body: 'Designers, architects, agencies and more.',
                    onTap: () => _push(context, const PartnersScreen()),
                  ),
                  InfoItem(
                    icon: Icons.design_services_outlined,
                    title: 'Vendor Services',
                    body: 'Every discipline an opening needs.',
                    onTap: () => _push(context, const VendorServicesScreen()),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.section),
              _AccountCard(onTap: () => _push(context, const LoginScreen())),
            ],
          ),
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

/// The one card on the screen — it's the only action here, as opposed to a
/// destination, so it's worth letting it look different from the list.
class _AccountCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AccountCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.violet50,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(color: AppColors.violet600, shape: BoxShape.circle),
                child: const Icon(Icons.person_outline_rounded, color: AppColors.white, size: 20),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sign in', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      'Or create an account.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: AppColors.violet600, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

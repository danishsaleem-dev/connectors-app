import 'package:flutter/material.dart';
import '../theme/spacing.dart';
import '../widgets/info_list.dart';
import '../widgets/section_intro.dart';
import 'about_screen.dart';
import 'consultants_screen.dart';
import 'contact_screen.dart';
import 'partners_screen.dart';
import 'services_screen.dart';
import 'vendor_services_screen.dart';

/// Everything that isn't Home, the account-type's primary action, or
/// Account — a plain content list, dropped straight into the app shell's
/// IndexedStack as its own tab (no Scaffold/AppBar here; the shell provides
/// one). MoreScreen below is the same content wrapped for when something —
/// currently nothing does, but the option stays cheap — needs to push it as
/// its own route instead.
class MoreBody extends StatelessWidget {
  const MoreBody({super.key});

  @override
  Widget build(BuildContext context) {
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
              InfoItem(
                icon: Icons.call_outlined,
                title: 'Contact',
                body: 'Our three offices, and how to reach them.',
                onTap: () => _push(context, const ContactScreen()),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: const SafeArea(child: MoreBody()),
    );
  }
}

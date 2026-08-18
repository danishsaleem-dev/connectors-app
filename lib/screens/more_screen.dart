import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../widgets/section_intro.dart';
import '../widgets/tile_grid.dart';
import 'about_screen.dart';
import 'consultants_screen.dart';
import 'login_screen.dart';
import 'partners_screen.dart';
import 'services_screen.dart';
import 'vendor_services_screen.dart';

/// Everything that isn't one of the five primary tabs — a sixth bottom-nav
/// item would crowd the bar, so secondary destinations live behind one
/// "Menu" icon in the app bar instead, same idiom as Uber/Airbnb's "More"
/// tab. A tile grid + one featured account card, not a settings-style list.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final destinations = [
      TileItem(
        icon: Icons.info_outline_rounded,
        title: 'About Connectors',
        body: 'Our story, mission and values.',
        onTap: () => _push(context, const AboutScreen()),
      ),
      TileItem(
        icon: Icons.hub_outlined,
        title: 'Our Services',
        body: 'Seven divisions, one ecosystem.',
        onTap: () => _push(context, const ServicesScreen()),
      ),
      TileItem(
        icon: Icons.groups_outlined,
        title: 'Consultants',
        body: 'In-house advisory for your expansion.',
        onTap: () => _push(context, const ConsultantsScreen()),
      ),
      TileItem(
        icon: Icons.diversity_3_outlined,
        title: 'Partners Program',
        body: 'Designers, architects, agencies & more.',
        onTap: () => _push(context, const PartnersScreen()),
      ),
      TileItem(
        icon: Icons.design_services_outlined,
        title: 'Vendor Services',
        body: 'Every discipline an opening needs.',
        onTap: () => _push(context, const VendorServicesScreen()),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Menu')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionIntro(eyebrow: 'Explore', title: 'Everything about Connectors.'),
              const SizedBox(height: 20),
              TileGrid(items: destinations),
              const SizedBox(height: 28),
              const Divider(),
              const SizedBox(height: 20),
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
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: AppColors.violet600, shape: BoxShape.circle),
                child: const Icon(Icons.account_circle_rounded, color: AppColors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Sign in or create an account', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      'Manage your enquiries and profile.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: AppColors.violet600),
            ],
          ),
        ),
      ),
    );
  }
}

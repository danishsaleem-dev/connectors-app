import 'package:flutter/material.dart';
import '../theme/colors.dart';
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
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 8),
          children: [
            _Row(
              icon: Icons.info_outline_rounded,
              title: 'About Connectors',
              onTap: () => _push(context, const AboutScreen()),
            ),
            _Row(
              icon: Icons.hub_outlined,
              title: 'Our Services',
              subtitle: 'Seven divisions, one ecosystem',
              onTap: () => _push(context, const ServicesScreen()),
            ),
            _Row(
              icon: Icons.groups_outlined,
              title: 'Consultants',
              subtitle: 'In-house advisory for your expansion',
              onTap: () => _push(context, const ConsultantsScreen()),
            ),
            _Row(
              icon: Icons.diversity_3_outlined,
              title: 'Partners Program',
              subtitle: 'Designers, architects, agencies & more',
              onTap: () => _push(context, const PartnersScreen()),
            ),
            _Row(
              icon: Icons.design_services_outlined,
              title: 'Vendor Services',
              subtitle: 'Every discipline an opening needs',
              onTap: () => _push(context, const VendorServicesScreen()),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
              child: Divider(),
            ),
            _Row(
              icon: Icons.account_circle_outlined,
              title: 'Sign in or create an account',
              onTap: () => _push(context, const LoginScreen()),
            ),
          ],
        ),
      ),
    );
  }

  void _push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _Row({required this.icon, required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.violet50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.violet600, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleLarge),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.grey300),
          ],
        ),
      ),
    );
  }
}

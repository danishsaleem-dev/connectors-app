import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/site_data.dart';
import '../theme/colors.dart';
import 'eyebrow.dart';
import 'reveal.dart';

/// Real office contact details — the same three offices the website footer
/// lists, tappable to call. Nothing invented: no address the site doesn't
/// already publish.
class OfficesSection extends StatelessWidget {
  const OfficesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Eyebrow('Get in touch'),
          const SizedBox(height: 10),
          Text('Three offices, one team.', style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 20),
          for (var i = 0; i < SiteData.offices.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Reveal(index: i, child: _OfficeCard(office: SiteData.offices[i])),
          ],
        ],
      ),
    );
  }
}

class _OfficeCard extends StatelessWidget {
  final Office office;

  const _OfficeCard({required this.office});

  Future<void> _openDirections() async {
    final query = Uri.encodeComponent(office.address);
    await launchUrl(Uri.parse('https://www.google.com/maps/search/?api=1&query=$query'));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  office.label,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(color: AppColors.violet600, letterSpacing: 1),
                ),
                const SizedBox(height: 6),
                Text(office.address, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _CircleAction(
            icon: Icons.directions_rounded,
            onTap: _openDirections,
            outlined: true,
          ),
          const SizedBox(width: 8),
          _CircleAction(
            icon: Icons.call_rounded,
            onTap: () => launchUrl(Uri.parse(office.phoneHref)),
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool outlined;

  const _CircleAction({required this.icon, required this.onTap, this.outlined = false});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: outlined ? AppColors.white : AppColors.violet600,
      shape: CircleBorder(
        side: outlined ? const BorderSide(color: AppColors.grey200) : BorderSide.none,
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(
            icon,
            color: outlined ? AppColors.violet600 : AppColors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

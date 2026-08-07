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
          const SizedBox(width: 12),
          Material(
            color: AppColors.violet600,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => launchUrl(Uri.parse(office.phoneHref)),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.call_rounded, color: AppColors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

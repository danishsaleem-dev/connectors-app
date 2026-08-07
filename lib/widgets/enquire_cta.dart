import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/site_data.dart';
import '../theme/colors.dart';
import 'eyebrow.dart';
import 'orbit_field.dart';

/// Dark CTA card closing a screen — same role as VendorCta / JoinCommunityCta
/// on the site. Opens a real mailto to the general inbox rather than a form:
/// the enquiry forms and their Server Actions are a later phase, this app is
/// public screens only for now.
class EnquireCta extends StatelessWidget {
  final String title;
  final String body;

  const EnquireCta({super.key, required this.title, required this.body});

  Future<void> _openEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: SiteData.generalEmail,
      query: 'subject=${Uri.encodeComponent('Enquiry via the Connectors app')}',
    );
    await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
        decoration: const BoxDecoration(color: AppColors.ink),
        child: Stack(
          children: [
            Positioned(
              right: -50,
              bottom: -60,
              child: IgnorePointer(
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: OrbitField(color: AppColors.white, count: 18, animate: false),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Eyebrow('Get in touch', color: AppColors.violet200),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall
                      ?.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white.withValues(alpha: 0.65),
                      ),
                ),
                const SizedBox(height: 22),
                ElevatedButton(
                  onPressed: _openEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.ink,
                  ),
                  child: const Text('Start a conversation'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

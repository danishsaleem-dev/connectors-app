import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/site_data.dart';
import '../theme/colors.dart';

/// A single-line fallback prompt, not a repeated marketing CTA card — the
/// audience cards above already do the routing, so this only needs to catch
/// whoever doesn't fit any of them.
class EnquireCta extends StatelessWidget {
  final String message;

  const EnquireCta({super.key, required this.message});

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
    return Material(
      color: AppColors.grey50,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: _openEmail,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(color: AppColors.violet600, shape: BoxShape.circle),
                child: const Icon(Icons.mail_outline_rounded, color: AppColors.white, size: 16),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(message, style: Theme.of(context).textTheme.bodyMedium),
              ),
              const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.violet600),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/auth_result.dart' show apiBaseUrl;
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/enquire_cta.dart';
import '../widgets/page_header.dart';

/// The vendor side of the business — designers, architects, agencies and
/// contractors joining the bench Connectors places on real projects. Used
/// to carry the full pitch (disciplines, benefits) inline; a vendor opening
/// this from their own Home is already signed up, so that marketing case
/// has already been made — this is now just a way to ask a question, plus
/// a link out to the website's own /partners page for anyone who wants the
/// full pitch again.
class PartnersBody extends StatelessWidget {
  const PartnersBody({super.key});

  Future<void> _readMore(BuildContext context) async {
    final ok = await launchUrl(
      Uri.parse('$apiBaseUrl/partners'),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Couldn't open that page.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(
            icon: Icons.diversity_3_rounded,
            title: 'Partners',
            lead: 'The people who actually build the openings we broker.',
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Questions about the programme, a live project, or your '
                  'own account — send them straight to your Connectors team.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
                ),
                const SizedBox(height: AppSpacing.section),
                const InquireCta(
                  message: 'Ask us about the Partners Program',
                  subject: 'The Partners Program',
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () => _readMore(context),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: const Text('Read more about the Partners Program'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

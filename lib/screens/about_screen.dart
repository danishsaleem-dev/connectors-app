import 'package:flutter/material.dart';
import '../data/company_data.dart';
import '../data/division_data.dart';
import '../data/site_data.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/enquire_cta.dart';
import '../widgets/info_list.dart';
import '../widgets/marquee_strip.dart';
import '../widgets/section_intro.dart';
import '../widgets/stat_strip.dart';
import '../widgets/statement_block.dart';

const _whyIcons = [
  Icons.hub_rounded,
  Icons.diversity_3_rounded,
  Icons.bolt_rounded,
  Icons.route_rounded,
];

/// The website's story/values narrative — plus "Why Connectors" and the
/// industries list, both moved here from Home so the primary tab could get
/// down to just the hero and the four audience cards. This screen is meant
/// to be read, not glanced at, so it's the one place in the app a longer
/// scroll is the right call. The figures in the strip are counts of the
/// app's own content (offices, divisions, values), not performance claims —
/// the site ships no credibility statistics and this app shouldn't invent
/// any either.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Connectors')),
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
                'We built the bridge that expansion kept falling through.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                CompanyData.about,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
              ),
              const SizedBox(height: AppSpacing.xl),
              StatStrip(
                items: [
                  StatItem(value: '${SiteData.offices.length}', label: 'OFFICES'),
                  StatItem(value: '${DivisionData.all.length}', label: 'DIVISIONS'),
                  StatItem(value: '${CompanyData.values.length}', label: 'VALUES'),
                ],
              ),
              const SizedBox(height: AppSpacing.section),
              const StatementBlock(label: 'Mission', body: CompanyData.mission),
              const SizedBox(height: AppSpacing.xl),
              const StatementBlock(label: 'Vision', body: CompanyData.vision, index: 1),
              const SizedBox(height: AppSpacing.section),
              const SectionIntro(
                eyebrow: 'What we stand for',
                title: 'Five values, everywhere we operate.',
              ),
              const SizedBox(height: AppSpacing.sm),
              InfoList(
                items: [
                  for (var i = 0; i < CompanyData.values.length; i++)
                    InfoItem(
                      index: (i + 1).toString().padLeft(2, '0'),
                      title: CompanyData.values[i].title,
                      body: CompanyData.values[i].body,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.section),
              const SectionIntro(eyebrow: 'Why Connectors', title: 'One ecosystem.'),
              const SizedBox(height: AppSpacing.sm),
              InfoList(
                items: [
                  for (var i = 0; i < CompanyData.whyChoose.length; i++)
                    InfoItem(
                      icon: _whyIcons[i % _whyIcons.length],
                      title: CompanyData.whyChoose[i].title,
                      body: CompanyData.whyChoose[i].body,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.section),
              const SectionIntro(eyebrow: 'Industries', title: 'Wherever retail happens.'),
              const SizedBox(height: AppSpacing.heading),
              MarqueeStrip(items: CompanyData.industries),
              const SizedBox(height: AppSpacing.section),
              const EnquireCta(message: 'Want to know more? Email our team.'),
            ],
          ),
        ),
      ),
    );
  }
}

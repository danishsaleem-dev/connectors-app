import 'package:flutter/material.dart';
import '../data/vendor_services_data.dart';
import '../theme/spacing.dart';
import '../widgets/enquire_cta.dart';
import '../widgets/eyebrow.dart';
import '../widgets/info_list.dart';
import '../widgets/section_intro.dart';

/// The Partners Program's full service catalog, grouped into the three
/// categories a brand actually thinks in — design & build, marketing &
/// launch, operations & compliance — rather than one undifferentiated list
/// of twelve. See VendorServicesData for why this stops at the one-liner
/// instead of the website's per-service deep page.
class VendorServicesScreen extends StatelessWidget {
  const VendorServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = VendorServicesData.grouped;

    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Services')),
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
              const SectionIntro(
                eyebrow: 'Partners Program',
                title: 'Every discipline an opening needs.',
                lead: 'From first sketch to opening day — the vetted bench '
                    'Connectors puts behind every brand.',
              ),
              for (final group in groups) ...[
                const SizedBox(height: AppSpacing.section),
                Eyebrow(group.key),
                const SizedBox(height: AppSpacing.xs),
                InfoList(
                  items: [
                    for (final service in group.value)
                      InfoItem(icon: service.icon, title: service.title, body: service.body),
                  ],
                ),
              ],
              const SizedBox(height: AppSpacing.section),
              const EnquireCta(message: 'Questions about a specific service? Email our team.'),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/vendor_services_data.dart';
import '../widgets/enquire_cta.dart';
import '../widgets/section_intro.dart';
import '../widgets/tile_grid.dart';
import 'signup_screen.dart';

/// The Partners Program's full service catalog, grouped into the three
/// categories a brand actually thinks in — design & build, marketing &
/// launch, operations & compliance — rather than one undifferentiated list
/// of twelve near-identical rows. See VendorServicesData for why this stops
/// at the one-liner instead of the website's per-service deep page.
class VendorServicesScreen extends StatelessWidget {
  const VendorServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = VendorServicesData.grouped;

    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Services')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionIntro(
                eyebrow: 'Partners Program',
                title: 'Every discipline an opening needs.',
                lead: 'From first sketch to opening day — the vetted bench '
                    'Connectors puts behind every brand.',
              ),
              const SizedBox(height: 24),
              for (final group in groups) ...[
                Text(group.key, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 12),
                TileGrid(flat: true, items: [
                  for (final service in group.value)
                    TileItem(icon: service.icon, title: service.title, body: service.body),
                ]),
                if (group != groups.last) const SizedBox(height: 24),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SignupScreen(initialType: 'vendor')),
                  ),
                  child: const Text('Become a vendor'),
                ),
              ),
              const SizedBox(height: 12),
              const EnquireCta(message: 'Questions about a specific service? Email our team.'),
            ],
          ),
        ),
      ),
    );
  }
}

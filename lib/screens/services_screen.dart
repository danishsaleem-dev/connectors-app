import 'package:flutter/material.dart';
import '../data/division_data.dart';
import '../widgets/enquire_cta.dart';
import '../widgets/section_intro.dart';
import '../widgets/tile_grid.dart';

/// The seven divisions from the website's Solutions menu, as a scannable
/// catalog. Each division gets a full page on the website; here it's one
/// tile — a phone screen that already has the divisions on the four
/// audience tabs doesn't need a second copy of that depth.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const _icons = [
    Icons.storefront_rounded,
    Icons.handshake_rounded,
    Icons.trending_up_rounded,
    Icons.apartment_rounded,
    Icons.real_estate_agent_rounded,
    Icons.campaign_rounded,
    Icons.hub_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Our Services')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionIntro(
                eyebrow: 'What we do',
                title: 'Seven divisions, one ecosystem.',
                lead: 'From the first site search to the software that runs your '
                    'franchise network — everything moves through one team.',
              ),
              const SizedBox(height: 20),
              TileGrid(
                items: [
                  for (var i = 0; i < DivisionData.all.length; i++)
                    TileItem(
                      icon: _icons[i % _icons.length],
                      title: DivisionData.all[i].navLabel,
                      body: DivisionData.all[i].short,
                    ),
                ],
              ),
              const SizedBox(height: 28),
              const EnquireCta(message: "Not sure which division fits? Email our team."),
            ],
          ),
        ),
      ),
    );
  }
}

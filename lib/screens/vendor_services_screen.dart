import 'package:flutter/material.dart';
import '../data/vendor_services_data.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../widgets/reveal.dart';

/// The Partners Program's full service catalog — every discipline a brand
/// might bring in, one line each. See VendorServicesData for why this stops
/// at the one-liner instead of the website's per-service deep page.
class VendorServicesScreen extends StatelessWidget {
  const VendorServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vendor Services')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          itemCount: VendorServicesData.all.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final service = VendorServicesData.all[i];
            return Reveal(
              index: i,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: cardShadow(),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.violet50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(service.icon, color: AppColors.violet600, size: 19),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(service.title, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 2),
                          Text(
                            service.body,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.grey500),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

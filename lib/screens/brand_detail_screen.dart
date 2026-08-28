import 'package:flutter/material.dart';
import '../data/franchising_brand.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/enquire_cta.dart';

class BrandDetailScreen extends StatelessWidget {
  final FranchisingBrand brand;

  const BrandDetailScreen({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(brand.name)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.lg,
            AppSpacing.page,
            AppSpacing.section,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: SizedBox(
                      width: 56,
                      height: 56,
                      child: brand.logoUrl != null
                          ? Image.network(
                              brand.logoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: AppColors.violet50,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.storefront_rounded,
                                  color: AppColors.violet600,
                                ),
                              ),
                            )
                          : Container(
                              color: AppColors.violet50,
                              alignment: Alignment.center,
                              child: const Icon(Icons.storefront_rounded, color: AppColors.violet600),
                            ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(brand.name, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 2),
                        Text(
                          [brand.industry, brand.country]
                              .where((s) => s != null && s.isNotEmpty)
                              .join(' · '),
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: AppColors.grey500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (brand.description != null && brand.description!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                Text(
                  brand.description!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              _DetailGrid(brand: brand),
              const SizedBox(height: AppSpacing.section),
              EnquireCta(message: 'Ask about franchising with ${brand.name}.'),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailGrid extends StatelessWidget {
  final FranchisingBrand brand;

  const _DetailGrid({required this.brand});

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[
      if (brand.outletCount != null)
        (Icons.storefront_outlined, 'Outlets open', '${brand.outletCount}'),
      if (brand.investmentDisplay != null)
        (Icons.payments_outlined, 'Investment', brand.investmentDisplay!),
      if (brand.feeDisplay != null) (Icons.receipt_long_outlined, 'Franchise fee', brand.feeDisplay!),
      if (brand.countriesPresent.isNotEmpty)
        (Icons.public_outlined, 'Present in', brand.countriesPresent.join(', ')),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        for (final (icon, label, value) in items)
          SizedBox(
            width: (MediaQuery.of(context).size.width - AppSpacing.page * 2 - AppSpacing.md) / 2,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: cardShadow(),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 18, color: AppColors.violet600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(color: AppColors.grey500),
                        ),
                        Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

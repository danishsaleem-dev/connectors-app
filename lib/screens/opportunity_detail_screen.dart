import 'package:flutter/material.dart';
import '../data/opportunity.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/enquire_cta.dart';

class OpportunityDetailScreen extends StatelessWidget {
  final OpportunityListing listing;

  const OpportunityDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final details = <(String, String)>[
      if (listing.industry != null) ('Industry', listing.industry!),
      if (listing.brandType != null) ('Brand type', listing.brandType!),
      if (listing.investmentDisplay != null) ('Investment range', listing.investmentDisplay!),
      if (listing.feeDisplay != null) ('Franchise fee', listing.feeDisplay!),
      if (listing.sizeDisplay != null) ('Size', listing.sizeDisplay!),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(categoryFor(listing.category).label)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.section,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(listing.title, style: Theme.of(context).textTheme.displaySmall),
                  ),
                  if (listing.featured) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.violet600,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Featured',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: AppColors.white),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 16, color: AppColors.grey500),
                  const SizedBox(width: 4),
                  Text(
                    '${listing.city}, ${listing.country}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Text(listing.description, style: Theme.of(context).textTheme.bodyLarge),
              if (details.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.xl),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.grey50,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < details.length; i++) ...[
                        if (i > 0) const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              details[i].$1,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.grey500),
                            ),
                            Text(details[i].$2, style: Theme.of(context).textTheme.titleMedium),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.section),
              const EnquireCta(message: 'Interested in this listing? Email our team.'),
            ],
          ),
        ),
      ),
    );
  }
}

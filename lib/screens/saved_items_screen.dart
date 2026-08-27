import 'package:flutter/material.dart';
import '../data/opportunity.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/opportunity_cover.dart';
import '../widgets/reveal.dart';
import 'opportunity_detail_screen.dart';

/// A shortlist of saved listings — the standard companion to any browse
/// experience, and currently the missing half of Opportunities (you can
/// look but not keep).
///
/// UI only: there's no save action anywhere in the app yet and nothing is
/// stored per account, so this shows a few of the same mock listings the
/// Opportunities tab uses. Wiring it up means adding a save toggle to the
/// listing cards and somewhere to persist it.
class SavedItemsScreen extends StatelessWidget {
  const SavedItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final saved = mockOpportunities.where((o) => o.featured).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Saved')),
      body: SafeArea(
        child: saved.isEmpty
            ? const _EmptyState()
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.md,
                  AppSpacing.page,
                  AppSpacing.section,
                ),
                itemCount: saved.length,
                separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, i) => Reveal(
                  index: i,
                  child: _SavedCard(listing: saved[i]),
                ),
              ),
      ),
    );
  }
}

class _SavedCard extends StatelessWidget {
  final OpportunityListing listing;

  const _SavedCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OpportunityDetailScreen(listing: listing)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              OpportunityCover(listing: listing, height: 96),
              Positioned(
                top: 10,
                right: 10,
                child: Material(
                  color: AppColors.white,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon')),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(7),
                      child: Icon(Icons.bookmark_rounded, size: 16, color: AppColors.violet600),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(listing.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.place_outlined, size: 14, color: AppColors.grey300),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${listing.city}, ${listing.country}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.grey500),
                      ),
                    ),
                    Text(
                      categoryFor(listing.category).label,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: AppColors.violet600),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.violet50, shape: BoxShape.circle),
              child: const Icon(
                Icons.bookmark_border_rounded,
                color: AppColors.violet600,
                size: 28,
              ),
            ),
            const SizedBox(height: 18),
            Text('Nothing saved yet', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Listings you save from Opportunities will show up here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
            ),
          ],
        ),
      ),
    );
  }
}

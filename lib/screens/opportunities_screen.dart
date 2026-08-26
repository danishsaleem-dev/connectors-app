import 'package:flutter/material.dart';
import '../data/opportunity.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/page_header.dart';
import '../widgets/reveal.dart';
import 'locations_screen.dart';
import 'opportunity_list_screen.dart';

/// The Opportunities tab — a category hub rather than one long feed, since
/// what's relevant varies a lot by category (a franchise fee means nothing
/// for a commercial project). Which categories show is role-dependent; see
/// categoriesForRole's doc comment for the current (first-pass) mapping.
class OpportunitiesScreen extends StatelessWidget {
  final String? orgType;

  const OpportunitiesScreen({super.key, required this.orgType});

  @override
  Widget build(BuildContext context) {
    final categories = categoriesForRole(orgType);

    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(
            icon: Icons.travel_explore_rounded,
            title: 'Opportunities',
            lead: 'Everything available across Connectors, in one place.',
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              // A fixed height per cell (not an aspect ratio) — that's what
              // guarantees every card is actually the same size regardless
              // of how much its title/description wrap, and gives content
              // enough room that it doesn't get clipped.
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                mainAxisExtent: 176,
              ),
              itemCount: categories.length,
              itemBuilder: (context, i) => Reveal(
                index: i,
                child: _CategoryCard(category: categories[i], orgType: orgType),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final OpportunityCategoryConfig category;
  final String? orgType;

  const _CategoryCard({required this.category, required this.orgType});

  @override
  Widget build(BuildContext context) {
    // "Locations" already has a real, working browse screen (search +
    // filters over live property data) for brand accounts — reuse it
    // instead of shadowing it with the mock category list.
    final useRealLocations = category.key == 'locations' && orgType == 'brand';

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => useRealLocations
                ? const LocationsScreen()
                : OpportunityListScreen(category: category),
          ),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: cardShadow(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.violet600.withValues(alpha: 0.08),
                          AppColors.violet600.withValues(alpha: 0.16),
                        ],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(category.icon, color: AppColors.violet600, size: 21),
                  ),
                  Icon(Icons.arrow_outward_rounded, size: 16, color: AppColors.grey200),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                category.label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                category.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.grey500, fontSize: 12.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

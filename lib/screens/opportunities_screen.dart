import 'package:flutter/material.dart';
import '../data/location.dart';
import '../data/opportunity.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_card.dart';
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

// Categories backed by real, live property data for brand accounts —
// "locations" is the unrestricted browse view (LocationsScreen's own Home
// action), "retail" and "commercial" are that exact same data, just
// grouped by property type (null means no grouping filter). "brands",
// "franchise" and "investors" stay mock: showing them for real would mean
// exposing other organizations' data across account types, which needs a
// real access-control decision nobody's made yet — see opportunity.dart.
const _realPropertyCategories = <String, Set<String>?>{
  'locations': null,
  'retail': retailPropertyTypes,
  'commercial': commercialPropertyTypes,
};

class _CategoryCard extends StatelessWidget {
  final OpportunityCategoryConfig category;
  final String? orgType;

  const _CategoryCard({required this.category, required this.orgType});

  @override
  Widget build(BuildContext context) {
    final isRealProperty =
        orgType == 'brand' && _realPropertyCategories.containsKey(category.key);

    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => isRealProperty
              ? LocationsScreen(
                  appBarTitle: category.key == 'locations' ? 'Available Locations' : category.label,
                  propertyTypes: _realPropertyCategories[category.key],
                )
              : OpportunityListScreen(category: category),
        ),
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
                decoration: const BoxDecoration(
                  color: AppColors.violet50,
                  shape: BoxShape.circle,
                ),
                child: Icon(category.icon, color: AppColors.violet600, size: 21),
              ),
              const Icon(Icons.arrow_outward_rounded, size: 16, color: AppColors.grey300),
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
    );
  }
}

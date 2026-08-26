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
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              childAspectRatio: 0.98,
              children: [
                for (var i = 0; i < categories.length; i++)
                  Reveal(
                    index: i,
                    child: _CategoryCard(category: categories[i], orgType: orgType),
                  ),
              ],
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
            boxShadow: cardShadow(opacity: 0.05),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.violet50, shape: BoxShape.circle),
                child: Icon(category.icon, color: AppColors.violet600, size: 19),
              ),
              const Spacer(),
              Text(category.label, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Expanded(
                child: Text(
                  category.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.grey500, fontSize: 12.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/opportunity.dart';
import '../data/opportunity_filters.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/opportunity_cover.dart';
import '../widgets/reveal.dart';
import 'opportunity_detail_screen.dart';

/// Search + filter + list for one Opportunities category. Same shape as
/// LocationsScreen (search field, chip row opening bottom-sheet pickers,
/// result count, card list) generalised over whichever of the six filter
/// fields a given category declares as relevant.
class OpportunityListScreen extends StatefulWidget {
  final OpportunityCategoryConfig category;

  const OpportunityListScreen({super.key, required this.category});

  @override
  State<OpportunityListScreen> createState() => _OpportunityListScreenState();
}

class _OpportunityListScreenState extends State<OpportunityListScreen> {
  final _searchController = TextEditingController();
  OpportunityFilters _filters = const OpportunityFilters();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _updateFilters(OpportunityFilters Function(OpportunityFilters) update) {
    setState(() => _filters = update(_filters));
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() => _filters = const OpportunityFilters());
  }

  @override
  Widget build(BuildContext context) {
    final all = opportunitiesFor(widget.category.key);
    final filtered = all.where(_filters.matches).toList();

    return Scaffold(
      appBar: AppBar(title: Text(widget.category.label)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.md,
                AppSpacing.page,
                0,
              ),
              child: _SearchField(
                controller: _searchController,
                onChanged: (v) => _updateFilters((f) => f.copyWith(query: v)),
              ),
            ),
            if (widget.category.filters.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.sm,
                  AppSpacing.page,
                  0,
                ),
                child: _FilterBar(
                  category: widget.category,
                  filters: _filters,
                  onChanged: _updateFilters,
                  onClear: _clearFilters,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.sm, AppSpacing.page, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  filtered.length == 1 ? '1 result' : '${filtered.length} results',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.grey500),
                ),
              ),
            ),
            Expanded(
              child: filtered.isEmpty
                  ? _EmptyState(onClear: _filters.isActive ? _clearFilters : null)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.page,
                        AppSpacing.md,
                        AppSpacing.page,
                        AppSpacing.section,
                      ),
                      itemCount: filtered.length,
                      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                      itemBuilder: (context, i) =>
                          Reveal(index: i, child: _OpportunityCard(listing: filtered[i])),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search by name or city',
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.grey300),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close_rounded, color: AppColors.grey300),
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
              ),
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

/// Maps each filter key to its options and its OpportunityFilters
/// accessor/mutator, so the chip row can stay generic over whatever
/// subset a category declares.
class _FilterBar extends StatelessWidget {
  final OpportunityCategoryConfig category;
  final OpportunityFilters filters;
  final void Function(OpportunityFilters Function(OpportunityFilters)) onChanged;
  final VoidCallback onClear;

  const _FilterBar({
    required this.category,
    required this.filters,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final key in category.filters) ...[
            _chipFor(context, key),
            const SizedBox(width: AppSpacing.sm),
          ],
          if (filters.isActive)
            ActionChip(
              label: const Text('Clear'),
              onPressed: onClear,
              avatar: const Icon(Icons.close_rounded, size: 16),
              backgroundColor: AppColors.white,
            ),
        ],
      ),
    );
  }

  Widget _chipFor(BuildContext context, String key) {
    switch (key) {
      case 'country':
        return _Chip(
          label: 'Country',
          value: filters.country,
          options: countries.map((c) => (c, c)).toList(),
          onSelect: (v) => onChanged((f) => f.copyWith(country: () => v)),
        );
      case 'industry':
        return _Chip(
          label: 'Industry',
          value: filters.industry,
          options: industries.map((c) => (c, c)).toList(),
          onSelect: (v) => onChanged((f) => f.copyWith(industry: () => v)),
        );
      case 'brandType':
        return _Chip(
          label: 'Brand Type',
          value: filters.brandType,
          options: brandTypes.map((c) => (c, c)).toList(),
          onSelect: (v) => onChanged((f) => f.copyWith(brandType: () => v)),
        );
      case 'investment':
        return _Chip(
          label: 'Investment Range',
          value: filters.investmentBucket,
          valueLabel: _bucketLabel(investmentBuckets, filters.investmentBucket),
          options: investmentBuckets.map((b) => (b.value, b.label)).toList(),
          onSelect: (v) => onChanged((f) => f.copyWith(investmentBucket: () => v)),
        );
      case 'fee':
        return _Chip(
          label: 'Franchise Fee',
          value: filters.feeBucket,
          valueLabel: _bucketLabel(feeBuckets, filters.feeBucket),
          options: feeBuckets.map((b) => (b.value, b.label)).toList(),
          onSelect: (v) => onChanged((f) => f.copyWith(feeBucket: () => v)),
        );
      case 'size':
        return _Chip(
          label: 'Property Size',
          value: filters.sizeBucket,
          valueLabel: _bucketLabel(sizeBuckets, filters.sizeBucket),
          options: sizeBuckets.map((b) => (b.value, b.label)).toList(),
          onSelect: (v) => onChanged((f) => f.copyWith(sizeBucket: () => v)),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

String? _bucketLabel(List<RangeBucket> buckets, String? value) {
  if (value == null) return null;
  for (final b in buckets) {
    if (b.value == value) return b.label;
  }
  return null;
}

class _Chip extends StatelessWidget {
  final String label;
  final String? value;
  final String? valueLabel;
  final List<(String, String)> options;
  final ValueChanged<String?> onSelect;

  const _Chip({
    required this.label,
    required this.value,
    required this.options,
    required this.onSelect,
    this.valueLabel,
  });

  @override
  Widget build(BuildContext context) {
    final active = value != null;
    final displayText = active ? (valueLabel ?? value!) : label;

    return Material(
      color: active ? AppColors.violet50 : AppColors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => _openPicker(context),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: active ? AppColors.violet600 : AppColors.grey100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                displayText,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: active ? AppColors.violet600 : AppColors.grey500,
                    ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.expand_more_rounded,
                size: 18,
                color: active ? AppColors.violet600 : AppColors.grey300,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openPicker(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(label, style: Theme.of(sheetContext).textTheme.titleLarge),
              ),
            ),
            ListTile(
              title: const Text('Any'),
              trailing: value == null
                  ? const Icon(Icons.check_rounded, color: AppColors.violet600)
                  : null,
              onTap: () {
                onSelect(null);
                Navigator.of(sheetContext).pop();
              },
            ),
            for (final option in options)
              ListTile(
                title: Text(option.$2),
                trailing: value == option.$1
                    ? const Icon(Icons.check_rounded, color: AppColors.violet600)
                    : null,
                onTap: () {
                  onSelect(option.$1);
                  Navigator.of(sheetContext).pop();
                },
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final OpportunityListing listing;

  const _OpportunityCard({required this.listing});

  @override
  Widget build(BuildContext context) {
    final meta = [
      listing.industry,
      listing.brandType,
      listing.investmentDisplay,
      listing.feeDisplay,
      listing.sizeDisplay,
    ].whereType<String>().toList();

    return AppCard(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => OpportunityDetailScreen(listing: listing)),
      ),
      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    OpportunityCover(listing: listing),
                    if (listing.featured)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Featured',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: AppColors.violet600),
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
                          Text(
                            '${listing.city}, ${listing.country}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.grey500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        listing.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.grey500),
                      ),
                      if (meta.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final m in meta)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.grey50,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  m,
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelMedium
                                      ?.copyWith(
                                        color: AppColors.grey500,
                                        fontWeight: FontWeight.w500,
                                      ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback? onClear;

  const _EmptyState({this.onClear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, color: AppColors.grey300, size: 40),
            const SizedBox(height: 16),
            Text(
              'No listings match your filters.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
            ),
            if (onClear != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(onPressed: onClear, child: const Text('Clear filters')),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../data/location.dart';
import '../data/location_filters.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/reveal.dart';
import 'location_detail_screen.dart';

/// Brand-only browse view — the endpoint itself enforces that (see its doc
/// comment), so this screen is only ever reached from a brand account's own
/// Home action card. Same data as the website's /available-locations, same
/// "not withdrawn" filter, already applied server-side. Search and filters
/// below mirror that page's own LocationFilters logic, applied in-memory
/// over the one fetched list rather than as repeat network requests.
class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  late Future<List<Location>> _future;
  final _searchController = TextEditingController();
  LocationFilters _filters = const LocationFilters();

  @override
  void initState() {
    super.initState();
    _future = ApiClient.fetchLocations();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _retry() => setState(() => _future = ApiClient.fetchLocations());

  void _updateFilters(LocationFilters Function(LocationFilters) update) {
    setState(() => _filters = update(_filters));
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() => _filters = const LocationFilters());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Locations')),
      body: SafeArea(
        child: FutureBuilder<List<Location>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _StatusMessage(
                icon: Icons.wifi_off_rounded,
                message: snapshot.error is ApiException
                    ? (snapshot.error as ApiException).message
                    : "Couldn't load locations. Please try again.",
                onRetry: _retry,
              );
            }
            final locations = snapshot.data ?? const [];
            if (locations.isEmpty) {
              return const _StatusMessage(
                icon: Icons.location_off_outlined,
                message: 'Nothing available right now — check back soon.',
              );
            }

            final cities = locations.map((l) => l.city).toSet().toList()..sort();
            final filtered = locations.where(_filters.matches).toList();

            return Column(
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
                    onChanged: (value) => _updateFilters((f) => f.copyWith(query: value)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.sm,
                    AppSpacing.page,
                    0,
                  ),
                  child: _FilterBar(
                    filters: _filters,
                    cities: cities,
                    onStatusChanged: (v) => _updateFilters((f) => f.copyWith(status: () => v)),
                    onTypeChanged: (v) => _updateFilters((f) => f.copyWith(propertyType: () => v)),
                    onSizeChanged: (v) => _updateFilters((f) => f.copyWith(sizeBucket: () => v)),
                    onCityChanged: (v) => _updateFilters((f) => f.copyWith(city: () => v)),
                    onClear: _clearFilters,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.sm,
                    AppSpacing.page,
                    0,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      filtered.length == 1 ? '1 result' : '${filtered.length} results',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge?.copyWith(color: AppColors.grey500),
                    ),
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? _StatusMessage(
                          icon: Icons.search_off_rounded,
                          message: 'No locations match your filters.',
                          onRetry: _filters.isActive ? _clearFilters : null,
                          retryLabel: 'Clear filters',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.page,
                            AppSpacing.md,
                            AppSpacing.page,
                            AppSpacing.section,
                          ),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
                          itemBuilder: (context, i) => Reveal(
                            index: i,
                            child: _LocationCard(location: filtered[i]),
                          ),
                        ),
                ),
              ],
            );
          },
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
        hintText: 'Search by title, city or area',
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

String? _sizeBucketLabel(String? value) {
  if (value == null) return null;
  for (final bucket in sizeBuckets) {
    if (bucket.value == value) return bucket.label;
  }
  return null;
}

class _FilterBar extends StatelessWidget {
  final LocationFilters filters;
  final List<String> cities;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onSizeChanged;
  final ValueChanged<String?> onCityChanged;
  final VoidCallback onClear;

  const _FilterBar({
    required this.filters,
    required this.cities,
    required this.onStatusChanged,
    required this.onTypeChanged,
    required this.onSizeChanged,
    required this.onCityChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _FilterChip(
            label: 'Status',
            value: filters.status == null ? null : propertyStatusLabels[filters.status],
            onTap: () => _openPicker(
              context,
              title: 'Status',
              value: filters.status,
              options: propertyStatusLabels.entries
                  .where((e) => e.key != 'withdrawn') // never shown — filtered out server-side
                  .map((e) => (e.key, e.value))
                  .toList(),
              onSelect: onStatusChanged,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: 'Type',
            value: filters.propertyType == null ? null : propertyTypeLabels[filters.propertyType],
            onTap: () => _openPicker(
              context,
              title: 'Property type',
              value: filters.propertyType,
              options: propertyTypeLabels.entries.map((e) => (e.key, e.value)).toList(),
              onSelect: onTypeChanged,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: 'Size',
            value: _sizeBucketLabel(filters.sizeBucket),
            onTap: () => _openPicker(
              context,
              title: 'Size',
              value: filters.sizeBucket,
              options: sizeBuckets.map((b) => (b.value, b.label)).toList(),
              onSelect: onSizeChanged,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _FilterChip(
            label: 'City',
            value: filters.city,
            onTap: () => _openPicker(
              context,
              title: 'City',
              value: filters.city,
              options: cities.map((c) => (c, c)).toList(),
              onSelect: onCityChanged,
            ),
          ),
          if (filters.isActive) ...[
            const SizedBox(width: AppSpacing.sm),
            ActionChip(
              label: const Text('Clear'),
              onPressed: onClear,
              avatar: const Icon(Icons.close_rounded, size: 16),
              backgroundColor: AppColors.white,
            ),
          ],
        ],
      ),
    );
  }

  void _openPicker(
    BuildContext context, {
    required String title,
    required String? value,
    required List<(String, String)> options,
    required ValueChanged<String?> onSelect,
  }) {
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
                child: Text(title, style: Theme.of(sheetContext).textTheme.titleLarge),
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

class _FilterChip extends StatelessWidget {
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _FilterChip({required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final active = value != null;
    return Material(
      color: active ? AppColors.violet50 : AppColors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
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
                active ? value! : label,
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
}

class _StatusMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;

  const _StatusMessage({
    required this.icon,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Try again',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColors.grey300, size: 40),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(onPressed: onRetry, child: Text(retryLabel)),
            ],
          ],
        ),
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final Location location;

  const _LocationCard({required this.location});

  @override
  Widget build(BuildContext context) {
    final cover = location.photoUrls.isNotEmpty ? location.photoUrls.first : null;

    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => LocationDetailScreen(location: location)),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: cardShadow(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                child: AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (cover != null)
                        Image.network(
                          cover,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const _ImageFallback(),
                          loadingBuilder: (context, child, progress) =>
                              progress == null ? child : const _ImageFallback(loading: true),
                        )
                      else
                        const _ImageFallback(),
                      Positioned(
                        left: 10,
                        top: 10,
                        child: _Pill(
                          text: propertyStatusLabels[location.status] ?? location.status,
                          color: AppColors.violet600,
                        ),
                      ),
                      if (location.featured)
                        Positioned(
                          right: 10,
                          top: 10,
                          child: _Pill(text: 'Featured', color: AppColors.ink),
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        propertyTypeLabels[location.propertyType] ?? location.propertyType,
                        [location.area, location.city].where((s) => s != null && s.isNotEmpty).join(', '),
                      ].where((s) => s.isNotEmpty).join(' · '),
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.grey500),
                    ),
                    if (location.sizeSqft != null || location.rentDisplay != null) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          if (location.sizeSqft != null) ...[
                            const Icon(Icons.square_foot_rounded, size: 15, color: AppColors.violet400),
                            const SizedBox(width: 4),
                            Text(
                              '${location.sizeSqft} sq ft',
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ],
                          if (location.sizeSqft != null && location.rentDisplay != null)
                            const SizedBox(width: 14),
                          if (location.rentDisplay != null)
                            Expanded(
                              child: Text(
                                location.rentDisplay!,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(color: AppColors.violet600),
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
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final bool loading;

  const _ImageFallback({this.loading = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.grey50,
      alignment: Alignment.center,
      child: loading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.grey300),
            )
          : const Icon(Icons.storefront_outlined, color: AppColors.grey300, size: 28),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color color;

  const _Pill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppColors.white),
      ),
    );
  }
}

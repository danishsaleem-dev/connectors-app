import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../data/location.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/reveal.dart';
import 'location_detail_screen.dart';

/// Brand-only browse view — the endpoint itself enforces that (see its doc
/// comment), so this screen is only ever reached from a brand account's own
/// Home action card. Same data as the website's /available-locations, same
/// "not withdrawn" filter, already applied server-side.
class LocationsScreen extends StatefulWidget {
  const LocationsScreen({super.key});

  @override
  State<LocationsScreen> createState() => _LocationsScreenState();
}

class _LocationsScreenState extends State<LocationsScreen> {
  late Future<List<Location>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiClient.fetchLocations();
  }

  void _retry() => setState(() => _future = ApiClient.fetchLocations());

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
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.md,
                AppSpacing.page,
                AppSpacing.section,
              ),
              itemCount: locations.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) => Reveal(
                index: i,
                child: _LocationCard(location: locations[i]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final VoidCallback? onRetry;

  const _StatusMessage({required this.icon, required this.message, this.onRetry});

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
              OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
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

import 'package:flutter/material.dart';
import '../data/location.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/enquire_cta.dart';

class LocationDetailScreen extends StatelessWidget {
  final Location location;

  const LocationDetailScreen({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Location Details')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (location.photoUrls.isNotEmpty) _PhotoCarousel(photoUrls: location.photoUrls),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.lg,
                  AppSpacing.page,
                  AppSpacing.section,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Pill(
                          text: propertyStatusLabels[location.status] ?? location.status,
                          color: AppColors.violet600,
                        ),
                        _Pill(
                          text: propertyTypeLabels[location.propertyType] ?? location.propertyType,
                          color: AppColors.grey500,
                        ),
                        if (location.featured) const _Pill(text: 'Featured', color: AppColors.ink),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(location.title, style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.grey500),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            [location.area, location.city, location.country]
                                .where((s) => s != null && s.isNotEmpty)
                                .join(', '),
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: AppColors.grey500),
                          ),
                        ),
                      ],
                    ),
                    if (location.organizationName != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Listed by ${location.organizationName}',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.grey500),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.xl),
                    _DetailGrid(location: location),
                    if (location.description != null && location.description!.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xl),
                      Text('About this space', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 8),
                      Text(
                        location.description!,
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AppColors.grey500),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.section),
                    EnquireCta(message: 'Interested in "${location.title}"? Email our team.'),
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

class _DetailGrid extends StatelessWidget {
  final Location location;

  const _DetailGrid({required this.location});

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[
      if (location.sizeSqft != null)
        (Icons.square_foot_rounded, 'Size', '${location.sizeSqft} sq ft'),
      if (location.dimensions != null && location.dimensions!.isNotEmpty)
        (Icons.straighten_rounded, 'Dimensions', location.dimensions!),
      if (location.floorLevel != null && location.floorLevel!.isNotEmpty)
        (Icons.layers_outlined, 'Floor', location.floorLevel!),
      (
        Icons.local_parking_outlined,
        'Parking',
        location.parkingAvailable ? 'Available' : 'Not available',
      ),
      if (location.rentDisplay != null) (Icons.payments_outlined, 'Rent', location.rentDisplay!),
      if (location.availableFrom != null && location.availableFrom!.isNotEmpty)
        (Icons.event_available_outlined, 'Available from', location.availableFrom!),
    ];

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

class _PhotoCarousel extends StatefulWidget {
  final List<String> photoUrls;

  const _PhotoCarousel({required this.photoUrls});

  @override
  State<_PhotoCarousel> createState() => _PhotoCarouselState();
}

class _PhotoCarouselState extends State<_PhotoCarousel> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 11,
          child: PageView.builder(
            controller: _controller,
            itemCount: widget.photoUrls.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) => Image.network(
              widget.photoUrls[i],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: AppColors.grey50,
                alignment: Alignment.center,
                child: const Icon(Icons.storefront_outlined, color: AppColors.grey300, size: 32),
              ),
            ),
          ),
        ),
        if (widget.photoUrls.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < widget.photoUrls.length; i++)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _page ? AppColors.violet600 : AppColors.grey200,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
            ],
          ),
        ],
      ],
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

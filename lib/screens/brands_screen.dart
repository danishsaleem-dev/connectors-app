import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../data/franchising_brand.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/reveal.dart';
import 'brand_detail_screen.dart';

/// Brands actively franchising — real data (see ApiClient.
/// fetchFranchisingBrands's doc comment: the same the public website
/// already shows). Backs both the "Brands" and "Franchise Opportunities"
/// Opportunities categories — there's no real distinction between them in
/// the data, so [title] is the only thing that differs between the two
/// entry points.
class BrandsScreen extends StatefulWidget {
  final String title;

  const BrandsScreen({super.key, this.title = 'Brands'});

  @override
  State<BrandsScreen> createState() => _BrandsScreenState();
}

class _BrandsScreenState extends State<BrandsScreen> {
  late Future<List<FranchisingBrand>> _future;
  final _searchController = TextEditingController();
  String _query = '';
  String? _industry;

  @override
  void initState() {
    super.initState();
    _future = ApiClient.fetchFranchisingBrands();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _retry() => setState(() => _future = ApiClient.fetchFranchisingBrands());

  bool _matches(FranchisingBrand brand) {
    if (_industry != null && brand.industry != _industry) return false;
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final haystack = '${brand.name} ${brand.industry ?? ''} ${brand.country ?? ''}'.toLowerCase();
    return haystack.contains(q);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: FutureBuilder<List<FranchisingBrand>>(
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
                    : "Couldn't load brands. Please try again.",
                onRetry: _retry,
              );
            }
            final brands = snapshot.data ?? const [];
            if (brands.isEmpty) {
              return const _StatusMessage(
                icon: Icons.storefront_outlined,
                message: 'No brands are franchising right now — check back soon.',
              );
            }

            final industries = brands.map((b) => b.industry).whereType<String>().toSet().toList()
              ..sort();
            final filtered = brands.where(_matches).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.md,
                    AppSpacing.page,
                    0,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search by name or industry',
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.grey300),
                      filled: true,
                      fillColor: AppColors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                if (industries.length > 1) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                      children: [
                        for (final industry in industries) ...[
                          _IndustryChip(
                            label: industry,
                            selected: _industry == industry,
                            onTap: () => setState(
                              () => _industry = _industry == industry ? null : industry,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                ],
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
                          message: 'No brands match your search.',
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
                            child: _BrandCard(brand: filtered[i]),
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

class _IndustryChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _IndustryChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.violet50 : AppColors.white,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? AppColors.violet600 : AppColors.grey100),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? AppColors.violet600 : AppColors.grey500,
                ),
          ),
        ),
      ),
    );
  }
}

class _BrandCard extends StatelessWidget {
  final FranchisingBrand brand;

  const _BrandCard({required this.brand});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => BrandDetailScreen(brand: brand)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 48,
              height: 48,
              child: brand.logoUrl != null
                  ? Image.network(
                      brand.logoUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const _LogoFallback(),
                    )
                  : const _LogoFallback(),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  [brand.industry, brand.country].where((s) => s != null && s.isNotEmpty).join(' · '),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
                ),
                if (brand.description != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    brand.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.grey500, fontSize: 12.5),
                  ),
                ],
                if (brand.investmentDisplay != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    brand.investmentDisplay!,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: AppColors.violet600),
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

class _LogoFallback extends StatelessWidget {
  const _LogoFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.violet50,
      alignment: Alignment.center,
      child: const Icon(Icons.storefront_rounded, color: AppColors.violet600, size: 22),
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

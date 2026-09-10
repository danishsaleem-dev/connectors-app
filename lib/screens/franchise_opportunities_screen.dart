import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../data/franchise_opportunity.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/enquire_cta.dart';
import '../widgets/page_header.dart';
import '../widgets/reveal.dart';

/// FranchiseOpportunitiesBody with its own AppBar — for the franchisee
/// role's "Opportunities" Home quick action (see account_type_config.dart),
/// so tapping it doesn't just duplicate the Opportunities tab underneath
/// without a way back. showHeader: false there since the AppBar title
/// already says what this is.
class FranchiseOpportunitiesScreen extends StatelessWidget {
  const FranchiseOpportunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Opportunities')),
      body: const SafeArea(
        child: SingleChildScrollView(
          child: FranchiseOpportunitiesBody(showHeader: false),
        ),
      ),
    );
  }
}

/// The franchisee role's Opportunities tab content — see opportunities_
/// screen.dart, where the tab body swaps to this entirely instead of the
/// brands/franchise category grid, same pattern as landlord/developer's
/// InterestedBody, consultant's RequestsBody and vendor's
/// VendorOpportunitiesBody. A franchisee never browses brands or franchise
/// opportunities directly — only what an admin has matched to them.
class FranchiseOpportunitiesBody extends StatefulWidget {
  /// Off when reached via FranchiseOpportunitiesScreen's own AppBar above,
  /// which already says "Opportunities" — on (the default) for the tab,
  /// which has no AppBar of its own.
  final bool showHeader;

  const FranchiseOpportunitiesBody({super.key, this.showHeader = true});

  @override
  State<FranchiseOpportunitiesBody> createState() =>
      _FranchiseOpportunitiesBodyState();
}

class _FranchiseOpportunitiesBodyState
    extends State<FranchiseOpportunitiesBody> {
  late Future<List<FranchiseOpportunity>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiClient.fetchFranchiseOpportunities();
  }

  void _retry() =>
      setState(() => _future = ApiClient.fetchFranchiseOpportunities());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.page,
        0,
        AppSpacing.page,
        AppSpacing.section,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showHeader) ...[
            const PageHeader(
              icon: Icons.workspace_premium_rounded,
              title: 'Opportunities',
              lead:
                  "Franchise opportunities your Connectors team's matched you to.",
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
          FutureBuilder<List<FranchiseOpportunity>>(
            future: _future,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 60),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return _StatusMessage(
                  message: snapshot.error is ApiException
                      ? (snapshot.error as ApiException).message
                      : "Couldn't load this. Please try again.",
                  onRetry: _retry,
                );
              }
              final opportunities = snapshot.data ?? const [];
              if (opportunities.isEmpty) {
                return const _StatusMessage(
                  icon: Icons.workspace_premium_outlined,
                  message:
                      "Once your Connectors team matches you to a franchise "
                      "opportunity, it'll show up here.",
                );
              }

              return Column(
                children: [
                  for (var i = 0; i < opportunities.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.md),
                    Reveal(
                      index: i,
                      child: _OpportunityCard(opportunity: opportunities[i]),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _OpportunityCard extends StatelessWidget {
  final FranchiseOpportunity opportunity;

  const _OpportunityCard({required this.opportunity});

  @override
  Widget build(BuildContext context) {
    final location = [
      opportunity.territory,
      opportunity.city,
    ].where((s) => s != null && s.isNotEmpty).join(', ');

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  opportunity.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.violet50,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  franchiseStatusLabels[opportunity.status] ??
                      opportunity.status,
                  style: Theme.of(
                    context,
                  ).textTheme.labelMedium?.copyWith(color: AppColors.violet600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              const Icon(
                Icons.storefront_outlined,
                size: 14,
                color: AppColors.grey300,
              ),
              const SizedBox(width: 4),
              Text(
                opportunity.brandName,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
              ),
            ],
          ),
          if (location.isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 14,
                  color: AppColors.grey300,
                ),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
                ),
              ],
            ),
          ],
          if (opportunity.investmentDisplay != null ||
              opportunity.spaceRequiredSqft != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (opportunity.spaceRequiredSqft != null) ...[
                  const Icon(
                    Icons.square_foot_rounded,
                    size: 15,
                    color: AppColors.violet400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${opportunity.spaceRequiredSqft} sq ft',
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ],
                if (opportunity.spaceRequiredSqft != null &&
                    opportunity.investmentDisplay != null)
                  const SizedBox(width: 14),
                if (opportunity.investmentDisplay != null)
                  Expanded(
                    child: Text(
                      opportunity.investmentDisplay!,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.violet600,
                      ),
                    ),
                  ),
              ],
            ),
          ],
          if (opportunity.description != null) ...[
            const SizedBox(height: 10),
            Text(
              opportunity.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (opportunity.note != null) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                opportunity.note!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => showInquireSheet(
                context,
                subject: '${opportunity.brandName} — ${opportunity.title}',
              ),
              child: const Text('Ask about this'),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;

  const _StatusMessage({
    required this.message,
    this.icon = Icons.wifi_off_rounded,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.grey300, size: 36),
          const SizedBox(height: 14),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 18),
            OutlinedButton(onPressed: onRetry, child: const Text('Try again')),
          ],
        ],
      ),
    );
  }
}

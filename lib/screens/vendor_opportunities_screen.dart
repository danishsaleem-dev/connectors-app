import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/api_client.dart';
import '../data/vendor_opportunity.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/page_header.dart';
import '../widgets/reveal.dart';

/// The vendor role's Opportunities tab content — see opportunities_screen
/// .dart, where the tab body swaps to this entirely instead of the
/// brand/franchisee category grid, same pattern as landlord/developer's
/// InterestedBody and consultant's RequestsBody. A vendor never browses
/// brands, franchisees or properties the way those roles do — this
/// admin-authored feed is the entire tab.
class VendorOpportunitiesBody extends StatefulWidget {
  const VendorOpportunitiesBody({super.key});

  @override
  State<VendorOpportunitiesBody> createState() =>
      _VendorOpportunitiesBodyState();
}

class _VendorOpportunitiesBodyState extends State<VendorOpportunitiesBody> {
  late Future<List<VendorOpportunity>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiClient.fetchVendorOpportunities();
  }

  void _retry() =>
      setState(() => _future = ApiClient.fetchVendorOpportunities());

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
          const PageHeader(
            icon: Icons.work_outline_rounded,
            title: 'Opportunities',
            lead: 'Briefs your Connectors team has put together for you.',
          ),
          const SizedBox(height: AppSpacing.xl),
          FutureBuilder<List<VendorOpportunity>>(
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
                  icon: Icons.work_outline_rounded,
                  message:
                      "Once your Connectors team has a project for you, it'll "
                      "show up here.",
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
  final VendorOpportunity opportunity;

  const _OpportunityCard({required this.opportunity});

  Future<void> _openAttachment(BuildContext context) async {
    final url = opportunity.attachmentUrl;
    if (url == null) return;
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Couldn't open that attachment.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Text(
                _formatDate(opportunity.createdAt),
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: AppColors.grey500),
              ),
            ],
          ),
          if (opportunity.description != null) ...[
            const SizedBox(height: 8),
            Text(
              opportunity.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (opportunity.attachmentUrl != null) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: OutlinedButton.icon(
                onPressed: () => _openAttachment(context),
                icon: const Icon(Icons.attach_file_rounded, size: 16),
                label: const Text('View attachment'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _formatDate(DateTime date) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

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

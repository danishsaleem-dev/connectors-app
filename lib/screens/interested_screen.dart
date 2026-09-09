import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../data/property_interest.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/enquire_cta.dart';
import '../widgets/page_header.dart';
import '../widgets/reveal.dart';

/// Pushed from the landlord/developer "Interested" quick action — its own
/// Scaffold since it's a fresh full screen, wrapping [InterestedBody].
class InterestedScreen extends StatelessWidget {
  const InterestedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Interested')),
      body: const SafeArea(child: InterestedBody()),
    );
  }
}

/// The same real, admin-curated interest list — also embedded directly in
/// the Opportunities tab for landlord/developer (see opportunities_screen
/// .dart), which is why this doesn't own a Scaffold: a tab body already
/// lives inside AppShell's one Scaffold, same reasoning as ConsultantsBody/
/// PartnersBody.
///
/// [showHeader] adds the tab's own PageHeader — on when embedded as a full
/// tab (replacing the generic "Opportunities" header), off for the pushed
/// screen above, which already has an AppBar title doing that job.
class InterestedBody extends StatefulWidget {
  final bool showHeader;

  const InterestedBody({super.key, this.showHeader = false});

  @override
  State<InterestedBody> createState() => _InterestedBodyState();
}

class _InterestedBodyState extends State<InterestedBody> {
  late Future<List<PropertyInterest>> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiClient.fetchInterests();
  }

  void _retry() => setState(() => _future = ApiClient.fetchInterests());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PropertyInterest>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final header = widget.showHeader
            ? const Padding(
                padding: EdgeInsets.only(bottom: AppSpacing.xl),
                child: PageHeader(
                  icon: Icons.visibility_rounded,
                  title: 'Interested',
                  lead: 'Who Connectors has matched to your properties.',
                ),
              )
            : null;

        if (snapshot.hasError) {
          return _wrap(
            header,
            _StatusMessage(
              message: snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : "Couldn't load this. Please try again.",
              onRetry: _retry,
            ),
          );
        }
        final interests = snapshot.data ?? const [];
        if (interests.isEmpty) {
          return _wrap(
            header,
            const _StatusMessage(
              icon: Icons.visibility_outlined,
              message:
                  "Once a brand, franchisee or investor shows interest in one of "
                  "your properties, they'll show up here.",
            ),
          );
        }

        return _wrap(
          header,
          Column(
            children: [
              for (var i = 0; i < interests.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                Reveal(index: i, child: _InterestCard(interest: interests[i])),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _wrap(Widget? header, Widget child) {
    if (header == null) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.page,
          AppSpacing.md,
          AppSpacing.page,
          AppSpacing.section,
        ),
        child: child,
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, 0, AppSpacing.page, AppSpacing.section),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [header, child]),
    );
  }
}

class _InterestCard extends StatelessWidget {
  final PropertyInterest interest;

  const _InterestCard({required this.interest});

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
                  interest.propertyTitle,
                  maxLines: 1,
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
                  orgTypeLabel(interest.organizationType),
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
              const Icon(Icons.place_outlined, size: 14, color: AppColors.grey300),
              const SizedBox(width: 4),
              Text(
                interest.propertyCity,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.grey50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.handshake_outlined, size: 16, color: AppColors.violet600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        interest.organizationName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                if (interest.note != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    interest.note!,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => showInquireSheet(
                context,
                subject: 'Interest from ${interest.organizationName} — ${interest.propertyTitle}',
              ),
              child: const Text('Message us about this'),
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

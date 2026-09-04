import 'package:flutter/material.dart';
import '../data/analytics.dart';
import '../data/api_client.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/reveal.dart';

/// The per-account analytics screen — real numbers only. See
/// getOrgAnalytics's doc comment (server side) for exactly what backs each
/// figure and why "profile views" and "introductions" aren't here: nothing
/// in the product tracks page views or discrete introduction events yet,
/// so rather than inventing those two the screen only shows what's
/// genuinely measurable — the org's own message thread, and the favorites
/// feature in both directions.
class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  late Future<OrgAnalytics> _future;

  @override
  void initState() {
    super.initState();
    _future = ApiClient.fetchAnalytics();
  }

  void _retry() => setState(() => _future = ApiClient.fetchAnalytics());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Analytics')),
      body: SafeArea(
        child: FutureBuilder<OrgAnalytics>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return _StatusMessage(
                message: snapshot.error is ApiException
                    ? (snapshot.error as ApiException).message
                    : "Couldn't load your analytics. Please try again.",
                onRetry: _retry,
              );
            }

            final data = snapshot.data!;
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.page,
                AppSpacing.md,
                AppSpacing.page,
                AppSpacing.section,
              ),
              children: [
                Text(
                  'Last 30 days',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                Reveal(index: 0, child: _StatGrid(data: data)),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Messages by week',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: AppSpacing.md),
                Reveal(
                  index: 1,
                  child: _BarChartCard(weeks: data.messagesByWeek),
                ),
                if (data.topProperties.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Your top listings',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Reveal(
                    index: 2,
                    child: _TopListCard(properties: data.topProperties),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatGrid extends StatelessWidget {
  final OrgAnalytics data;

  const _StatGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (
        icon: Icons.outbox_outlined,
        label: 'Messages sent',
        value: '${data.messagesSent30d}',
        delta: OrgAnalytics.delta(
          data.messagesSent30d,
          data.messagesSentPrev30d,
        ),
      ),
      (
        icon: Icons.mark_email_unread_outlined,
        label: 'Replies received',
        value: '${data.repliesReceived30d}',
        delta: OrgAnalytics.delta(
          data.repliesReceived30d,
          data.repliesReceivedPrev30d,
        ),
      ),
      (
        icon: Icons.bookmark_border_rounded,
        label: 'Saved by you',
        value: '${data.savedByYou}',
        delta: null,
      ),
      (
        icon: Icons.favorite_border_rounded,
        label: 'Saved by others',
        value: '${data.savedByOthers}',
        delta: null,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisExtent: 124,
      ),
      itemCount: stats.length,
      itemBuilder: (context, i) => _StatCard(stat: stats[i]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final ({IconData icon, String label, String value, String? delta}) stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final delta = stat.delta;
    final up = delta != null && delta.startsWith('+');

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stat.icon, size: 20, color: AppColors.violet600),
          const Spacer(),
          Text(stat.value, style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  stat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.grey500,
                    fontSize: 12.5,
                  ),
                ),
              ),
              if (delta != null)
                Text(
                  delta,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: up
                        ? const Color(0xFF1B7F4E)
                        : const Color(0xFFB3261E),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Hand-drawn bars rather than a charting package — four values don't
/// justify a dependency, and this keeps full control of the styling.
class _BarChartCard extends StatelessWidget {
  final List<WeekActivity> weeks;

  const _BarChartCard({required this.weeks});

  @override
  Widget build(BuildContext context) {
    final maxValue = weeks.map((w) => w.count).fold(0, (a, b) => a > b ? a : b);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: SizedBox(
        height: 150,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final week in weeks)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${week.count}',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: AppColors.grey500),
                      ),
                      const SizedBox(height: 6),
                      // Fraction of the 100px band the tallest bar fills,
                      // floored so a small (or zero) value still reads as a
                      // bar rather than disappearing entirely.
                      Container(
                        height:
                            24 +
                            (maxValue == 0 ? 0 : (week.count / maxValue) * 76),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [AppColors.violet400, AppColors.violet600],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        week.label,
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(color: AppColors.grey500),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TopListCard extends StatelessWidget {
  final List<TopProperty> properties;

  const _TopListCard({required this.properties});

  @override
  Widget build(BuildContext context) {
    final maxSaves = properties
        .map((p) => p.saves)
        .fold(0, (a, b) => a > b ? a : b);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (var i = 0; i < properties.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            Builder(
              builder: (context) {
                final property = properties[i];
                final fraction = maxSaves == 0
                    ? 0.0
                    : property.saves / maxSaves;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${property.title} · ${property.city}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Text(
                          property.saves == 1
                              ? '1 save'
                              : '${property.saves} saves',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: AppColors.grey500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: fraction,
                        minHeight: 6,
                        backgroundColor: AppColors.grey100,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.violet600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const _StatusMessage({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.wifi_off_rounded,
              color: AppColors.grey300,
              size: 40,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: onRetry,
                child: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

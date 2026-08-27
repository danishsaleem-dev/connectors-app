import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/reveal.dart';

/// The per-role analytics dashboard the business-logic doc calls for.
///
/// **Every number on this screen is invented.** There is no analytics
/// pipeline, no event tracking, and nothing that counts views or enquiries
/// for a real account. That matters more here than on the other preview
/// screens: figures like "profile views" look like operating data someone
/// could make a decision on, so the screen is labelled as sample data
/// rather than quietly presenting fiction as this account's performance.
class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.page),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Sample data',
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: AppColors.grey500),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.section,
          ),
          children: [
            Text('Last 30 days', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            const Reveal(index: 0, child: _StatGrid()),
            const SizedBox(height: AppSpacing.xl),
            Text('Enquiries by week', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            const Reveal(index: 1, child: _BarChartCard()),
            const SizedBox(height: AppSpacing.xl),
            Text('Top locations', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            const Reveal(index: 2, child: _TopListCard()),
          ],
        ),
      ),
    );
  }
}

class _Stat {
  final IconData icon;
  final String label;
  final String value;
  final String delta;
  final bool up;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.delta,
    required this.up,
  });
}

const _stats = [
  _Stat(
    icon: Icons.visibility_outlined,
    label: 'Profile views',
    value: '1,284',
    delta: '+12%',
    up: true,
  ),
  _Stat(
    icon: Icons.mark_email_unread_outlined,
    label: 'Enquiries',
    value: '46',
    delta: '+8%',
    up: true,
  ),
  _Stat(
    icon: Icons.bookmark_border_rounded,
    label: 'Saved by others',
    value: '73',
    delta: '-3%',
    up: false,
  ),
  _Stat(
    icon: Icons.handshake_outlined,
    label: 'Introductions',
    value: '9',
    delta: '+2',
    up: true,
  ),
];

class _StatGrid extends StatelessWidget {
  const _StatGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: AppSpacing.sm,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisExtent: 124,
      ),
      itemCount: _stats.length,
      itemBuilder: (context, i) => _StatCard(stat: _stats[i]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final _Stat stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final deltaColor = stat.up ? const Color(0xFF1B7F4E) : const Color(0xFFB3261E);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(stat.icon, size: 20, color: AppColors.violet600),
          const Spacer(),
          Text(
            stat.value,
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 2),
          Row(
            children: [
              Expanded(
                child: Text(
                  stat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.grey500, fontSize: 12.5),
                ),
              ),
              Text(
                stat.delta,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: deltaColor),
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
  const _BarChartCard();

  static const _weeks = [
    ('W1', 8),
    ('W2', 14),
    ('W3', 11),
    ('W4', 13),
  ];

  @override
  Widget build(BuildContext context) {
    final maxValue = _weeks.map((w) => w.$2).reduce((a, b) => a > b ? a : b);

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
      child: SizedBox(
        height: 150,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (final (label, value) in _weeks)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '$value',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
                            ?.copyWith(color: AppColors.grey500),
                      ),
                      const SizedBox(height: 6),
                      // Fraction of the 100px band the tallest bar fills,
                      // floored so a small value still reads as a bar.
                      Container(
                        height: 24 + (value / maxValue) * 76,
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
                        label,
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium
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
  const _TopListCard();

  static const _rows = [
    ('London, United Kingdom', 0.82),
    ('Lahore, Pakistan', 0.61),
    ('Dallas, United States', 0.44),
    ('Manchester, United Kingdom', 0.28),
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          for (var i = 0; i < _rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _rows[i].$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${(_rows[i].$2 * 100).round()}%',
                      style: Theme.of(context)
                          .textTheme
                          .labelLarge
                          ?.copyWith(color: AppColors.grey500),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: _rows[i].$2,
                    minHeight: 6,
                    backgroundColor: AppColors.grey100,
                    valueColor: const AlwaysStoppedAnimation(AppColors.violet600),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/reveal.dart';

/// The membership-plans screen the business-logic doc calls for.
///
/// UI only, and worth being blunt about in code: **there is no payment
/// infrastructure anywhere in this product** — no billing provider, no
/// prices agreed, no entitlements enforced. The tiers and figures below
/// are placeholders to show the shape of the screen. Nothing here should
/// be quoted to a customer, and the screen says as much at the bottom so
/// nobody reads it as a real price list.
class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Membership')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            AppSpacing.section,
          ),
          children: [
            Text('Choose your plan', style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 6),
            Text(
              'Upgrade for wider reach, priority placement and a dedicated '
              'point of contact.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.grey500),
            ),
            const SizedBox(height: AppSpacing.xl),
            for (var i = 0; i < _plans.length; i++) ...[
              if (i > 0) const SizedBox(height: AppSpacing.md),
              Reveal(index: i, child: _PlanCard(plan: _plans[i])),
            ],
            const SizedBox(height: AppSpacing.xl),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.grey300),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Indicative pricing only — plans are not final and billing '
                    'is not enabled yet.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppColors.grey500),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Plan {
  final String name;
  final String price;
  final String cadence;
  final String tagline;
  final List<String> features;
  final bool current;
  final bool featured;

  const _Plan({
    required this.name,
    required this.price,
    required this.cadence,
    required this.tagline,
    required this.features,
    this.current = false,
    this.featured = false,
  });
}

const _plans = [
  _Plan(
    name: 'Starter',
    price: 'Free',
    cadence: '',
    tagline: 'Everything you need to get listed.',
    features: [
      'One active listing',
      'Browse all opportunities',
      'Standard response times',
    ],
    current: true,
  ),
  _Plan(
    name: 'Growth',
    price: '\$149',
    cadence: '/ month',
    tagline: 'For brands actively expanding.',
    features: [
      'Up to 10 active listings',
      'Priority placement in search',
      'Featured badge on listings',
      'Dedicated account contact',
    ],
    featured: true,
  ),
  _Plan(
    name: 'Enterprise',
    price: 'Custom',
    cadence: '',
    tagline: 'Multi-market and master franchise.',
    features: [
      'Unlimited listings',
      'Full market analytics',
      'Introductions handled by our team',
      'Onboarding and training support',
    ],
  ),
];

class _PlanCard extends StatelessWidget {
  final _Plan plan;

  const _PlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    final onDark = plan.featured;
    final titleColor = onDark ? AppColors.white : AppColors.ink;
    final mutedColor =
        onDark ? AppColors.white.withValues(alpha: 0.72) : AppColors.grey500;

    return AppCard(
      radius: 20,
      padding: const EdgeInsets.all(20),
      color: onDark ? AppColors.violet700 : AppColors.white,
      onTap: plan.current
          ? null
          : () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                plan.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: titleColor),
              ),
              const SizedBox(width: 8),
              if (plan.current)
                _Tag(text: 'Current', fg: AppColors.violet600, bg: AppColors.violet50)
              else if (plan.featured)
                const _Tag(text: 'Popular', fg: AppColors.violet700, bg: AppColors.white),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            plan.tagline,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: mutedColor),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                plan.price,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall
                    ?.copyWith(color: titleColor),
              ),
              if (plan.cadence.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  plan.cadence,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: mutedColor),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),
          for (final feature in plan.features)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_rounded,
                    size: 17,
                    color: onDark ? AppColors.white : AppColors.violet600,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      feature,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: onDark ? AppColors.white : AppColors.ink),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: plan.current
                ? OutlinedButton(
                    onPressed: null,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Your current plan'),
                  )
                : ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: onDark ? AppColors.white : AppColors.violet600,
                      foregroundColor: onDark ? AppColors.violet700 : AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon')),
                    ),
                    child: Text(plan.price == 'Custom' ? 'Talk to us' : 'Choose ${plan.name}'),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color fg;
  final Color bg;

  const _Tag({required this.text, required this.fg, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: fg),
      ),
    );
  }
}

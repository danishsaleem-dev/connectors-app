import 'package:flutter/material.dart';
import '../data/account_type_config.dart';
import '../data/api_client.dart';
import '../data/auth_state.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/eyebrow.dart';
import '../widgets/reveal.dart';
import 'chat_screen.dart';

const _roleLabels = {
  'brand': 'Brand',
  'franchisee': 'Franchisee',
  'landlord': 'Landlord',
  'developer': 'Mall / Developer',
  'investor': 'Investor',
  'vendor': 'Vendor',
  'consultant': 'Consultant',
};

void _openAction(BuildContext context, HomeAction action) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => action.hasOwnScaffold
          ? action.buildScreen()
          : Scaffold(
              appBar: AppBar(title: Text(action.title)),
              body: SafeArea(child: SingleChildScrollView(child: action.buildScreen())),
            ),
    ),
  );
}

/// Home leads with who's signed in and what they can do — no banner, no app
/// bar branding, both removed per feedback that they were empty ceremony
/// ahead of anything useful. Just a profile row (who you are), a chat
/// entry point, and the action cards that matter for this account type.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AuthResult?>(
      valueListenable: Auth.session,
      builder: (context, session, _) {
        final config = configFor(session?.orgType);
        final roleLabel = session?.isAdmin == true
            ? 'Connectors team'
            : (_roleLabels[session?.orgType] ?? 'Member');
        final hasMultipleActions = config.homeActions.length > 1;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.page,
            AppSpacing.md,
            AppSpacing.page,
            110,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: AppColors.violet600,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      (session?.name.trim().isNotEmpty ?? false)
                          ? session!.name.trim()[0].toUpperCase()
                          : '?',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: AppColors.white),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session?.name ?? '',
                          style: Theme.of(context).textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          roleLabel,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppColors.grey500),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: AppColors.violet50,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).push(ChatScreen.route()),
                      child: const Padding(
                        padding: EdgeInsets.all(11),
                        child: Icon(
                          Icons.auto_awesome_rounded,
                          color: AppColors.violet600,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.section),
              if (hasMultipleActions) ...[
                const Reveal(index: 0, child: _PromoBanner()),
                const SizedBox(height: AppSpacing.heading),
                Reveal(
                  index: 1,
                  child: _ActionGrid(actions: config.homeActions),
                ),
                const SizedBox(height: AppSpacing.lg),
                Reveal(index: 2, child: _HighlightRow()),
                const SizedBox(height: AppSpacing.lg),
                const Reveal(index: 3, child: _MarketingBanner()),
                const SizedBox(height: AppSpacing.section),
                const Eyebrow('All actions'),
                const SizedBox(height: AppSpacing.sm),
                Text('Everything in one place.', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: AppSpacing.heading),
                for (var i = 0; i < config.homeActions.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  Reveal(index: i + 4, child: _DetailedActionCard(action: config.homeActions[i])),
                ],
              ] else ...[
                const Eyebrow('Get started'),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  config.homeActions.first.title,
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: AppSpacing.heading),
                Reveal(index: 0, child: _ActionRow(action: config.homeActions.first)),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Replaces the plain "Get started" eyebrow for account types with more
/// than one action (brand, today) — a compact violet banner rather than a
/// second big marketing moment, since Home was deliberately cut down to
/// stay dense-free.
class _PromoBanner extends StatelessWidget {
  const _PromoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.violet700, AppColors.violet600],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Expand Smarter,\nGrow Faster.',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your complete platform for brand growth.',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.white.withValues(alpha: 0.78)),
          ),
        ],
      ),
    );
  }
}

/// The compact icon-tile row — one square per action, all four visible at
/// once rather than a full-width scrollable list, for accounts with
/// several things to do from Home (only brand, today).
class _ActionGrid extends StatelessWidget {
  final List<HomeAction> actions;

  const _ActionGrid({required this.actions});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(width: AppSpacing.sm),
          Expanded(child: _ActionTile(action: actions[i])),
        ],
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final HomeAction action;

  const _ActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openAction(context, action),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: cardShadow(opacity: 0.05),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.violet600.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(action.icon, color: AppColors.violet600, size: 18),
              ),
              const SizedBox(height: 8),
              Text(
                action.tileLabel,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Two informational highlight cards — deliberately not tappable. Neither
/// "franchise legends" nor "royalty tracking" has a real feature behind it
/// yet, so this is presented as a visual only, not a button that would
/// promise something that isn't built. IntrinsicHeight + stretch keeps both
/// cards the same height regardless of which title wraps to two lines.
class _HighlightRow extends StatelessWidget {
  const _HighlightRow();

  @override
  Widget build(BuildContext context) {
    return const IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _HighlightCard(
              icon: Icons.workspace_premium_rounded,
              title: 'Franchise Legends',
              statHeadline: '100%',
              statSubtitle: 'Franchisor Support',
              accentColor: AppColors.violet600,
            ),
          ),
          SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _HighlightCard(
              icon: Icons.verified_user_rounded,
              title: 'Franchise Royalties',
              statHeadline: 'Secure',
              statSubtitle: 'Platform Services',
              accentColor: AppColors.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String statHeadline;
  final String statSubtitle;
  final Color accentColor;

  const _HighlightCard({
    required this.icon,
    required this.title,
    required this.statHeadline,
    required this.statSubtitle,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        color: AppColors.white,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(painter: _DotPatternPainter(color: accentColor)),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: accentColor, shape: BoxShape.circle),
                    child: Icon(icon, color: AppColors.white, size: 16),
                  ),
                  const SizedBox(height: 10),
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          statHeadline,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: AppColors.white),
                        ),
                        Text(
                          statSubtitle,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.white.withValues(alpha: 0.65),
                                fontSize: 11.5,
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A faint dot grid instead of a flat fill — texture rather than a solid
/// colour block, staying inside the accent colour passed in so it reads as
/// a deliberate surface, not decoration for its own sake.
class _DotPatternPainter extends CustomPainter {
  final Color color;

  const _DotPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color.withValues(alpha: 0.05);
    const spacing = 14.0;
    const radius = 1.3;
    for (var y = spacing / 2; y < size.height; y += spacing) {
      for (var x = spacing / 2; x < size.width; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotPatternPainter oldDelegate) => oldDelegate.color != color;
}

/// Closing banner — its one action is real (opens the existing chat
/// screen), unlike the two highlight cards above it.
class _MarketingBanner extends StatelessWidget {
  const _MarketingBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'We scale local marketing for multi-location brands.',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () => Navigator.of(context).push(ChatScreen.route()),
            child: const Text('Ask us'),
          ),
        ],
      ),
    );
  }
}

/// The full descriptive version of the same actions the icon grid already
/// shows compactly — title, body copy and a double-chevron badge instead
/// of icon-left/chevron-right, matching the reference's row-card layout.
class _DetailedActionCard extends StatelessWidget {
  final HomeAction action;

  const _DetailedActionCard({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openAction(context, action),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: cardShadow(opacity: 0.05),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(action.title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 3),
                    Text(
                      action.body,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.grey500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.violet200),
                ),
                child: const Icon(Icons.keyboard_double_arrow_right_rounded,
                    color: AppColors.violet600, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final HomeAction action;

  const _ActionRow({required this.action});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openAction(context, action),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            boxShadow: cardShadow(),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.violet50,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(action.icon, color: AppColors.violet600, size: 21),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(action.title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 2),
                    Text(
                      action.body,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.grey500),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Icon(Icons.chevron_right_rounded, color: AppColors.grey300),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../data/account_type_config.dart';
import '../data/api_client.dart';
import '../data/auth_state.dart';
import '../data/site_data.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/eyebrow.dart';
import '../widgets/feature_card.dart';
import '../widgets/reveal.dart';
import 'chat_screen.dart';
import 'contact_screen.dart';

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
                Reveal(
                  index: 0,
                  child: _PromoBanner(
                    headline: config.promoHeadline!,
                    subtitle: config.promoSubtitle!,
                  ),
                ),
                const SizedBox(height: AppSpacing.heading),
                Reveal(
                  index: 1,
                  child: _ActionGrid(actions: config.homeActions),
                ),
                const SizedBox(height: AppSpacing.lg),
                Reveal(
                  index: 2,
                  child: _HighlightRow(
                    cards: session?.orgType == 'brand'
                        ? _franchiseHighlights
                        : _trustHighlights(context),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Reveal(
                  index: 3,
                  child: _MarketingBanner(text: config.marketingBannerText!),
                ),
                const SizedBox(height: AppSpacing.section),
                const Eyebrow('All actions'),
                const SizedBox(height: AppSpacing.sm),
                Text('Everything in one place.', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: AppSpacing.heading),
                for (var i = 0; i < config.homeActions.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  Reveal(
                    index: i + 4,
                    child: FeatureCard(
                      title: config.homeActions[i].title,
                      body: config.homeActions[i].body,
                      onTap: () => _openAction(context, config.homeActions[i]),
                    ),
                  ),
                ],
              ] else ...[
                // Single-action types (everyone but brand) get the same
                // visual language — banner, feature card, trust cards,
                // closing CTA — just built around their one real action
                // instead of four. Banner copy is the action's own
                // title/body, not new marketing copy, so nothing here
                // promises anything the account type doesn't already have.
                Reveal(
                  index: 0,
                  child: _PromoBanner(
                    headline: '${config.homeActions.first.title}.',
                    subtitle: config.homeActions.first.body,
                  ),
                ),
                const SizedBox(height: AppSpacing.heading),
                Reveal(
                  index: 1,
                  child: FeatureCard(
                    title: config.homeActions.first.title,
                    body: config.homeActions.first.body,
                    onTap: () => _openAction(context, config.homeActions.first),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Reveal(index: 2, child: _HighlightRow(cards: _trustHighlights(context))),
                const SizedBox(height: AppSpacing.lg),
                const Reveal(
                  index: 3,
                  child: _MarketingBanner(text: "Questions before you start? We're here to help."),
                ),
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
/// stay dense-free. Also used by every single-action type now, with the
/// headline/subtitle built from that type's own action copy.
class _PromoBanner extends StatelessWidget {
  final String headline;
  final String subtitle;

  const _PromoBanner({required this.headline, required this.subtitle});

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
            headline,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
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

/// The compact icon-tile grid — one square per action, all visible at once
/// rather than a full-width scrollable list, for accounts with several
/// things to do from Home. Fixed-width tiles wrapped into rows (rather
/// than always stretching to fill one row) so a 2-action type doesn't get
/// two oversized tiles and a 5-action type doesn't get five cramped ones —
/// account types now range from 2 to 5 actions.
class _ActionGrid extends StatelessWidget {
  final List<HomeAction> actions;

  const _ActionGrid({required this.actions});

  @override
  Widget build(BuildContext context) {
    final columns = actions.length <= 4 ? actions.length : 3;

    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - AppSpacing.sm * (columns - 1)) / columns;
        return Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final action in actions)
              SizedBox(width: tileWidth, child: _ActionTile(action: action)),
          ],
        );
      },
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

/// One highlight card's content — deliberately not always tappable.
/// `onTap` is null for purely informational cards (like the franchise
/// program badges, which have no real feature behind them yet); pass one
/// when the card is fronting something real (like Contact).
class _HighlightData {
  final IconData icon;
  final String title;
  final String statHeadline;
  final String statSubtitle;
  final Color accentColor;
  final VoidCallback? onTap;

  const _HighlightData({
    required this.icon,
    required this.title,
    required this.statHeadline,
    required this.statSubtitle,
    required this.accentColor,
    this.onTap,
  });
}

const _franchiseHighlights = [
  _HighlightData(
    icon: Icons.workspace_premium_rounded,
    title: 'Franchise Legends',
    statHeadline: '100%',
    statSubtitle: 'Franchisor Support',
    accentColor: AppColors.violet600,
  ),
  _HighlightData(
    icon: Icons.verified_user_rounded,
    title: 'Franchise Royalties',
    statHeadline: 'Secure',
    statSubtitle: 'Platform Services',
    accentColor: AppColors.ink,
  ),
];

/// Shared by every single-action account type — real, established facts
/// (office count, response-time promise already used across the enquiry
/// forms) rather than invented features, since these types don't have a
/// franchise-program equivalent to show off.
List<_HighlightData> _trustHighlights(BuildContext context) => [
      _HighlightData(
        icon: Icons.public_rounded,
        title: '${SiteData.offices.length} Offices, One Team',
        statHeadline: 'Global',
        statSubtitle: 'UK, US & Pakistan',
        accentColor: AppColors.violet600,
        onTap: () =>
            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ContactScreen())),
      ),
      const _HighlightData(
        icon: Icons.bolt_rounded,
        title: 'Fast Response',
        statHeadline: '1 Day',
        statSubtitle: 'Typical review time',
        accentColor: AppColors.ink,
      ),
    ];

/// A pair of informational highlight cards. IntrinsicHeight + stretch
/// keeps both the same height regardless of which title wraps to two
/// lines.
class _HighlightRow extends StatelessWidget {
  final List<_HighlightData> cards;

  const _HighlightRow({required this.cards});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: AppSpacing.sm),
            Expanded(child: _HighlightCard(data: cards[i])),
          ],
        ],
      ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final _HighlightData data;

  const _HighlightCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final icon = data.icon;
    final title = data.title;
    final statHeadline = data.statHeadline;
    final statSubtitle = data.statSubtitle;
    final accentColor = data.accentColor;

    final content = ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        // A light tint of the card's own accent, not plain white — enough
        // to read as "coloured" without going back to the heavy solid
        // fill this replaced.
        color: accentColor.withValues(alpha: 0.06),
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

    if (data.onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: data.onTap,
        borderRadius: BorderRadius.circular(18),
        child: content,
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
    final paint = Paint()..color = color.withValues(alpha: 0.14);
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
  final String text;

  const _MarketingBanner({required this.text});

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
              text,
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



import 'package:flutter/material.dart';
import '../data/api_client.dart';
import '../screens/audience_screen.dart';
import '../screens/brands_screen.dart';
import '../screens/coming_soon_screen.dart';
import '../screens/consultants_screen.dart';
import '../screens/franchise_opportunities_screen.dart';
import '../screens/interested_screen.dart';
import '../screens/locations_screen.dart';
import '../screens/messages_screen.dart';
import '../screens/partners_screen.dart';
import '../screens/service_info_screen.dart';

/// One card in Home's action list — title, a one-line description, an icon,
/// and what it opens (pushed, since Home isn't tied to any one bottom-nav
/// tab index).
class HomeAction {
  final String title;
  final String body;
  final IconData icon;
  final Widget Function() buildScreen;

  /// False (the default) means buildScreen returns chrome-less body content
  /// — Home wraps it in a generic Scaffold + SingleChildScrollView, same as
  /// buildAudienceScreen's own static content. Set true when buildScreen
  /// already provides its own Scaffold with independent scrolling state
  /// (e.g. a FutureBuilder-backed list) — nesting a ListView inside the
  /// generic wrapper's SingleChildScrollView would be a layout error, not
  /// just redundant chrome.
  final bool hasOwnScaffold;

  /// A one-word label for the compact icon-grid tile used when an account
  /// type has more than one action — `title` alone is too long to fit a
  /// small square tile. Falls back to `title` when unset, so single-action
  /// types (which render a full row, not the grid) never need to bother
  /// setting it.
  final String? shortLabel;

  const HomeAction({
    required this.title,
    required this.body,
    required this.icon,
    required this.buildScreen,
    this.hasOwnScaffold = false,
    this.shortLabel,
  });

  String get tileLabel => shortLabel ?? title;
}

/// What a signed-in account of a given type sees on Home. Every org is
/// exactly one of these seven types, so — unlike the old app, which showed
/// every visitor all four audience doors because it didn't yet know who
/// they were — the app can now show exactly what this account actually
/// needs. (The bottom nav's second tab used to be per-type too; it's now
/// the shared Opportunities hub for everyone — see OpportunitiesScreen.)
class AccountTypeConfig {
  final List<HomeAction> homeActions;

  /// Only meaningful when homeActions.length > 1 — Home derives the promo
  /// banner/CTA copy from the one action directly for single-action types,
  /// so these stay null there.
  final String? promoHeadline;
  final String? promoSubtitle;
  final String? marketingBannerText;

  const AccountTypeConfig({
    required this.homeActions,
    this.promoHeadline,
    this.promoSubtitle,
    this.marketingBannerText,
  });
}

final Map<String, AccountTypeConfig> accountTypeConfigs = {
  'brand': AccountTypeConfig(
    promoHeadline: 'Expand Smarter,\nGrow Faster.',
    promoSubtitle: 'Your complete platform for brand growth.',
    marketingBannerText: 'We scale local marketing for multi-location brands.',
    homeActions: [
      HomeAction(
        title: 'Available Locations',
        body: 'Browse open retail and commercial space across our markets.',
        icon: Icons.location_city_rounded,
        buildScreen: () => const LocationsScreen(showRequestCta: true),
        hasOwnScaffold: true,
        shortLabel: 'Location',
      ),
      HomeAction(
        title: 'Find Franchisees',
        body:
            'Connect with franchisees ready to open your brand in a new territory.',
        icon: Icons.handshake_rounded,
        buildScreen: () => buildAudienceScreen('for-franchise'),
        shortLabel: 'Franchisees',
      ),
      HomeAction(
        title: 'Find Investors',
        body:
            "Connect with potential investors to accelerate your brand's future growth.",
        icon: Icons.trending_up_rounded,
        buildScreen: () => buildAudienceScreen('for-investors'),
        shortLabel: 'Investors',
      ),
      HomeAction(
        title: 'Marketing Services',
        body: 'Local marketing support built for multi-location brands.',
        icon: Icons.campaign_rounded,
        buildScreen: () => const ServiceInfoScreen(
          title: 'Marketing Services',
          icon: Icons.campaign_rounded,
          lead: 'We scale local marketing for multi-location brands.',
          body:
              'Every location has its own local audience — marketing support that '
              'works market-by-market, not one campaign stretched across all of '
              'them. Get in touch and our team will walk you through what fits '
              'your brand.',
          enquireMessage: 'Ask about marketing support for your brand.',
        ),
        hasOwnScaffold: true,
        shortLabel: 'Digital Marketing',
      ),
      HomeAction(
        title: 'IT Solutions',
        body:
            'Technology built for running a multi-location franchise operation.',
        icon: Icons.memory_rounded,
        buildScreen: () => const ServiceInfoScreen(
          title: 'IT Solutions',
          icon: Icons.memory_rounded,
          lead: 'Technology built for franchise operations.',
          body:
              'From day-to-day systems to the tools your franchisees use — get '
              'in touch and our team will talk through what your brand actually '
              'needs.',
          enquireMessage: 'Ask about technology support for your brand.',
        ),
        hasOwnScaffold: true,
        shortLabel: 'Technology Partners',
      ),
    ],
  ),
  'franchisee': AccountTypeConfig(
    promoHeadline: 'Find Your Franchise,\nFaster.',
    promoSubtitle:
        'Browse live opportunities or apply directly — whichever gets you moving.',
    marketingBannerText: "Questions before you apply? We're here to help.",
    homeActions: [
      HomeAction(
        title: 'Opportunities',
        body:
            'Franchise opportunities your Connectors team has matched you to.',
        icon: Icons.workspace_premium_rounded,
        buildScreen: () => const FranchiseOpportunitiesScreen(),
        hasOwnScaffold: true,
        shortLabel: 'Opportunities',
      ),
      HomeAction(
        title: 'Apply for Franchise',
        body: 'Your budget, territory and industry interest.',
        icon: Icons.assignment_turned_in_rounded,
        buildScreen: () => buildAudienceScreen('for-franchise'),
        shortLabel: 'Apply',
      ),
      HomeAction(
        title: 'Contact Brand',
        body: "Message the brands you're talking to, in one place.",
        icon: Icons.forum_rounded,
        buildScreen: () => const MessagesScreen(),
        hasOwnScaffold: true,
        shortLabel: 'Messages',
      ),
    ],
  ),
  'landlord': AccountTypeConfig(
    promoHeadline: 'Fill Your Space,\nFaster.',
    promoSubtitle: 'Submit your property and see who wants it.',
    marketingBannerText:
        "Questions about listing your space? We're here to help.",
    homeActions: [
      HomeAction(
        title: 'Submit Property',
        body: 'We bring the brands to it.',
        icon: Icons.apartment_rounded,
        buildScreen: () => buildAudienceScreen('for-landlords'),
        shortLabel: 'Submit',
      ),
      HomeAction(
        title: 'My Properties',
        body: 'Everything you\'ve listed, in one place.',
        icon: Icons.list_alt_rounded,
        buildScreen: () => LocationsScreen(
          appBarTitle: 'My Properties',
          fetch: ApiClient.fetchMyProperties,
          emptyMessage: "You haven't listed any properties yet.",
          showFavorite: false,
        ),
        hasOwnScaffold: true,
        shortLabel: 'My Properties',
      ),
      HomeAction(
        title: 'Interested Organizations',
        body: 'See which brands, franchisees or investors want your property.',
        icon: Icons.visibility_rounded,
        buildScreen: () => const InterestedScreen(),
        hasOwnScaffold: true,
        shortLabel: 'Interested',
      ),
    ],
  ),
  // Shares the landlord form — the website's own "for-landlords" audience
  // is already titled "Landlords & Developers" and covers both.
  'developer': AccountTypeConfig(
    promoHeadline: 'Fill Your Mall,\nFaster.',
    promoSubtitle:
        'Tell us what you need, or browse brands actively expanding.',
    marketingBannerText:
        "Questions about your development? We're here to help.",
    homeActions: [
      HomeAction(
        title: 'Request Brand Placement',
        body: 'Tell us the brands you want in your mall or development.',
        icon: Icons.add_business_rounded,
        buildScreen: () => buildAudienceScreen('for-landlords'),
        shortLabel: 'Placement',
      ),
      HomeAction(
        title: 'My Properties',
        body: 'Everything you\'ve listed, in one place.',
        icon: Icons.list_alt_rounded,
        buildScreen: () => LocationsScreen(
          appBarTitle: 'My Properties',
          fetch: ApiClient.fetchMyProperties,
          emptyMessage: "You haven't listed any properties yet.",
          showFavorite: false,
        ),
        hasOwnScaffold: true,
        shortLabel: 'My Properties',
      ),
      HomeAction(
        title: 'View Brand Categories',
        body: 'Browse brands actively expanding, by category.',
        icon: Icons.category_rounded,
        buildScreen: () => const BrandsScreen(title: 'Brand Categories'),
        hasOwnScaffold: true,
        shortLabel: 'Categories',
      ),
      HomeAction(
        title: 'Interested Organizations',
        body: 'See which brands, franchisees or investors want your property.',
        icon: Icons.visibility_rounded,
        buildScreen: () => const InterestedScreen(),
        hasOwnScaffold: true,
        shortLabel: 'Interested',
      ),
    ],
  ),
  'investor': AccountTypeConfig(
    promoHeadline: 'Invest Smarter,\nGrow Together.',
    promoSubtitle: 'Real opportunities, vetted brands, one platform.',
    marketingBannerText: "Questions before you invest? We're here to help.",
    homeActions: [
      HomeAction(
        title: 'Explore Investment Opportunities',
        body: 'Franchise concepts open for new territories and capital.',
        icon: Icons.insights_rounded,
        buildScreen: () => const BrandsScreen(title: 'Franchise Opportunities'),
        hasOwnScaffold: true,
        shortLabel: 'Explore',
      ),
      HomeAction(
        title: 'Connect With Brands',
        body: 'Brands actively expanding and open to new partners.',
        icon: Icons.handshake_rounded,
        buildScreen: () => const BrandsScreen(title: 'Connect With Brands'),
        hasOwnScaffold: true,
        shortLabel: 'Brands',
      ),
      HomeAction(
        title: 'Investment Portfolio',
        body: 'Track the opportunities you back through Connectors.',
        icon: Icons.account_balance_wallet_rounded,
        buildScreen: () => const ComingSoonScreen(
          title: 'Investment Portfolio',
          icon: Icons.account_balance_wallet_rounded,
          message:
              "Once you back an opportunity through Connectors, it'll show "
              'up here.',
        ),
        hasOwnScaffold: true,
        shortLabel: 'Portfolio',
      ),
    ],
  ),
  'vendor': AccountTypeConfig(
    homeActions: [
      HomeAction(
        title: 'The Partners Program',
        body: 'Disciplines, benefits and how the bench works.',
        icon: Icons.diversity_3_rounded,
        buildScreen: () => const PartnersBody(),
      ),
    ],
  ),
  'consultant': AccountTypeConfig(
    homeActions: [
      HomeAction(
        title: 'The consultants roster',
        body: 'Who Connectors helps, and how engagements work.',
        icon: Icons.groups_rounded,
        buildScreen: () => const ConsultantsBody(),
      ),
    ],
  ),
};

/// Falls back to the brand config for an admin account (no organization, so
/// no real type) or any type this map doesn't recognise — admins run the
/// business from the website portal, not this app, so there's nothing
/// meaningfully "primary" to show them here; brand is just a reasonable
/// default rather than a crash.
AccountTypeConfig configFor(String? orgType) =>
    accountTypeConfigs[orgType] ?? accountTypeConfigs['brand']!;

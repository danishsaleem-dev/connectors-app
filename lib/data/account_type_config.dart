import 'package:flutter/material.dart';
import '../screens/audience_screen.dart';
import '../screens/consultants_screen.dart';
import '../screens/locations_screen.dart';
import '../screens/partners_screen.dart';

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

  const HomeAction({
    required this.title,
    required this.body,
    required this.icon,
    required this.buildScreen,
    this.hasOwnScaffold = false,
  });
}

/// What a signed-in account of a given type sees: which nav tab replaces
/// the old generic "Brands/Franchise/Landlords/Investors" set, and which
/// action cards Home leads with. Every org is exactly one of these seven
/// types, so — unlike the old app, which showed every visitor all four
/// audience doors because it didn't yet know who they were — the app can
/// now show exactly what this account actually needs.
class AccountTypeConfig {
  final String tabLabel;
  final IconData tabIcon;
  final IconData tabActiveIcon;
  final List<HomeAction> homeActions;

  /// Builds the tab's body content — no Scaffold/AppBar of its own, since
  /// it's dropped straight into the app shell's IndexedStack, same as the
  /// four audience screens already are.
  final Widget Function() buildPrimaryScreen;

  const AccountTypeConfig({
    required this.tabLabel,
    required this.tabIcon,
    required this.tabActiveIcon,
    required this.homeActions,
    required this.buildPrimaryScreen,
  });
}

final Map<String, AccountTypeConfig> accountTypeConfigs = {
  // The only type with more than one Home action, by explicit request — a
  // brand's three real asks (a location, more franchisees, investors) each
  // land on an existing form rather than needing new ones.
  'brand': AccountTypeConfig(
    tabLabel: 'Locations',
    tabIcon: Icons.storefront_outlined,
    tabActiveIcon: Icons.storefront_rounded,
    buildPrimaryScreen: () => buildAudienceScreen('for-brands'),
    homeActions: [
      HomeAction(
        title: 'Request a Location',
        body: "Submit your preferred expansion location and let opportunities find you.",
        icon: Icons.search_rounded,
        buildScreen: () => buildAudienceScreen('for-brands'),
      ),
      HomeAction(
        title: 'More Franchises?',
        body: 'Explore franchise opportunities and connect with brands ready for expansion.',
        icon: Icons.handshake_rounded,
        buildScreen: () => buildAudienceScreen('for-franchise'),
      ),
      HomeAction(
        title: 'Looking for Investors?',
        body: "Connect with potential investors to accelerate your brand's future growth.",
        icon: Icons.trending_up_rounded,
        buildScreen: () => buildAudienceScreen('for-investors'),
      ),
      HomeAction(
        title: 'Browse Available Locations',
        body: 'See retail and commercial space currently listed with Connectors.',
        icon: Icons.location_city_rounded,
        buildScreen: () => const LocationsScreen(),
        hasOwnScaffold: true,
      ),
    ],
  ),
  'franchisee': AccountTypeConfig(
    tabLabel: 'Franchise',
    tabIcon: Icons.handshake_outlined,
    tabActiveIcon: Icons.handshake_rounded,
    buildPrimaryScreen: () => buildAudienceScreen('for-franchise'),
    homeActions: [
      HomeAction(
        title: 'Find your franchise',
        body: 'Your budget, territory and industry interest.',
        icon: Icons.handshake_rounded,
        buildScreen: () => buildAudienceScreen('for-franchise'),
      ),
    ],
  ),
  'landlord': AccountTypeConfig(
    tabLabel: 'List Space',
    tabIcon: Icons.apartment_outlined,
    tabActiveIcon: Icons.apartment_rounded,
    buildPrimaryScreen: () => buildAudienceScreen('for-landlords'),
    homeActions: [
      HomeAction(
        title: 'Submit your space',
        body: 'We bring the brands to it.',
        icon: Icons.apartment_rounded,
        buildScreen: () => buildAudienceScreen('for-landlords'),
      ),
    ],
  ),
  // Shares the landlord form — the website's own "for-landlords" audience
  // is already titled "Landlords & Developers" and covers both.
  'developer': AccountTypeConfig(
    tabLabel: 'List Space',
    tabIcon: Icons.apartment_outlined,
    tabActiveIcon: Icons.apartment_rounded,
    buildPrimaryScreen: () => buildAudienceScreen('for-landlords'),
    homeActions: [
      HomeAction(
        title: 'Submit your space',
        body: 'We bring the brands to it.',
        icon: Icons.apartment_rounded,
        buildScreen: () => buildAudienceScreen('for-landlords'),
      ),
    ],
  ),
  'investor': AccountTypeConfig(
    tabLabel: 'Invest',
    tabIcon: Icons.trending_up_outlined,
    tabActiveIcon: Icons.trending_up_rounded,
    buildPrimaryScreen: () => buildAudienceScreen('for-investors'),
    homeActions: [
      HomeAction(
        title: 'Share your interest',
        body: 'Your ticket size, sectors and horizon.',
        icon: Icons.trending_up_rounded,
        buildScreen: () => buildAudienceScreen('for-investors'),
      ),
    ],
  ),
  'vendor': AccountTypeConfig(
    tabLabel: 'Partners',
    tabIcon: Icons.diversity_3_outlined,
    tabActiveIcon: Icons.diversity_3_rounded,
    buildPrimaryScreen: () => const PartnersBody(),
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
    tabLabel: 'Consultants',
    tabIcon: Icons.groups_outlined,
    tabActiveIcon: Icons.groups_rounded,
    buildPrimaryScreen: () => const ConsultantsBody(),
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

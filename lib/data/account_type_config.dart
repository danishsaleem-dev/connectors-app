import 'package:flutter/material.dart';
import '../screens/audience_screen.dart';
import '../screens/consultants_screen.dart';
import '../screens/partners_screen.dart';

/// What a signed-in account of a given type sees: which nav tab replaces
/// the old generic "Brands/Franchise/Landlords/Investors" set, and what
/// Home's one primary action card says. Every org is exactly one of these
/// seven types, so — unlike the old app, which showed every visitor all
/// four audience doors because it didn't yet know who they were — the app
/// can now show exactly the one thing this account actually needs.
class AccountTypeConfig {
  final String tabLabel;
  final IconData tabIcon;
  final IconData tabActiveIcon;
  final String homeTitle;
  final String homeBody;
  final IconData homeIcon;

  /// Builds the tab's body content — no Scaffold/AppBar of its own, since
  /// it's dropped straight into the app shell's IndexedStack, same as the
  /// four audience screens already are.
  final Widget Function() buildPrimaryScreen;

  const AccountTypeConfig({
    required this.tabLabel,
    required this.tabIcon,
    required this.tabActiveIcon,
    required this.homeTitle,
    required this.homeBody,
    required this.homeIcon,
    required this.buildPrimaryScreen,
  });
}

final Map<String, AccountTypeConfig> accountTypeConfigs = {
  'brand': AccountTypeConfig(
    tabLabel: 'Locations',
    tabIcon: Icons.storefront_outlined,
    tabActiveIcon: Icons.storefront_rounded,
    homeTitle: 'Submit a location request',
    homeBody: "Tell us what you're looking to open, and where.",
    homeIcon: Icons.storefront_rounded,
    buildPrimaryScreen: () => buildAudienceScreen('for-brands'),
  ),
  'franchisee': AccountTypeConfig(
    tabLabel: 'Franchise',
    tabIcon: Icons.handshake_outlined,
    tabActiveIcon: Icons.handshake_rounded,
    homeTitle: 'Find your franchise',
    homeBody: 'Your budget, territory and industry interest.',
    homeIcon: Icons.handshake_rounded,
    buildPrimaryScreen: () => buildAudienceScreen('for-franchise'),
  ),
  'landlord': AccountTypeConfig(
    tabLabel: 'List Space',
    tabIcon: Icons.apartment_outlined,
    tabActiveIcon: Icons.apartment_rounded,
    homeTitle: 'Submit your space',
    homeBody: 'We bring the brands to it.',
    homeIcon: Icons.apartment_rounded,
    buildPrimaryScreen: () => buildAudienceScreen('for-landlords'),
  ),
  // Shares the landlord form — the website's own "for-landlords" audience
  // is already titled "Landlords & Developers" and covers both.
  'developer': AccountTypeConfig(
    tabLabel: 'List Space',
    tabIcon: Icons.apartment_outlined,
    tabActiveIcon: Icons.apartment_rounded,
    homeTitle: 'Submit your space',
    homeBody: 'We bring the brands to it.',
    homeIcon: Icons.apartment_rounded,
    buildPrimaryScreen: () => buildAudienceScreen('for-landlords'),
  ),
  'investor': AccountTypeConfig(
    tabLabel: 'Invest',
    tabIcon: Icons.trending_up_outlined,
    tabActiveIcon: Icons.trending_up_rounded,
    homeTitle: 'Share your interest',
    homeBody: 'Your ticket size, sectors and horizon.',
    homeIcon: Icons.trending_up_rounded,
    buildPrimaryScreen: () => buildAudienceScreen('for-investors'),
  ),
  'vendor': AccountTypeConfig(
    tabLabel: 'Partners',
    tabIcon: Icons.diversity_3_outlined,
    tabActiveIcon: Icons.diversity_3_rounded,
    homeTitle: 'The Partners Program',
    homeBody: 'Disciplines, benefits and how the bench works.',
    homeIcon: Icons.diversity_3_rounded,
    buildPrimaryScreen: () => const PartnersBody(),
  ),
  'consultant': AccountTypeConfig(
    tabLabel: 'Consultants',
    tabIcon: Icons.groups_outlined,
    tabActiveIcon: Icons.groups_rounded,
    homeTitle: 'The consultants roster',
    homeBody: 'Who Connectors helps, and how engagements work.',
    homeIcon: Icons.groups_rounded,
    buildPrimaryScreen: () => const ConsultantsBody(),
  ),
};

/// Falls back to the brand config for an admin account (no organization, so
/// no real type) or any type this map doesn't recognise — admins run the
/// business from the website portal, not this app, so there's nothing
/// meaningfully "primary" to show them here; brand is just a reasonable
/// default rather than a crash.
AccountTypeConfig configFor(String? orgType) =>
    accountTypeConfigs[orgType] ?? accountTypeConfigs['brand']!;

import 'package:flutter/material.dart';

/// The four onboarding slides, headings and descriptions verbatim from the
/// business-logic doc's "2. ONBOARDING / WELCOME SCREENS".
///
/// Worth noting what these four actually are: one per audience the product
/// serves — brand, investor, franchisee, and landlord/mall owner. They're
/// not filler, they're "here's who this is for", which is why they sit
/// directly before role selection in the doc's flow.
class OnboardingSlide {
  final String heading;
  final String description;
  final IconData icon;

  /// Unsplash photo id — same source and id set as the website's own
  /// src/lib/images.ts (free for commercial use, no attribution required;
  /// every id there was downloaded and visually checked before being
  /// written in, not guessed). Not imported directly since that file lives
  /// in the other repo — same ids, kept in sync by hand.
  final String backgroundPhotoId;

  const OnboardingSlide({
    required this.heading,
    required this.description,
    required this.icon,
    required this.backgroundPhotoId,
  });
}

const onboardingSlides = [
  OnboardingSlide(
    heading: 'Expand Your Brand',
    description: 'Find premium retail locations and grow your business faster.',
    icon: Icons.storefront_rounded,
    // Boutique interior — a brand's own retail space.
    backgroundPhotoId: 'photo-1441986300917-64674bd600d8',
  ),
  OnboardingSlide(
    heading: 'Connect With Investors',
    description: 'Discover investment opportunities and business partnerships.',
    icon: Icons.trending_up_rounded,
    // Commercial towers, looking up — capital and investment.
    backgroundPhotoId: 'photo-1486406146926-c627a92ad1ab',
  ),
  OnboardingSlide(
    heading: 'Franchise Opportunities',
    description: 'Connect brands with qualified franchisees worldwide.',
    icon: Icons.handshake_rounded,
    // Bright modern cafe — a franchised business in the wild.
    backgroundPhotoId: 'photo-1567521464027-f127ff144326',
  ),
  OnboardingSlide(
    heading: 'Commercial Property Solutions',
    description: 'Mall owners and landlords can attract premium brands.',
    icon: Icons.apartment_rounded,
    // Multi-level shopping mall atrium — the property side of the network.
    backgroundPhotoId: 'photo-1519567241046-7f570eee3ce6',
  ),
];

/// Same URL formula as the website's photoUrl() (src/lib/images.ts) —
/// Unsplash's on-the-fly resize/crop/format API, no local asset needed.
String onboardingPhotoUrl(String id, {int width = 1024, int quality = 72}) =>
    'https://images.unsplash.com/$id?auto=format&fit=crop&w=$width&q=$quality';

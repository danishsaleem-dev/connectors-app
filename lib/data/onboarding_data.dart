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

  const OnboardingSlide({
    required this.heading,
    required this.description,
    required this.icon,
  });
}

const onboardingSlides = [
  OnboardingSlide(
    heading: 'Expand Your Brand',
    description: 'Find premium retail locations and grow your business faster.',
    icon: Icons.storefront_rounded,
  ),
  OnboardingSlide(
    heading: 'Connect With Investors',
    description: 'Discover investment opportunities and business partnerships.',
    icon: Icons.trending_up_rounded,
  ),
  OnboardingSlide(
    heading: 'Franchise Opportunities',
    description: 'Connect brands with qualified franchisees worldwide.',
    icon: Icons.handshake_rounded,
  ),
  OnboardingSlide(
    heading: 'Commercial Property Solutions',
    description: 'Mall owners and landlords can attract premium brands.',
    icon: Icons.apartment_rounded,
  ),
];

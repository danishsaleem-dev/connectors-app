import 'package:flutter/material.dart';
import '../data/opportunity.dart';
import '../theme/colors.dart';

/// The gradient-plus-watermark-icon cover used everywhere a mock
/// OpportunityListing needs a visual anchor in place of a real photo —
/// list cards and the detail screen both use this, so a listing's cover
/// looks the same wherever it shows up.
class OpportunityCover extends StatelessWidget {
  final OpportunityListing listing;
  final double height;

  const OpportunityCover({super.key, required this.listing, this.height = 110});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: listing.coverColors,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -height * 0.18,
              bottom: -height * 0.18,
              child: Icon(
                categoryFor(listing.category).icon,
                size: height * 0.85,
                color: AppColors.white.withValues(alpha: 0.14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

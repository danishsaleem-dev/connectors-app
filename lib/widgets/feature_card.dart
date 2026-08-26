import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// The app's one "tappable feature" row card — title, body copy, and a
/// double-chevron badge on the right instead of icon-left/chevron-right.
/// Originally built for Home's action list; pulled out into a shared
/// widget since Account, Partners, Consultants and Contact all want the
/// same tappable-card language rather than each rolling their own.
class FeatureCard extends StatelessWidget {
  final String title;
  final String body;
  final VoidCallback onTap;

  const FeatureCard({super.key, required this.title, required this.body, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
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
                    Text(title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 3),
                    Text(
                      body,
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
                child: const Icon(
                  Icons.keyboard_double_arrow_right_rounded,
                  color: AppColors.violet600,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

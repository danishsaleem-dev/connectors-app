import 'package:flutter/material.dart';
import '../data/profile_fields.dart';
import '../screens/profile_completion_screen.dart';
import '../theme/colors.dart';
import 'app_card.dart';

/// A one-line "finish your profile" nudge for Home.
///
/// Deliberately minimal — a slim bar, a percentage and a chevron, no
/// illustration or headline. It's a prompt sitting above the content
/// someone actually opened the app for, and it disappears entirely once
/// the profile is complete (or immediately, for roles the doc defines no
/// fields for) rather than lingering as a permanent 100% badge.
class ProfileProgressStrip extends StatelessWidget {
  final String? orgType;

  const ProfileProgressStrip({super.key, required this.orgType});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, Object>>(
      valueListenable: ProfileDraft.values,
      builder: (context, _, _) {
        final progress = ProfileDraft.completion(orgType);
        if (progress >= 1) return const SizedBox.shrink();

        final total = profileFieldsFor(orgType).length;
        final done = ProfileDraft.filledCount(orgType);

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: AppCard(
            radius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => ProfileCompletionScreen(orgType: orgType)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Complete your profile',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '$done of $total',
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: AppColors.grey500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          backgroundColor: AppColors.grey100,
                          valueColor: const AlwaysStoppedAnimation(AppColors.violet600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                const Icon(Icons.chevron_right_rounded, color: AppColors.grey300),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/page_header.dart';
import '../widgets/reveal.dart';
import 'notification_detail_screen.dart';

/// UI-only for now — there's no push-notification infra yet. The doc's
/// bottom-nav spec calls for a Notifications tab, so this is the visual
/// shape of it with sample content, ready to swap for a real feed once
/// that infra exists.
class NotificationsBody extends StatelessWidget {
  const NotificationsBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            lead: "Updates on your requests and account.",
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Column(
              children: [
                for (var i = 0; i < sampleNotifications.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  Reveal(index: i, child: _NotificationCard(item: sampleNotifications[i])),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Read by the bottom nav to show an unread badge — same sample data the
/// screen itself renders, so the badge count and what you see on opening
/// the tab never disagree.
int get unreadNotificationsCount => sampleNotifications.where((n) => n.unread).length;

class NotificationItem {
  final IconData icon;
  final String title;
  final String body;
  final String time;
  final bool unread;

  const NotificationItem({
    required this.icon,
    required this.title,
    required this.body,
    required this.time,
    this.unread = false,
  });
}

const sampleNotifications = [
  NotificationItem(
    icon: Icons.location_city_rounded,
    title: 'New location matched',
    body: 'A retail unit in your target city just went live.',
    time: '2h ago',
    unread: true,
  ),
  NotificationItem(
    icon: Icons.mark_email_read_outlined,
    title: 'Request received',
    body: "We've received your submission and are reviewing it.",
    time: '1d ago',
  ),
  NotificationItem(
    icon: Icons.campaign_outlined,
    title: 'Welcome to Connectors',
    body: 'Your account is set up — explore what you can do from Home.',
    time: '3d ago',
  ),
];

class _NotificationCard extends StatelessWidget {
  final NotificationItem item;

  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.unread ? AppColors.violet600.withValues(alpha: 0.08) : AppColors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => NotificationDetailScreen(item: item)),
        ),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            // Unread gets a clearly-primary-tinted card, not just a shade
            // off white — the icon badge inverts to a solid fill too, so
            // an unread notification reads as highlighted at a glance, not
            // just faintly different.
            borderRadius: BorderRadius.circular(16),
            boxShadow: cardShadow(opacity: 0.05),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.unread ? AppColors.violet600 : AppColors.violet50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: item.unread ? AppColors.white : AppColors.violet600,
                  size: 19,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      item.body,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.grey500),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.time,
                      style: Theme.of(context)
                          .textTheme
                          .labelMedium
                          ?.copyWith(color: AppColors.grey300, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

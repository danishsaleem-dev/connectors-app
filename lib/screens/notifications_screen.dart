import 'package:flutter/material.dart';
import '../data/message.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/app_card.dart';
import '../widgets/page_header.dart';
import '../widgets/reveal.dart';

/// A different view of the same data Messages shows — an admin-authored
/// message *is* a notification (see MessagesStore's doc comment). Nothing
/// else in the product is real enough to notify on yet: an enquiry's
/// status is admin-internal by design (see the website's `requests`
/// table doc comment — the submitting org never sees it), so there's
/// nothing there to surface honestly. When that changes, this is where a
/// second notification source would join this one.
class NotificationsBody extends StatelessWidget {
  final VoidCallback onOpenMessages;

  const NotificationsBody({super.key, required this.onOpenMessages});

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
            lead: 'Messages from the Connectors team.',
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: ValueListenableBuilder<List<Message>>(
              valueListenable: MessagesStore.thread,
              builder: (context, thread, _) {
                // Newest first for a notification feed — Messages itself
                // stays oldest-first (a conversation reads top to bottom),
                // but "what's new" reads top to bottom the other way.
                final notifications = thread.where((m) => m.authorIsAdmin).toList().reversed.toList();

                if (notifications.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Text(
                        "You're all caught up.",
                        style: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.copyWith(color: AppColors.grey500),
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    for (var i = 0; i < notifications.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.sm),
                      Reveal(
                        index: i,
                        child: _NotificationCard(
                          message: notifications[i],
                          onTap: onOpenMessages,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Message message;
  final VoidCallback onTap;

  const _NotificationCard({required this.message, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = message.readAt == null;

    // Unread gets a clearly-primary-tinted card, not just a shade off
    // white — the icon badge inverts to a solid fill too, so an unread
    // notification reads as highlighted at a glance, not just faintly
    // different.
    return AppCard(
      radius: 16,
      padding: const EdgeInsets.all(14),
      color: unread ? const Color(0xFFF0EBF9) : AppColors.white,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: unread ? AppColors.violet600 : AppColors.violet50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chat_bubble_outline_rounded,
              color: unread ? AppColors.white : AppColors.violet600,
              size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Connectors', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(
                  message.body,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
                ),
                const SizedBox(height: 6),
                Text(
                  _relativeTime(message.createdAt),
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
    );
  }
}

String _relativeTime(DateTime time) {
  final diff = DateTime.now().difference(time);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${time.day}/${time.month}/${time.year}';
}

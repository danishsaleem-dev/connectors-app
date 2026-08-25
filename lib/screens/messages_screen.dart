import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import '../widgets/page_header.dart';
import '../widgets/reveal.dart';

/// UI-only for now — there's no messaging backend yet (real threads with
/// the Connectors team, or between accounts). The doc's bottom-nav spec
/// calls for a Messages tab, so this is the visual shape of it with sample
/// content, ready to swap for a real feed once that infra exists.
class MessagesBody extends StatelessWidget {
  const MessagesBody({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const PageHeader(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Messages',
            lead: 'Conversations with your Connectors contacts.',
          ),
          const SizedBox(height: AppSpacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
            child: Column(
              children: [
                for (var i = 0; i < _sampleThreads.length; i++) ...[
                  if (i > 0) const SizedBox(height: AppSpacing.sm),
                  Reveal(index: i, child: _ThreadCard(thread: _sampleThreads[i])),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Thread {
  final String name;
  final String preview;
  final String time;
  final bool unread;

  const _Thread({
    required this.name,
    required this.preview,
    required this.time,
    this.unread = false,
  });
}

const _sampleThreads = [
  _Thread(
    name: 'Connectors — Brand Expansion',
    preview: "We've shortlisted two locations that match your brief.",
    time: '9:40 AM',
    unread: true,
  ),
  _Thread(
    name: 'Connectors — Franchise Team',
    preview: 'Thanks for the application — reviewing this week.',
    time: 'Yesterday',
  ),
  _Thread(
    name: 'Connectors Support',
    preview: 'Let us know if you have any questions in the meantime.',
    time: 'Mon',
  ),
];

class _ThreadCard extends StatelessWidget {
  final _Thread thread;

  const _ThreadCard({required this.thread});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: cardShadow(opacity: 0.05),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.violet50, shape: BoxShape.circle),
            child: const Icon(Icons.forum_outlined, color: AppColors.violet600, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  thread.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  thread.preview,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.grey500),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                thread.time,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: AppColors.grey300, fontWeight: FontWeight.w500),
              ),
              if (thread.unread) ...[
                const SizedBox(height: 6),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.violet600,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

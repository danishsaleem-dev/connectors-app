import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import 'messages_screen.dart';

/// UI-only conversation preview — a believable exchange built around the
/// thread's own preview line (shown as the most recent message, matching
/// what the list already shows) rather than a real message history, since
/// there's no messaging backend behind any of this yet.
class MessageThreadScreen extends StatelessWidget {
  final MessageThread thread;

  const MessageThreadScreen({super.key, required this.thread});

  @override
  Widget build(BuildContext context) {
    final bubbles = [
      _Bubble(text: 'Hi! Just wanted to check in on this.', fromMe: false, time: '9:02 AM'),
      _Bubble(text: 'Thanks for reaching out — appreciate the update.', fromMe: true, time: '9:15 AM'),
      _Bubble(text: thread.preview, fromMe: false, time: thread.time),
    ];

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: AppColors.violet50, shape: BoxShape.circle),
              child: const Icon(Icons.forum_outlined, color: AppColors.violet600, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(thread.name, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page,
                  AppSpacing.md,
                  AppSpacing.page,
                  AppSpacing.md,
                ),
                children: [
                  for (var i = 0; i < bubbles.length; i++) ...[
                    if (i > 0) const SizedBox(height: AppSpacing.sm),
                    bubbles[i],
                  ],
                ],
              ),
            ),
            _ComposeBar(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Coming soon')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool fromMe;
  final String time;

  const _Bubble({required this.text, required this.fromMe, required this.time});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: fromMe ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Column(
            crossAxisAlignment: fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: fromMe ? AppColors.violet600 : AppColors.grey50,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(fromMe ? 16 : 4),
                    bottomRight: Radius.circular(fromMe ? 4 : 16),
                  ),
                ),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: fromMe ? AppColors.white : AppColors.ink,
                      ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: AppColors.grey300, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComposeBar extends StatelessWidget {
  final VoidCallback onTap;

  const _ComposeBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.page, 10, AppSpacing.page, 14),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.grey100)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.grey50,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Message not available in this preview',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey300),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Material(
            color: AppColors.violet600,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: const Padding(
                padding: EdgeInsets.all(11),
                child: Icon(Icons.send_rounded, color: AppColors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import 'notifications_screen.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationItem item;

  const NotificationDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.page),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: const BoxDecoration(color: AppColors.violet50, shape: BoxShape.circle),
                child: Icon(item.icon, color: AppColors.violet600, size: 26),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(item.title, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 6),
              Text(
                item.time,
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppColors.grey300, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(item.body, style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
      ),
    );
  }
}

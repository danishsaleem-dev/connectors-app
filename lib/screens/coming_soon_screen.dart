import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// An honest placeholder for personalized data that doesn't exist yet
/// (e.g. "your" portfolio, "your" interested brands) — distinct from
/// Messages/Notifications' sample content, which previews a feature
/// without claiming to be this specific account's real history. Showing
/// fabricated personal data here would read as the app lying about the
/// account's own state, so this says plainly that it's not built yet.
class ComingSoonScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;

  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: AppColors.violet50, shape: BoxShape.circle),
                  child: Icon(icon, color: AppColors.violet600, size: 28),
                ),
                const SizedBox(height: 18),
                Text(
                  'Coming soon',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

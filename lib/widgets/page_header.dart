import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// The title area for every screen except Home — a plain icon + title row,
/// not a repeated marketing banner. AppHero's gradient/orbit treatment is
/// deliberately reserved for the Home tab alone; putting it on every screen
/// is what made the app read as a scrolled website instead of an app.
class PageHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? lead;

  const PageHeader({super.key, required this.icon, required this.title, this.lead});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.violet50,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: AppColors.violet600, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
              ),
            ],
          ),
          if (lead != null) ...[
            const SizedBox(height: 10),
            Text(
              lead!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
            ),
          ],
        ],
      ),
    );
  }
}

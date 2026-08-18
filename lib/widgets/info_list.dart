import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';
import 'reveal.dart';

/// One row in an [InfoList]. A row carries either an [icon] or an [index]
/// ("01"), never both.
class InfoItem {
  final IconData? icon;
  final String? index;
  final String title;
  final String? body;
  final VoidCallback? onTap;

  const InfoItem({
    required this.title,
    this.icon,
    this.index,
    this.body,
    this.onTap,
  });
}

/// Full-width rows separated by hairlines — the app's primary way of
/// presenting a list of things.
///
/// This deliberately replaced a 2-column card grid. Two columns leaves each
/// item roughly 150pt of text width on a normal phone, which is narrower
/// than these descriptions need: titles wrapped to two lines on some items
/// and one on others, bodies had to be clipped with an ellipsis mid-word,
/// and the ragged heights read as clutter. A row spanning the full width
/// fits the same content with no truncation and no boxes.
class InfoList extends StatelessWidget {
  final List<InfoItem> items;

  const InfoList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const Divider(height: 1),
          _InfoRow(item: items[i], index: i),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final InfoItem item;
  final int index;

  const _InfoRow({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.icon != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Icon(item.icon, size: 20, color: AppColors.violet600),
            ),
            const SizedBox(width: AppSpacing.lg),
          ] else if (item.index != null) ...[
            SizedBox(
              width: 26,
              child: Text(
                item.index!,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(color: AppColors.violet400),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                if (item.body != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    item.body!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
                  ),
                ],
              ],
            ),
          ),
          if (item.onTap != null) ...[
            const SizedBox(width: AppSpacing.md),
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.grey300),
            ),
          ],
        ],
      ),
    );

    return Reveal(
      index: index,
      child: item.onTap == null ? row : InkWell(onTap: item.onTap, child: row),
    );
  }
}

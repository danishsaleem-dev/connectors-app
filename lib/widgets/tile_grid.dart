import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import 'reveal.dart';

/// One entry in a [TileGrid] — an icon, a title, and a short body.
class TileItem {
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback? onTap;

  const TileItem({required this.icon, required this.title, required this.body, this.onTap});
}

/// The app's general-purpose 2-column icon tile grid — values, divisions,
/// disciplines, menu destinations are all fundamentally "a labelled list of
/// things," so they share this one pattern instead of a bespoke list per
/// screen. `flat` swaps the elevated white+shadow card for the quieter
/// grey50 tile used where a list runs long and no single item should
/// compete hard for attention.
class TileGrid extends StatelessWidget {
  final List<TileItem> items;
  final bool flat;
  final int maxBodyLines;
  final int startIndex;

  const TileGrid({
    super.key,
    required this.items,
    this.flat = false,
    this.maxBodyLines = 2,
    this.startIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var row = 0; row < items.length; row += 2) ...[
          if (row > 0) const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _Tile(
                    item: items[row],
                    index: startIndex + row,
                    flat: flat,
                    maxLines: maxBodyLines,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: row + 1 < items.length
                      ? _Tile(
                          item: items[row + 1],
                          index: startIndex + row + 1,
                          flat: flat,
                          maxLines: maxBodyLines,
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  final TileItem item;
  final int index;
  final bool flat;
  final int maxLines;

  const _Tile({required this.item, required this.index, required this.flat, required this.maxLines});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(flat ? 16 : 18);
    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: AppColors.violet50, borderRadius: BorderRadius.circular(11)),
            child: Icon(item.icon, color: AppColors.violet600, size: 18),
          ),
          const SizedBox(height: 12),
          Text(item.title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(
            item.body,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.grey500),
          ),
          if (item.onTap != null) ...[
            const SizedBox(height: 10),
            const Icon(Icons.arrow_forward_rounded, size: 16, color: AppColors.violet600),
          ],
        ],
      ),
    );

    final card = Material(
      color: flat ? AppColors.grey50 : AppColors.white,
      borderRadius: radius,
      elevation: 0,
      child: item.onTap != null
          ? InkWell(onTap: item.onTap, borderRadius: radius, child: content)
          : content,
    );

    return Reveal(
      index: index,
      child: flat
          ? card
          : DecoratedBox(
              decoration: BoxDecoration(borderRadius: radius, boxShadow: cardShadow()),
              child: card,
            ),
    );
  }
}

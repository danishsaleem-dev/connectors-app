import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../theme/colors.dart';

/// Continuously auto-scrolling strip of chips — the app's take on the
/// website's industries marquee. Two copies of the list back to back, shifted
/// left forever and wrapped, so it reads as an infinite loop with no visible
/// seam or reset-jump.
class MarqueeStrip extends StatefulWidget {
  final List<String> items;

  const MarqueeStrip({super.key, required this.items});

  @override
  State<MarqueeStrip> createState() => _MarqueeStripState();
}

class _MarqueeStripState extends State<MarqueeStrip> with SingleTickerProviderStateMixin {
  final _scrollController = ScrollController();
  late final Ticker _ticker;
  double _offset = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    if (max <= 0) return;
    _offset += 0.6; // px per frame — a calm drift, not a scroll race.
    if (_offset >= max) _offset = 0;
    _scrollController.jumpTo(_offset);
  }

  @override
  void dispose() {
    _ticker.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final doubled = [...widget.items, ...widget.items];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: doubled.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, i) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.grey50,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: AppColors.grey200),
          ),
          alignment: Alignment.center,
          child: Text(
            doubled[i],
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w500, color: AppColors.grey500),
          ),
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import '../data/division_data.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../theme/spacing.dart';

/// Swipeable "how we work with you" cards — a horizontal carousel rather
/// than a static vertical list, since an audience only ever has 2-4 relevant
/// divisions and a stack of boxes undersells them. Peeks the next card at
/// the edge so it reads as swipeable at a glance, and rotates on its own so
/// the other cards get seen without a swipe.
class DivisionCarousel extends StatefulWidget {
  final List<Division> divisions;

  const DivisionCarousel({super.key, required this.divisions});

  @override
  State<DivisionCarousel> createState() => _DivisionCarouselState();
}

class _DivisionCarouselState extends State<DivisionCarousel> {
  static const _interval = Duration(seconds: 4);

  late final PageController _controller;
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.86);
    _controller.addListener(() {
      final next = _controller.page?.round() ?? 0;
      if (next != _page) setState(() => _page = next);
    });
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _timer?.cancel();
    if (widget.divisions.length < 2) return;
    _timer = Timer.periodic(_interval, (_) {
      if (!mounted || !_controller.hasClients) return;
      _controller.animateToPage(
        (_page + 1) % widget.divisions.length,
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: NotificationListener<ScrollNotification>(
            // Hand control back to the reader while they're dragging, then
            // pick the rotation back up once they've let go.
            onNotification: (notification) {
              if (notification is ScrollStartNotification && notification.dragDetails != null) {
                _timer?.cancel();
              } else if (notification is ScrollEndNotification) {
                _startAutoPlay();
              }
              return false;
            },
            child: PageView.builder(
              controller: _controller,
              itemCount: widget.divisions.length,
              itemBuilder: (context, i) {
                final division = widget.divisions[i];
                final active = i == _page;
                return AnimatedPadding(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: active ? 0 : 10),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      // Brand violet rather than near-black: the card is the
                      // one saturated surface on these screens, and ink read
                      // as a hole punched in the page.
                      color: active ? AppColors.violet600 : AppColors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: cardShadow(opacity: active ? 0.16 : 0.05),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (i + 1).toString().padLeft(2, '0'),
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                color: active ? AppColors.violet200 : AppColors.violet400,
                              ),
                        ),
                        const Spacer(),
                        Text(
                          division.navLabel,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: active ? AppColors.white : AppColors.ink,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          division.short,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: active
                                    ? AppColors.white.withValues(alpha: 0.78)
                                    : AppColors.grey500,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < widget.divisions.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 20 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: i == _page ? AppColors.violet600 : AppColors.grey200,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

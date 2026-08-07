import 'package:flutter/material.dart';
import '../data/division_data.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';

/// Swipeable "how we work with you" cards — a horizontal carousel rather
/// than a static vertical list, since an audience only ever has 2-4 relevant
/// divisions and a stack of boxes undersells them. Peeks the next card at
/// the edge so it reads as swipeable at a glance.
class DivisionCarousel extends StatefulWidget {
  final List<Division> divisions;

  const DivisionCarousel({super.key, required this.divisions});

  @override
  State<DivisionCarousel> createState() => _DivisionCarouselState();
}

class _DivisionCarouselState extends State<DivisionCarousel> {
  late final PageController _controller;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(viewportFraction: 0.86);
    _controller.addListener(() {
      final next = _controller.page?.round() ?? 0;
      if (next != _page) setState(() => _page = next);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 200,
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
                    color: active ? AppColors.ink : AppColors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: cardShadow(opacity: active ? 0.16 : 0.05),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (i + 1).toString().padLeft(2, '0'),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppColors.violet400,
                            ),
                      ),
                      const Spacer(),
                      Text(
                        division.navLabel,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: active ? AppColors.white : AppColors.ink,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        division.short,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: active
                                  ? AppColors.white.withValues(alpha: 0.7)
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
        const SizedBox(height: 16),
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

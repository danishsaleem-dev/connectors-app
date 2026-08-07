import 'package:flutter/material.dart';

/// Fade-and-rise entrance for a section — the app's equivalent of the
/// website's scroll-triggered Reveal. Runs once on first build rather than
/// on scroll-into-view (no extra viewport-visibility dependency needed for
/// what's effectively a single long scroll per screen), with the same
/// index-based stagger the site uses to cascade a group of siblings.
class Reveal extends StatefulWidget {
  final Widget child;
  final int index;

  const Reveal({super.key, required this.child, this.index = 0});

  @override
  State<Reveal> createState() => _RevealState();
}

class _RevealState extends State<Reveal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _offset;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 520));
    const curve = Curves.easeOutCubic;
    _opacity = CurvedAnimation(parent: _controller, curve: curve);
    _offset = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: curve));
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _offset, child: widget.child),
    );
  }
}

import 'dart:math' as math;
import 'package:flutter/material.dart';

/// The Connectors mark's "O", rebuilt as geometry — a stack of meridian
/// ellipses whose width follows a cosine, so they bunch at the edges and
/// spread through the middle, plus a heavier accent crescent. Same math as
/// the website's OrbitField.tsx, so the app's signature decorative motif is
/// the actual brand mark, not a generic gradient blob.
class OrbitField extends StatefulWidget {
  final int count;
  final Color color;
  final double strokeWidth;
  final bool animate;
  final bool accent;

  const OrbitField({
    super.key,
    this.count = 26,
    required this.color,
    this.strokeWidth = 0.35,
    this.animate = true,
    this.accent = true,
  });

  @override
  State<OrbitField> createState() => _OrbitFieldState();
}

class _OrbitFieldState extends State<OrbitField> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // 90s per full turn — the same very-slow drift as the site's
    // .animate-orbit, deliberately subtle rather than a spinner.
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 90))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animate) {
      return CustomPaint(
        painter: _OrbitPainter(
          turns: 0,
          count: widget.count,
          color: widget.color,
          strokeWidth: widget.strokeWidth,
          accent: widget.accent,
        ),
      );
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => CustomPaint(
        painter: _OrbitPainter(
          turns: _controller.value,
          count: widget.count,
          color: widget.color,
          strokeWidth: widget.strokeWidth,
          accent: widget.accent,
        ),
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  final double turns;
  final int count;
  final Color color;
  final double strokeWidth;
  final bool accent;

  _OrbitPainter({
    required this.turns,
    required this.count,
    required this.color,
    required this.strokeWidth,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2;
    final sw = strokeWidth / 100 * size.width;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(turns * 2 * math.pi);
    canvas.translate(-center.dx, -center.dy);

    final rimPaint = Paint()
      ..color = color.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = sw;
    canvas.drawCircle(center, r, rimPaint);

    for (var i = 0; i < count; i++) {
      final theta = (i / (count - 1)) * math.pi;
      final rx = (math.cos(theta)).abs() * r;
      final opacity = 0.14 + (rx / r) * 0.34;
      final paint = Paint()
        ..color = color.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw;
      canvas.drawOval(
        Rect.fromCenter(center: center, width: rx * 2, height: r * 2),
        paint,
      );
    }

    if (accent) {
      final accentPaint = Paint()
        ..color = color.withValues(alpha: 0.9)
        ..style = PaintingStyle.stroke
        ..strokeWidth = sw * 3.2;
      final rx = r * 0.34;
      canvas.drawOval(
        Rect.fromCenter(center: center, width: rx * 2, height: r * 2),
        accentPaint,
      );
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) =>
      oldDelegate.turns != turns || oldDelegate.color != color;
}

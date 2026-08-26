import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';

/// The app's one elevated-surface primitive: a white rounded card with a
/// real shadow and an optional tap ripple.
///
/// The shadow lives on a [DecoratedBox] *behind* the [Material], and the
/// Material clips its own ink. That ordering is not cosmetic. Putting the
/// shadow on a `Container` *inside* a coloured Material paints the blur's
/// inward half on top of the card's own fill — which reads as a grey wash
/// creeping in from the edges instead of as elevation. (A standalone
/// `Container` that sets both `color` and `boxShadow` is fine, because
/// BoxDecoration paints the fill after the shadow and covers the bleed;
/// it's specifically shadow-without-fill layered over a Material that
/// breaks.)
///
/// Every card in the app goes through here so that can't be reintroduced
/// one widget at a time.
class AppCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final double radius;
  final Color color;
  final List<BoxShadow>? shadow;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.radius = 18,
    this.color = AppColors.white,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    final shape = BorderRadius.circular(radius);

    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: shape, boxShadow: shadow ?? cardShadow()),
      child: Material(
        color: color,
        borderRadius: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: padding == null ? child : Padding(padding: padding!, child: child),
        ),
      ),
    );
  }
}

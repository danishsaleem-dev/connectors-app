import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// One consistent "profile picture, or initials if there isn't one yet"
/// circle — used in Account and Edit Profile, so a photo showing up in one
/// and not the other was never a thing to keep in sync by hand.
///
/// `photoUrl` is expected already resolved to a signed, directly-renderable
/// URL (see ProfileData.photoUrl's doc comment) — this widget doesn't know
/// or care that it's backed by private Storage.
class Avatar extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double size;

  /// Defaults match Edit Profile's own circle (violet on white); Account's
  /// header card sits on a violet gradient, so it passes these inverted —
  /// the initial fallback needs to keep reading against whatever it's on.
  final Color backgroundColor;
  final Color foregroundColor;

  const Avatar({
    super.key,
    required this.photoUrl,
    required this.name,
    this.size = 88,
    this.backgroundColor = AppColors.violet600,
    this.foregroundColor = AppColors.white,
  });

  @override
  Widget build(BuildContext context) {
    final initial = name.trim().isEmpty ? '?' : name.trim()[0].toUpperCase();
    final url = photoUrl;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: backgroundColor, shape: BoxShape.circle),
      child: url == null || url.isEmpty
          ? _Initial(initial: initial, size: size, color: foregroundColor)
          : ClipOval(
              child: Image.network(
                url,
                key: ValueKey(url),
                width: size,
                height: size,
                fit: BoxFit.cover,
                // A stale/expired signed URL or a genuine network failure
                // both fall back to the initial rather than a broken-image
                // icon — same "never show something worse than the fallback
                // we'd have shown anyway" reasoning as every other image in
                // this app (see LocationsScreen's _ImageFallback).
                errorBuilder: (context, error, stackTrace) =>
                    _Initial(initial: initial, size: size, color: foregroundColor),
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : _Initial(initial: initial, size: size, color: foregroundColor),
              ),
            ),
    );
  }
}

class _Initial extends StatelessWidget {
  final String initial;
  final double size;
  final Color color;

  const _Initial({required this.initial, required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Text(
      initial,
      style: TextStyle(color: color, fontSize: size * 0.42, fontWeight: FontWeight.w600),
    );
  }
}

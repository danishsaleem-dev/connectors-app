import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Plus Jakarta Sans throughout — one family for display and body rather
/// than the previous Instrument Sans + Geist pairing. Two families whose
/// letterforms are that close buys no useful contrast on a phone; it just
/// makes headings and body look subtly mismatched. Jakarta's tighter
/// apertures and even rhythm hold up better at the small sizes an app
/// actually uses, and weight alone carries the hierarchy.
/// `GoogleFonts.getFont` (not the per-family generated method) so this
/// doesn't depend on a generated binding existing in whatever google_fonts
/// version ends up resolved.
TextStyle _font({double? size, FontWeight? weight, double? height, double? spacing}) =>
    GoogleFonts.getFont(
      'Plus Jakarta Sans',
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: spacing,
    );

/// Soft, deep shadow for elevated cards — a real sense of lift rather than a
/// hairline border, which is most of what separated the first pass from
/// reading as a native, considered app rather than a form filled in with
/// Material defaults.
List<BoxShadow> cardShadow({double opacity = 0.06}) => [
      BoxShadow(
        color: AppColors.ink.withValues(alpha: opacity),
        blurRadius: 28,
        offset: const Offset(0, 12),
        spreadRadius: -8,
      ),
    ];

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.violet600,
      primary: AppColors.violet600,
      onPrimary: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.ink,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.white,
  );

  return base.copyWith(
    textTheme: base.textTheme
        .copyWith(
          // Tight, editorial display sizes; a deliberately small step
          // between titleLarge and body so full-width list rows read as
          // rows rather than a stack of competing headlines — the old
          // 20pt row title was sized for a card, not a list.
          displayLarge: _font(size: 40, weight: FontWeight.w600, height: 1.05, spacing: -1.2),
          displayMedium: _font(size: 31, weight: FontWeight.w600, height: 1.1, spacing: -0.8),
          displaySmall: _font(size: 25, weight: FontWeight.w600, height: 1.18, spacing: -0.5),
          headlineMedium: _font(size: 22, weight: FontWeight.w600, height: 1.28, spacing: -0.4),
          titleLarge: _font(size: 17, weight: FontWeight.w600, height: 1.35, spacing: -0.1),
          titleMedium: _font(size: 15, weight: FontWeight.w600, height: 1.35),
          bodyLarge: _font(size: 16, weight: FontWeight.w400, height: 1.55),
          bodyMedium: _font(size: 14.5, weight: FontWeight.w400, height: 1.55),
          labelLarge: _font(size: 13, weight: FontWeight.w600, height: 1.2),
          labelMedium: _font(size: 11, weight: FontWeight.w700, height: 1.2),
        )
        .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.ink,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      surfaceTintColor: AppColors.white,
    ),
    dividerTheme: const DividerThemeData(color: AppColors.grey200, thickness: 1, space: 1),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.violet600,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: _font(size: 15, weight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.grey200, width: 1.4),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: _font(size: 15, weight: FontWeight.w600),
      ),
    ),
  );
}

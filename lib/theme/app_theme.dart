import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Instrument Sans for display type, Geist for body/UI — same pairing as the
/// website. `GoogleFonts.getFont` (not the per-family generated methods) so
/// this doesn't depend on both families having a generated binding in
/// whatever google_fonts version ends up resolved.
TextStyle _display({double? size, FontWeight? weight, double? height, double? spacing}) =>
    GoogleFonts.getFont(
      'Instrument Sans',
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: spacing,
    );

TextStyle _body({double? size, FontWeight? weight, double? height}) =>
    GoogleFonts.getFont('Geist', fontSize: size, fontWeight: weight, height: height);

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
          // Larger and tighter than Material defaults — the "big, premium
          // editorial" register the site's own display type sets, rather
          // than a scaled-up default app type ramp.
          displayLarge: _display(size: 52, weight: FontWeight.w500, height: 1.02, spacing: -1.4),
          displayMedium: _display(size: 38, weight: FontWeight.w500, height: 1.06, spacing: -0.8),
          displaySmall: _display(size: 30, weight: FontWeight.w500, height: 1.1, spacing: -0.4),
          headlineMedium: _display(size: 24, weight: FontWeight.w500, height: 1.2),
          titleLarge: _display(size: 20, weight: FontWeight.w500, height: 1.25),
          bodyLarge: _body(size: 17, weight: FontWeight.w400, height: 1.6),
          bodyMedium: _body(size: 15, weight: FontWeight.w400, height: 1.6),
          labelLarge: _body(size: 13.5, weight: FontWeight.w600, height: 1.2),
          labelMedium: _body(size: 11.5, weight: FontWeight.w600, height: 1.2),
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
        textStyle: _body(size: 15, weight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.grey200, width: 1.4),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: _body(size: 15, weight: FontWeight.w600),
      ),
    ),
  );
}

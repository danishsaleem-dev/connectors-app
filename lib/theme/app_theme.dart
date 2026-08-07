import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

/// Instrument Sans for display type, Geist for body/UI — same pairing as the
/// website. `GoogleFonts.getFont` (not the per-family generated methods) so
/// this doesn't depend on both families having a generated binding in
/// whatever google_fonts version ends up resolved.
TextStyle _display({double? size, FontWeight? weight, double? height}) =>
    GoogleFonts.getFont('Instrument Sans', fontSize: size, fontWeight: weight, height: height);

TextStyle _body({double? size, FontWeight? weight, double? height}) =>
    GoogleFonts.getFont('Geist', fontSize: size, fontWeight: weight, height: height);

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
          displayLarge: _display(size: 40, weight: FontWeight.w500, height: 1.08),
          displayMedium: _display(size: 32, weight: FontWeight.w500, height: 1.1),
          displaySmall: _display(size: 26, weight: FontWeight.w500, height: 1.15),
          headlineMedium: _display(size: 22, weight: FontWeight.w500, height: 1.2),
          titleLarge: _display(size: 19, weight: FontWeight.w500, height: 1.25),
          bodyLarge: _body(size: 16, weight: FontWeight.w400, height: 1.55),
          bodyMedium: _body(size: 14, weight: FontWeight.w400, height: 1.55),
          labelLarge: _body(size: 13, weight: FontWeight.w600, height: 1.2),
          labelMedium: _body(size: 11, weight: FontWeight.w600, height: 1.2),
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
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: _body(size: 14, weight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.grey200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        textStyle: _body(size: 14, weight: FontWeight.w600),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.white,
      indicatorColor: AppColors.violet50,
      surfaceTintColor: AppColors.white,
      elevation: 0,
      height: 64,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return _body(
          size: 11,
          weight: selected ? FontWeight.w600 : FontWeight.w500,
        ).copyWith(color: selected ? AppColors.violet600 : AppColors.grey500);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(color: selected ? AppColors.violet600 : AppColors.grey500, size: 22);
      }),
    ),
  );
}

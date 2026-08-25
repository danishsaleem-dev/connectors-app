import 'package:flutter/material.dart';
import '../theme/colors.dart';

/// White pill input, icon-prefixed, no separate label — shared by the
/// Login and Signup screens, which both sit on the violet entrance
/// background rather than the app's usual white-with-violet-accent body.
InputDecoration authInputDecoration({required IconData icon, required String hintText, Widget? suffixIcon}) {
  return InputDecoration(
    hintText: hintText,
    prefixIcon: Icon(icon, color: AppColors.violet400, size: 20),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: AppColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 16),
    hintStyle: const TextStyle(color: AppColors.grey300),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(999),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(999),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(999),
      borderSide: const BorderSide(color: AppColors.violet400, width: 1.5),
    ),
  );
}

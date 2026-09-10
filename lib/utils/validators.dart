import '../data/countries.dart';

/// Real format checks shared by every form that collects them (the
/// enquiry wizards, Sign Up, the profile step) — one place so tightening a
/// rule tightens it everywhere at once, instead of drifting between
/// several loose copies.
class FormatValidators {
  FormatValidators._();

  static final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  static bool isValidEmail(String text) => _emailPattern.hasMatch(text.trim());

  /// Digits plus the punctuation a real phone number is actually written
  /// with (+, spaces, hyphens, parens) — a letter or other stray
  /// character fails immediately, before the digit pattern is even
  /// checked.
  static final _phoneCharsPattern = RegExp(r'^[0-9+\-\s()]+$');

  /// A reasonable generic check for a country with no curated pattern
  /// (see Country.phonePattern's doc comment) — E.164's own length bounds,
  /// not a guess.
  static final _genericDigitCount = RegExp(r'^\d{7,15}$');

  /// Null when [text] is a plausible phone number for [country] (or a
  /// plausible phone number in general, when [country] is null or has no
  /// curated pattern of its own) — otherwise the message to show.
  static String? phoneError(String text, {Country? country}) {
    final trimmed = text.trim();
    if (!_phoneCharsPattern.hasMatch(trimmed)) {
      return 'Enter a valid phone number.';
    }
    final digits = trimmed.replaceAll(RegExp(r'[^0-9]'), '');

    final pattern = country?.phonePattern;
    if (pattern != null) {
      return pattern.hasMatch(digits)
          ? null
          : 'Enter a valid ${country!.name} phone number.';
    }
    return _genericDigitCount.hasMatch(digits)
        ? null
        : 'Enter a valid phone number.';
  }
}

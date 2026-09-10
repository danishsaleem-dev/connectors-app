/// One shared country list backing every "Country" field in the app (the
/// profile step, Edit Profile) — previously free text, which is how a
/// phone number in any format at all was getting through unchecked.
///
/// [phonePattern], when set, matches the *national* mobile number for that
/// country after stripping everything but digits — with or without the
/// country's own dial code and a leading trunk "0" both still allowed,
/// since that's how people actually type a number they know by heart
/// (see FormatValidators.phoneErrorFor). Only curated for the markets
/// Connectors actually operates in (same real-world set phone_login_screen
/// .dart's country picker already uses) — anywhere else falls back to a
/// generic "plausible phone number" check rather than a guessed pattern
/// this app can't actually verify.
class Country {
  final String name;
  final String flag;
  final String dialCode;
  final RegExp? phonePattern;

  const Country({
    required this.name,
    required this.flag,
    required this.dialCode,
    this.phonePattern,
  });
}

final countries = [
  Country(
    name: 'United Kingdom',
    flag: '🇬🇧',
    dialCode: '+44',
    // Mobile: 07XXX XXXXXX / +44 7XXX XXXXXX — 10 digits starting with 7,
    // an optional leading trunk 0 and/or the 44 country code.
    phonePattern: RegExp(r'^(44)?0?7\d{9}$'),
  ),
  Country(
    name: 'United States',
    flag: '🇺🇸',
    dialCode: '+1',
    // NANP: 10 digits, optionally prefixed with the 1 country code.
    phonePattern: RegExp(r'^1?\d{10}$'),
  ),
  Country(
    name: 'Pakistan',
    flag: '🇵🇰',
    dialCode: '+92',
    // Mobile: 03XX XXXXXXX / +92 3XX XXXXXXX — 10 digits starting with 3,
    // an optional leading trunk 0 and/or the 92 country code.
    phonePattern: RegExp(r'^(92)?0?3\d{9}$'),
  ),
  Country(
    name: 'United Arab Emirates',
    flag: '🇦🇪',
    dialCode: '+971',
    // Mobile: 05X XXX XXXX / +971 5X XXX XXXX — 9 digits starting with 5,
    // an optional leading trunk 0 and/or the 971 country code.
    phonePattern: RegExp(r'^(971)?0?5\d{8}$'),
  ),
  const Country(name: 'Afghanistan', flag: '🇦🇫', dialCode: '+93'),
  const Country(name: 'Australia', flag: '🇦🇺', dialCode: '+61'),
  const Country(name: 'Bahrain', flag: '🇧🇭', dialCode: '+973'),
  const Country(name: 'Bangladesh', flag: '🇧🇩', dialCode: '+880'),
  const Country(name: 'Belgium', flag: '🇧🇪', dialCode: '+32'),
  const Country(name: 'Brazil', flag: '🇧🇷', dialCode: '+55'),
  const Country(name: 'Canada', flag: '🇨🇦', dialCode: '+1'),
  const Country(name: 'China', flag: '🇨🇳', dialCode: '+86'),
  const Country(name: 'Egypt', flag: '🇪🇬', dialCode: '+20'),
  const Country(name: 'France', flag: '🇫🇷', dialCode: '+33'),
  const Country(name: 'Germany', flag: '🇩🇪', dialCode: '+49'),
  const Country(name: 'India', flag: '🇮🇳', dialCode: '+91'),
  const Country(name: 'Indonesia', flag: '🇮🇩', dialCode: '+62'),
  const Country(name: 'Ireland', flag: '🇮🇪', dialCode: '+353'),
  const Country(name: 'Italy', flag: '🇮🇹', dialCode: '+39'),
  const Country(name: 'Japan', flag: '🇯🇵', dialCode: '+81'),
  const Country(name: 'Jordan', flag: '🇯🇴', dialCode: '+962'),
  const Country(name: 'Kenya', flag: '🇰🇪', dialCode: '+254'),
  const Country(name: 'Kuwait', flag: '🇰🇼', dialCode: '+965'),
  const Country(name: 'Malaysia', flag: '🇲🇾', dialCode: '+60'),
  const Country(name: 'Netherlands', flag: '🇳🇱', dialCode: '+31'),
  const Country(name: 'New Zealand', flag: '🇳🇿', dialCode: '+64'),
  const Country(name: 'Nigeria', flag: '🇳🇬', dialCode: '+234'),
  const Country(name: 'Oman', flag: '🇴🇲', dialCode: '+968'),
  const Country(name: 'Philippines', flag: '🇵🇭', dialCode: '+63'),
  const Country(name: 'Qatar', flag: '🇶🇦', dialCode: '+974'),
  const Country(name: 'Saudi Arabia', flag: '🇸🇦', dialCode: '+966'),
  const Country(name: 'Singapore', flag: '🇸🇬', dialCode: '+65'),
  const Country(name: 'South Africa', flag: '🇿🇦', dialCode: '+27'),
  const Country(name: 'South Korea', flag: '🇰🇷', dialCode: '+82'),
  const Country(name: 'Spain', flag: '🇪🇸', dialCode: '+34'),
  const Country(name: 'Sri Lanka', flag: '🇱🇰', dialCode: '+94'),
  const Country(name: 'Sweden', flag: '🇸🇪', dialCode: '+46'),
  const Country(name: 'Switzerland', flag: '🇨🇭', dialCode: '+41'),
  const Country(name: 'Thailand', flag: '🇹🇭', dialCode: '+66'),
  const Country(name: 'Turkey', flag: '🇹🇷', dialCode: '+90'),
  const Country(name: 'Vietnam', flag: '🇻🇳', dialCode: '+84'),
  const Country(name: 'Other', flag: '🌐', dialCode: ''),
];

Country? countryByName(String? name) {
  if (name == null) return null;
  for (final c in countries) {
    if (c.name == name) return c;
  }
  return null;
}

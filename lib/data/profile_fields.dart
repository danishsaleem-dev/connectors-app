import 'package:flutter/material.dart';

/// The doc's "5. PROFILE CREATION FLOW" — the information each role is
/// asked for, grouped into short steps.
///
/// Field lists are verbatim from the doc. The *grouping* is mine: a brand
/// has eleven required fields, and eleven inputs in one wall immediately
/// after signup is how you lose people. Two or three themed steps, each
/// skippable, gets the same data with somewhere sensible to stop.
///
/// Vendor and consultant deliberately have no steps here — the doc never
/// specifies fields for them, and inventing a set would be guessing at
/// what the business actually needs to know.
enum ProfileFieldKind { text, number, multiline, select, multiSelect, upload }

class ProfileField {
  final String key;
  final String label;
  final ProfileFieldKind kind;
  final String? hint;
  final List<String> options;

  const ProfileField({
    required this.key,
    required this.label,
    this.kind = ProfileFieldKind.text,
    this.hint,
    this.options = const [],
  });
}

class ProfileStep {
  final String title;
  final String subtitle;
  final List<ProfileField> fields;

  const ProfileStep({
    required this.title,
    required this.subtitle,
    required this.fields,
  });
}

const _industries = [
  'Food & Beverage',
  'Retail',
  'Fitness & Wellness',
  'Beauty',
  'Education',
  'Other',
];

const _countries = [
  'United Kingdom',
  'United States',
  'Pakistan',
  'United Arab Emirates',
  'Other',
];

const _propertyTypes = [
  'Retail shop',
  'Commercial unit',
  'Food court',
  'Standalone building',
  'Kiosk',
  'Showroom',
  'Office',
  'Mixed use',
];

final Map<String, List<ProfileStep>> profileStepsByRole = {
  'brand': const [
    ProfileStep(
      title: 'About your brand',
      subtitle: 'The basics buyers and landlords see first.',
      fields: [
        ProfileField(key: 'brandName', label: 'Brand name'),
        ProfileField(
          key: 'industry',
          label: 'Industry',
          kind: ProfileFieldKind.select,
          options: _industries,
        ),
        ProfileField(
          key: 'country',
          label: 'Country',
          kind: ProfileFieldKind.select,
          options: _countries,
        ),
        ProfileField(
          key: 'brandDescription',
          label: 'Brand description',
          kind: ProfileFieldKind.multiline,
          hint: 'What you do, and what makes the concept work.',
        ),
      ],
    ),
    ProfileStep(
      title: 'Your expansion',
      subtitle: 'Where you are now and where you want to be.',
      fields: [
        ProfileField(
          key: 'expansionGoals',
          label: 'Expansion goals',
          kind: ProfileFieldKind.multiline,
          hint: 'e.g. 10 new units across the UK in 2 years.',
        ),
        ProfileField(
          key: 'existingStores',
          label: 'Number of existing stores',
          kind: ProfileFieldKind.number,
        ),
        ProfileField(
          key: 'preferredLocations',
          label: 'Preferred locations',
          kind: ProfileFieldKind.multiSelect,
          options: _countries,
        ),
      ],
    ),
    ProfileStep(
      title: 'Franchise & investment',
      subtitle: 'What partners need to know before they enquire.',
      fields: [
        ProfileField(
          key: 'franchiseAvailability',
          label: 'Franchise availability',
          kind: ProfileFieldKind.select,
          options: ['Available now', 'Opening soon', 'Not offering franchises'],
        ),
        ProfileField(
          key: 'investmentRequirement',
          label: 'Investment requirement',
          hint: 'e.g. \$150K – \$300K',
        ),
        ProfileField(key: 'logo', label: 'Brand logo', kind: ProfileFieldKind.upload),
        ProfileField(key: 'brandDeck', label: 'Brand deck', kind: ProfileFieldKind.upload),
      ],
    ),
  ],
  'franchisee': const [
    ProfileStep(
      title: "What you're looking for",
      subtitle: 'So we only show you franchises that fit.',
      fields: [
        ProfileField(key: 'investmentBudget', label: 'Investment budget', hint: 'e.g. \$50K – \$150K'),
        ProfileField(
          key: 'preferredBrands',
          label: 'Preferred brands',
          kind: ProfileFieldKind.multiSelect,
          options: _industries,
        ),
        ProfileField(
          key: 'preferredCountries',
          label: 'Preferred countries',
          kind: ProfileFieldKind.multiSelect,
          options: _countries,
        ),
      ],
    ),
    ProfileStep(
      title: 'Your background',
      subtitle: 'What you bring to a franchise partnership.',
      fields: [
        ProfileField(
          key: 'businessExperience',
          label: 'Business experience',
          kind: ProfileFieldKind.multiline,
          hint: 'Sectors, years, and anything you currently operate.',
        ),
        ProfileField(
          key: 'propertyAvailability',
          label: 'Commercial property availability',
          kind: ProfileFieldKind.select,
          options: ['I already have a site', 'Actively looking', 'Need help finding one'],
        ),
      ],
    ),
  ],
  'investor': const [
    ProfileStep(
      title: 'Your mandate',
      subtitle: 'The shape of deal you want to see.',
      fields: [
        ProfileField(key: 'investmentRange', label: 'Investment range', hint: 'e.g. \$250K – \$1M'),
        ProfileField(
          key: 'industryInterest',
          label: 'Industry interest',
          kind: ProfileFieldKind.multiSelect,
          options: _industries,
        ),
        ProfileField(
          key: 'preferredCountries',
          label: 'Preferred countries',
          kind: ProfileFieldKind.multiSelect,
          options: _countries,
        ),
      ],
    ),
    ProfileStep(
      title: 'Your background',
      subtitle: 'Helps brands understand who they are talking to.',
      fields: [
        ProfileField(
          key: 'investmentExperience',
          label: 'Investment experience',
          kind: ProfileFieldKind.multiline,
          hint: 'Previous deals, sectors and typical involvement.',
        ),
      ],
    ),
  ],
  'landlord': const [
    ProfileStep(
      title: 'Your property',
      subtitle: 'The essentials a brand screens on.',
      fields: [
        ProfileField(
          key: 'propertyType',
          label: 'Property type',
          kind: ProfileFieldKind.select,
          options: _propertyTypes,
        ),
        ProfileField(key: 'propertySize', label: 'Property size (sq ft)', kind: ProfileFieldKind.number),
        ProfileField(key: 'location', label: 'Location', hint: 'City and area'),
      ],
    ),
    ProfileStep(
      title: 'Commercial terms',
      subtitle: 'What you are asking, and what the space includes.',
      fields: [
        ProfileField(key: 'rentalExpectation', label: 'Rental expectation', hint: 'e.g. £4,500 / month'),
        ProfileField(
          key: 'commercialDetails',
          label: 'Commercial details',
          kind: ProfileFieldKind.multiline,
          hint: 'Lease length, service charge, fit-out contribution.',
        ),
        ProfileField(key: 'photos', label: 'Photos', kind: ProfileFieldKind.upload),
      ],
    ),
  ],
  // "Mall Owners" in the doc — the app's developer account type.
  'developer': const [
    ProfileStep(
      title: 'Your development',
      subtitle: 'What you are letting, and where.',
      fields: [
        ProfileField(key: 'mallName', label: 'Mall / development name'),
        ProfileField(key: 'location', label: 'Location', hint: 'City and area'),
        ProfileField(key: 'availableUnits', label: 'Available units', kind: ProfileFieldKind.number),
      ],
    ),
    ProfileStep(
      title: 'Tenants & traffic',
      subtitle: 'What brands ask before they commit.',
      fields: [
        ProfileField(
          key: 'footfall',
          label: 'Footfall details',
          kind: ProfileFieldKind.multiline,
          hint: 'Average daily or monthly visitors, and peak periods.',
        ),
        ProfileField(
          key: 'brandCategories',
          label: 'Brand categories needed',
          kind: ProfileFieldKind.multiSelect,
          options: _industries,
        ),
      ],
    ),
  ],
};

List<ProfileStep> profileStepsFor(String? orgType) => profileStepsByRole[orgType] ?? const [];

List<ProfileField> profileFieldsFor(String? orgType) =>
    profileStepsFor(orgType).expand((s) => s.fields).toList();

/// In-memory only. Nothing is persisted and nothing is sent anywhere —
/// there's no profile endpoint to send it to. It lives in a notifier so
/// the completion meter on Home actually moves as you fill fields in
/// during a session, rather than being a static decoration.
class ProfileDraft {
  ProfileDraft._();

  static final values = ValueNotifier<Map<String, Object>>({});

  static Object? get(String key) => values.value[key];

  static void set(String key, Object? value) {
    final next = Map<String, Object>.from(values.value);
    if (value == null || (value is String && value.trim().isEmpty) || (value is List && value.isEmpty)) {
      next.remove(key);
    } else {
      next[key] = value;
    }
    values.value = next;
  }

  static void clear() => values.value = {};

  static int filledCount(String? orgType) {
    final fields = profileFieldsFor(orgType);
    return fields.where((f) => values.value.containsKey(f.key)).length;
  }

  /// 0.0–1.0. Returns 1.0 for roles with no defined fields so they never
  /// see a "finish your profile" nudge for a flow that doesn't exist.
  static double completion(String? orgType) {
    final total = profileFieldsFor(orgType).length;
    if (total == 0) return 1;
    return filledCount(orgType) / total;
  }
}

IconData iconForField(ProfileFieldKind kind) {
  switch (kind) {
    case ProfileFieldKind.number:
      return Icons.tag_rounded;
    case ProfileFieldKind.multiline:
      return Icons.notes_rounded;
    case ProfileFieldKind.select:
    case ProfileFieldKind.multiSelect:
      return Icons.expand_more_rounded;
    case ProfileFieldKind.upload:
      return Icons.upload_file_rounded;
    case ProfileFieldKind.text:
      return Icons.edit_outlined;
  }
}

import 'package:flutter/material.dart';

/// What the app asks to complete a profile — kept in exact lockstep with
/// the website's own onboarding wizard (see connectors/src/components/
/// portal/ProfileFields.tsx and src/lib/portal/actions.ts's writeProfile):
/// same field keys, same per-type tables, same organizationName/phone/
/// country trio at the organization level. Whichever surface someone
/// finishes onboarding on, the other reads the exact same saved data.
///
/// Two things the website's version has that this one deliberately
/// doesn't yet: file uploads (brand logo, vendor logo/cover, consultant
/// photo) and the consultant role's repeatable Experience/Education
/// entries — neither the app's ApiClient nor its UI has an upload/
/// repeatable-entry story yet (see EnquiryWizard's FileFieldSpec doc
/// comment for the same reasoning applied there). Everything else each
/// type's real profile table stores is here.
///
/// The *grouping* into steps is mine — a brand has a dozen real fields,
/// and a dozen inputs in one wall is how a signup becomes an abandoned
/// signup. Short themed steps, each skippable, gets the same data with
/// somewhere sensible to stop.
enum ProfileFieldKind { text, number, multiline, select, multiSelect, checkbox, upload }

class ProfileField {
  final String key;
  final String label;
  final ProfileFieldKind kind;
  final String? hint;
  final List<String> options;

  /// Display label per option value, for a select where what's stored
  /// (an enum key like 'interior') shouldn't be what's shown (e.g.
  /// 'Interior Specialist'). Falls back to the raw option value when a
  /// select's own value and label are already the same string.
  final Map<String, String> optionLabels;

  const ProfileField({
    required this.key,
    required this.label,
    this.kind = ProfileFieldKind.text,
    this.hint,
    this.options = const [],
    this.optionLabels = const {},
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

/// Same list as the website's INDUSTRIES (src/lib/portal/domain.ts) — kept
/// in sync by hand since the app has no build step that shares constants
/// with the website.
const _industries = [
  'Food & Beverage',
  'Fashion & Apparel',
  'Beauty & Cosmetics',
  'Retail Chains',
  'Fitness & Wellness',
  'Entertainment',
  'Healthcare',
  'Education',
  'Technology',
  'Lifestyle Brands',
  'Luxury Retail',
  'Hospitality',
];

/// Same keys as _vendorDisciplines, kept as a literal list rather than
/// derived via .keys.toList() — that call isn't allowed inside the const
/// ProfileField below.
const _vendorDisciplineKeys = ['designer', 'architect', 'interior', 'agency', 'consultant', 'contractor'];

/// Same values as vendorDisciplineEnum / VENDOR_DISCIPLINE_LABEL.
const _vendorDisciplines = {
  'designer': 'Designer',
  'architect': 'Architect',
  'interior': 'Interior Specialist',
  'agency': 'Agency',
  'consultant': 'Consultant',
  'contractor': 'Contractor',
};

/// organizationName/phone/country live on `organizations` itself, not a
/// per-type profile table, but the flow collects them the same way as
/// everything else — ApiClient.saveProfile knows to pull just these three
/// reserved keys out of the draft and send them as the request's top-level
/// fields rather than inside `fields`. Every role gets this step first.
const _organizationStep = ProfileStep(
  title: 'About your organization',
  subtitle: 'The basics, wherever your organization appears.',
  fields: [
    ProfileField(key: 'organizationName', label: 'Organization name'),
    ProfileField(key: 'phone', label: 'Phone number', hint: '+44 …'),
    ProfileField(key: 'country', label: 'Country'),
  ],
);

final Map<String, List<ProfileStep>> profileStepsByRole = {
  'brand': const [
    ProfileStep(
      title: 'About your brand',
      subtitle: 'What buyers and landlords see first.',
      fields: [
        ProfileField(
          key: 'industry',
          label: 'Industry',
          kind: ProfileFieldKind.select,
          options: _industries,
        ),
        ProfileField(
          key: 'description',
          label: 'About the brand',
          kind: ProfileFieldKind.multiline,
        ),
        ProfileField(key: 'website', label: 'Website'),
      ],
    ),
    ProfileStep(
      title: 'Scale & presence',
      subtitle: 'Where you already operate.',
      fields: [
        ProfileField(key: 'foundedYear', label: 'Year founded', kind: ProfileFieldKind.number),
        ProfileField(
          key: 'outletCount',
          label: 'Outlets currently open',
          kind: ProfileFieldKind.number,
        ),
        ProfileField(
          key: 'countriesPresent',
          label: 'Countries present',
          hint: 'Comma separated — e.g. United Kingdom, Pakistan',
        ),
        ProfileField(
          key: 'spaceRequiredSqft',
          label: 'Space required (sq ft)',
          kind: ProfileFieldKind.number,
        ),
      ],
    ),
    ProfileStep(
      title: 'Franchising',
      subtitle: 'What a partner needs to know before they enquire.',
      fields: [
        ProfileField(
          key: 'isFranchising',
          label: 'We offer franchise opportunities',
          kind: ProfileFieldKind.checkbox,
        ),
        ProfileField(
          key: 'franchiseInvestmentMin',
          label: 'Franchise investment from',
          kind: ProfileFieldKind.number,
        ),
        ProfileField(
          key: 'franchiseInvestmentMax',
          label: 'Franchise investment to',
          kind: ProfileFieldKind.number,
        ),
        ProfileField(key: 'franchiseFee', label: 'Franchise fee', kind: ProfileFieldKind.number),
        ProfileField(key: 'royaltyPercent', label: 'Royalty %', kind: ProfileFieldKind.number),
      ],
    ),
  ],
  'franchisee': const [
    ProfileStep(
      title: "What you're looking for",
      subtitle: 'So we only show you franchises that fit.',
      fields: [
        ProfileField(key: 'budgetMin', label: 'Investment budget from', kind: ProfileFieldKind.number),
        ProfileField(key: 'budgetMax', label: 'Investment budget to', kind: ProfileFieldKind.number),
        ProfileField(
          key: 'preferredCities',
          label: 'Preferred cities',
          hint: 'Comma separated — e.g. London, Manchester',
        ),
        ProfileField(
          key: 'industriesInterested',
          label: 'Industries of interest',
          kind: ProfileFieldKind.multiSelect,
          options: _industries,
        ),
      ],
    ),
    ProfileStep(
      title: 'Your background',
      subtitle: 'What you bring to a franchise partnership.',
      fields: [
        ProfileField(
          key: 'experienceYears',
          label: 'Years of business experience',
          kind: ProfileFieldKind.number,
        ),
        ProfileField(
          key: 'hasExistingBusiness',
          label: 'I already operate a business',
          kind: ProfileFieldKind.checkbox,
        ),
        ProfileField(key: 'notes', label: 'Anything else', kind: ProfileFieldKind.multiline),
      ],
    ),
  ],
  'landlord': const [
    ProfileStep(
      title: 'Your portfolio',
      subtitle: 'The essentials a brand screens on.',
      fields: [
        ProfileField(
          key: 'cities',
          label: 'Cities you hold property in',
          hint: 'Comma separated — e.g. London, Lahore',
        ),
        ProfileField(
          key: 'portfolioSize',
          label: 'Number of units in portfolio',
          kind: ProfileFieldKind.number,
        ),
        ProfileField(key: 'notes', label: 'Anything else', kind: ProfileFieldKind.multiline),
      ],
    ),
  ],
  // "Mall Owners" in the doc — the app's developer account type.
  'developer': const [
    ProfileStep(
      title: 'Your development',
      subtitle: 'What you are letting, and where.',
      fields: [
        ProfileField(key: 'projectName', label: 'Project name'),
        ProfileField(
          key: 'projectType',
          label: 'Project type',
          kind: ProfileFieldKind.select,
          options: [
            'Shopping mall',
            'Mixed-use development',
            'Lifestyle destination',
            'Commercial project',
          ],
        ),
        ProfileField(key: 'city', label: 'City'),
      ],
    ),
    ProfileStep(
      title: 'Scale & timing',
      subtitle: 'What brands ask before they commit.',
      fields: [
        ProfileField(key: 'totalUnits', label: 'Total units', kind: ProfileFieldKind.number),
        ProfileField(
          key: 'occupancyPercent',
          label: 'Current occupancy %',
          kind: ProfileFieldKind.number,
        ),
        ProfileField(key: 'openingDate', label: 'Opening date', hint: "Or 'open'"),
        ProfileField(key: 'notes', label: 'Anything else', kind: ProfileFieldKind.multiline),
      ],
    ),
  ],
  'investor': const [
    ProfileStep(
      title: 'Your mandate',
      subtitle: 'The shape of deal you want to see.',
      fields: [
        ProfileField(key: 'ticketMin', label: 'Ticket size from', kind: ProfileFieldKind.number),
        ProfileField(key: 'ticketMax', label: 'Ticket size to', kind: ProfileFieldKind.number),
        ProfileField(
          key: 'sectors',
          label: 'Sectors of interest',
          kind: ProfileFieldKind.multiSelect,
          options: _industries,
        ),
        ProfileField(
          key: 'investmentTypes',
          label: 'Investment types',
          hint: 'Comma separated — e.g. Equity, Joint venture',
        ),
        ProfileField(key: 'horizonMonths', label: 'Horizon (months)', kind: ProfileFieldKind.number),
      ],
    ),
    ProfileStep(
      title: 'Anything else',
      subtitle: 'Helps brands understand who they are talking to.',
      fields: [
        ProfileField(key: 'notes', label: 'Notes', kind: ProfileFieldKind.multiline),
      ],
    ),
  ],
  'vendor': const [
    ProfileStep(
      title: 'What you do',
      subtitle: 'The Partners Program roster listing.',
      fields: [
        ProfileField(
          key: 'discipline',
          label: 'Discipline',
          kind: ProfileFieldKind.select,
          options: _vendorDisciplineKeys,
          optionLabels: _vendorDisciplines,
        ),
        ProfileField(key: 'headline', label: 'Headline', hint: 'One line, shown under your name'),
        ProfileField(key: 'bio', label: 'About', kind: ProfileFieldKind.multiline),
        ProfileField(
          key: 'specialties',
          label: 'Specialties',
          hint: 'Comma separated — e.g. Store design, Fit-out management',
        ),
      ],
    ),
    ProfileStep(
      title: 'Track record',
      subtitle: 'What projects have you actually delivered.',
      fields: [
        ProfileField(
          key: 'citiesServed',
          label: 'Cities served',
          hint: 'Comma separated — e.g. London, Dubai, Lahore',
        ),
        ProfileField(key: 'yearsExperience', label: 'Years experience', kind: ProfileFieldKind.number),
        ProfileField(key: 'teamSize', label: 'Team size', kind: ProfileFieldKind.number),
        ProfileField(
          key: 'projectsCompleted',
          label: 'Projects completed',
          kind: ProfileFieldKind.number,
        ),
        ProfileField(key: 'website', label: 'Website'),
        ProfileField(key: 'contactEmail', label: 'Contact email'),
      ],
    ),
  ],
  // Deliberately narrower than the website's consultant onboarding, which
  // also collects a photo and repeatable Experience/Education entries —
  // see this file's doc comment for why those aren't here yet.
  'consultant': const [
    ProfileStep(
      title: 'Your roster profile',
      subtitle: "What Connectors' team reviews before it goes live.",
      fields: [
        ProfileField(key: 'title', label: 'Title', hint: 'e.g. Hospitality Operations Consultant'),
        ProfileField(key: 'yearsExperience', label: 'Years of experience', kind: ProfileFieldKind.number),
        ProfileField(key: 'bio', label: 'Bio', kind: ProfileFieldKind.multiline),
      ],
    ),
  ],
};

/// Every role gets the shared organization step first, then whatever's
/// specific to its type (none for a role this map doesn't cover, though
/// every current role has at least one).
List<ProfileStep> profileStepsFor(String? orgType) => [
      _organizationStep,
      ...?profileStepsByRole[orgType],
    ];

List<ProfileField> profileFieldsFor(String? orgType) =>
    profileStepsFor(orgType).expand((s) => s.fields).toList();

/// In-memory draft, seeded from the server (see AppShell's initState) and
/// pushed back to it on save — see ApiClient.fetchProfile/saveProfile.
/// Living in a notifier is what makes the completion meter on Home move
/// as fields are filled in, rather than being a static decoration.
class ProfileDraft {
  ProfileDraft._();

  static final values = ValueNotifier<Map<String, Object>>({});

  /// Separate from `values` deliberately — a photo isn't a form field with
  /// a "filled" state the completion meter counts, it's a resolved,
  /// ready-to-render URL the avatar widgets in Account/Edit profile both
  /// listen to, so a change (upload, or the initial seed) repaints both
  /// immediately without either screen re-fetching anything.
  static final photoUrl = ValueNotifier<String?>(null);

  /// Consultant only — a name-only subset of the real `expertise` column
  /// (which also carries an optional per-tag description; the website's
  /// own editor supports that, this one deliberately doesn't yet). Kept
  /// outside `values`/the generic ProfileField system for the same reason
  /// `photoUrl` is: this isn't a single scalar field, it's its own little
  /// editor with add/remove state.
  static final expertise = ValueNotifier<List<String>>([]);

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

  /// Replaces the whole draft — used once, right after a successful
  /// ApiClient.fetchProfile, rather than merged field-by-field.
  static void seed(Map<String, Object> fields) => values.value = fields;

  static void clear() {
    values.value = {};
    photoUrl.value = null;
    expertise.value = [];
  }

  static int filledCount(String? orgType) {
    final fields = profileFieldsFor(orgType);
    return fields.where((f) => values.value.containsKey(f.key)).length;
  }

  /// 0.0–1.0.
  static double completion(String? orgType) {
    final total = profileFieldsFor(orgType).length;
    if (total == 0) return 1;
    return filledCount(orgType) / total;
  }
}

/// Converts a raw JSON value from GET /api/mobile/profile into whatever
/// shape [field]'s own input widget expects. Array-valued columns
/// (countriesPresent, preferredCities, …) come back as real JSON arrays,
/// but every array field here is rendered as a comma-separated text input
/// rather than a multiSelect (multiSelect is reserved for fields with a
/// fixed option list, like industries) — those get joined into the same
/// "a, b, c" string ApiClient.saveProfile round-trips back through
/// writeProfile's own comma-splitting `list()` helper on the website.
Object? coerceProfileValue(ProfileField field, Object? raw) {
  if (raw == null) return null;
  switch (field.kind) {
    case ProfileFieldKind.checkbox:
      return raw == true;
    case ProfileFieldKind.multiSelect:
      return raw is List ? raw.map((e) => e.toString()).toList() : null;
    case ProfileFieldKind.upload:
      return null;
    case ProfileFieldKind.text:
    case ProfileFieldKind.number:
    case ProfileFieldKind.multiline:
    case ProfileFieldKind.select:
      return raw is List ? raw.map((e) => e.toString()).join(', ') : raw.toString();
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
    case ProfileFieldKind.checkbox:
      return Icons.check_box_outlined;
    case ProfileFieldKind.upload:
      return Icons.upload_file_rounded;
    case ProfileFieldKind.text:
      return Icons.edit_outlined;
  }
}

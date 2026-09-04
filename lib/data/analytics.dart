/// One bar in the "Messages by week" chart — a real count, not a mock one.
class WeekActivity {
  final String label;
  final int count;

  const WeekActivity({required this.label, required this.count});

  factory WeekActivity.fromJson(Map<String, dynamic> json) =>
      WeekActivity(label: json['label'] as String, count: json['count'] as int);
}

/// One row in "Your top listings" — only ever populated for an org that
/// actually owns properties (landlords/developers); empty otherwise.
class TopProperty {
  final String id;
  final String title;
  final String city;
  final int saves;

  const TopProperty({
    required this.id,
    required this.title,
    required this.city,
    required this.saves,
  });

  factory TopProperty.fromJson(Map<String, dynamic> json) => TopProperty(
    id: json['id'] as String,
    title: json['title'] as String,
    city: json['city'] as String,
    saves: json['saves'] as int,
  );
}

/// Backs the Analytics screen with real, org-scoped numbers only — see the
/// server's getOrgAnalytics doc comment for why "profile views" and
/// "introductions" (the two invented stats the screen used to show) aren't
/// here: nothing in the product tracks either one yet.
class OrgAnalytics {
  final int messagesSent30d;
  final int messagesSentPrev30d;
  final int repliesReceived30d;
  final int repliesReceivedPrev30d;
  final int savedByYou;
  final int savedByOthers;
  final List<WeekActivity> messagesByWeek;
  final List<TopProperty> topProperties;

  const OrgAnalytics({
    required this.messagesSent30d,
    required this.messagesSentPrev30d,
    required this.repliesReceived30d,
    required this.repliesReceivedPrev30d,
    required this.savedByYou,
    required this.savedByOthers,
    required this.messagesByWeek,
    required this.topProperties,
  });

  factory OrgAnalytics.fromJson(Map<String, dynamic> json) => OrgAnalytics(
    messagesSent30d: json['messagesSent30d'] as int,
    messagesSentPrev30d: json['messagesSentPrev30d'] as int,
    repliesReceived30d: json['repliesReceived30d'] as int,
    repliesReceivedPrev30d: json['repliesReceivedPrev30d'] as int,
    savedByYou: json['savedByYou'] as int,
    savedByOthers: json['savedByOthers'] as int,
    messagesByWeek: (json['messagesByWeek'] as List)
        .cast<Map<String, dynamic>>()
        .map(WeekActivity.fromJson)
        .toList(),
    topProperties: (json['topProperties'] as List)
        .cast<Map<String, dynamic>>()
        .map(TopProperty.fromJson)
        .toList(),
  );

  /// A real period-over-period delta — only computable for the two message
  /// stats, since favorites have no historical snapshot to diff against.
  /// Null means "nothing to compare" (both periods zero), rendered as no
  /// delta rather than a misleading "+0%".
  static String? delta(int current, int previous) {
    if (current == previous) return null;
    if (previous == 0) return '+$current';
    final pct = ((current - previous) / previous * 100).round();
    return pct > 0 ? '+$pct%' : '$pct%';
  }
}

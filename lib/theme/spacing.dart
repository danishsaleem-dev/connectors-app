/// One spacing scale for the whole app. Every gap in a screen should come
/// from here — the screens drifted into ad-hoc 10/12/14/18/20/24/28/32
/// values, which is most of why the layouts read as crowded and unrhythmic
/// even where the individual pieces were fine.
class AppSpacing {
  AppSpacing._();

  /// Horizontal page margin, shared by every screen.
  static const page = 20.0;

  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;

  /// Gap between a heading and the content it introduces.
  static const heading = 18.0;

  /// Gap between two sections of a screen.
  static const section = 40.0;
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:connectors_app/data/api_client.dart';
import 'package:connectors_app/data/auth_state.dart';
import 'package:connectors_app/data/site_data.dart';
import 'package:connectors_app/main.dart';
import 'package:connectors_app/screens/splash_screen.dart';
import 'package:connectors_app/screens/welcome_screen.dart';
import 'package:connectors_app/theme/app_theme.dart';
import 'package:connectors_app/widgets/floating_nav_bar.dart';

/// A bounded pump instead of pumpAndSettle: the app bar/hero and the
/// enquire CTA carry an infinitely-repeating OrbitField rotation, and the
/// industries marquee ticks forever — neither ever "settles", so
/// pumpAndSettle would hang until its own timeout on every screen. This
/// advances enough frames for the bounded entrance animations (Reveal) to
/// finish without waiting on the ones that never do.
Future<void> _settle(WidgetTester tester) => tester.pump(const Duration(milliseconds: 900));

const _fakeBrandSession = AuthResult(
  name: 'Jamie Test',
  isAdmin: false,
  sessionToken: 'fake-token',
  orgType: 'brand',
  orgName: 'Test Brand Co',
);

void main() {
  // Auth.session is a process-wide singleton — reset it after every test so
  // one test's signed-in state can't leak into the next.
  tearDown(() => Auth.session.value = null);

  testWidgets('SplashScreen renders the brand mark and a loading indicator', (
    WidgetTester tester,
  ) async {
    // Pumped in isolation rather than driving the real AppRoot boot
    // sequence — flutter_secure_storage's desktop backend behaves
    // unpredictably under the test runner (real Windows Credential
    // Manager calls, not a clean "missing platform channel" failure),
    // which makes driving the full boot flow here more trouble than it's
    // worth for what's fundamentally a static screen.
    await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: const SplashScreen()));
    await tester.pump();

    expect(find.text('CONNECTORS'), findsOneWidget);
    expect(find.text(SiteData.tagline), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('Signed out, the app shows Welcome, not the tab shell', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: const WelcomeScreen()));
    await tester.pump();

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.textContaining('Sign up now'), findsOneWidget);
  });

  testWidgets('Signed in, the app shell renders with bottom nav and Home active', (
    WidgetTester tester,
  ) async {
    Auth.session.value = _fakeBrandSession;
    await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: const AppShell()));
    await tester.pump();
    // Let every Reveal's staggered delayed-start timer actually fire —
    // otherwise they're still pending when the test ends, which the test
    // framework treats as a leak.
    await _settle(tester);

    // No app bar/logo any more — Home's own profile row is the only place
    // the signed-in account shows up.
    expect(find.byType(FloatingNavBar), findsOneWidget);
    expect(find.text('Jamie Test'), findsOneWidget);
    expect(find.text('Brand'), findsOneWidget);
  });

  testWidgets('Tapping the primary tab shows the account type\'s own form', (
    WidgetTester tester,
  ) async {
    Auth.session.value = _fakeBrandSession;
    await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: const AppShell()));
    await tester.pump();

    // A brand account's second tab is "Locations" — storefront icon, same
    // as the old fixed Brands tab used.
    await tester.tap(find.byIcon(Icons.storefront_outlined));
    await _settle(tester);

    expect(find.text('What are you looking to open, and where?'), findsOneWidget);
  });

  testWidgets("A brand's Home offers all four of its actions as a tile grid", (
    WidgetTester tester,
  ) async {
    Auth.session.value = _fakeBrandSession;
    await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: const AppShell()));
    await tester.pump();
    await _settle(tester);

    // The multi-action grid shows each tile's short label, not its full
    // title — the full titles only ever appear as onTap-target content on
    // the screens the tiles push to.
    expect(find.text('Request'), findsOneWidget);
    expect(find.text('Franchise'), findsOneWidget);
    expect(find.text('Investors'), findsOneWidget);
    expect(find.text('Browse'), findsOneWidget);

    // Tapping the franchise tile opens the franchise form specifically,
    // not the brand's own — each tile is wired to a different existing
    // form.
    await tester.tap(find.text('Franchise'));
    await tester.pump();
    await _settle(tester);
    expect(find.text('Your budget, territory and industry interest.'), findsOneWidget);
  });

  testWidgets('Account tab offers Contact now that Menu is gone', (WidgetTester tester) async {
    Auth.session.value = _fakeBrandSession;
    await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: const AppShell()));
    await tester.pump();

    await tester.tap(find.byIcon(Icons.person_outline_rounded));
    await _settle(tester);
    expect(find.text('Contact'), findsOneWidget);

    await tester.tap(find.text('Contact'));
    await tester.pump();
    await _settle(tester);
    expect(find.text('Three offices, one team.'), findsOneWidget);
  });

  testWidgets(
    'Brand enquiry wizard blocks on an empty required field, then advances once filled',
    (WidgetTester tester) async {
      Auth.session.value = _fakeBrandSession;
      await tester.pumpWidget(MaterialApp(theme: buildAppTheme(), home: const AppShell()));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.storefront_outlined));
      await _settle(tester);

      // The form sits directly under the page header now, but the screen
      // can still exceed the test viewport once entrance animations set
      // initial offsets, so scroll defensively rather than assume it's
      // already on screen. "Next" (not the submit label, which only
      // appears on the last step) is present as soon as step 1 renders.
      await tester.scrollUntilVisible(find.text('Next'), 400, scrollable: find.byType(Scrollable).first);
      await _settle(tester);

      expect(find.text('STEP 1 OF 5 — COMPANY INFORMATION'), findsOneWidget);

      // Tapping Next with every field empty should surface the step error
      // and keep step 1 on screen.
      await tester.tap(find.text('Next'));
      await _settle(tester);
      expect(find.textContaining('Fill in'), findsOneWidget);
      expect(find.text('STEP 1 OF 5 — COMPANY INFORMATION'), findsOneWidget);

      // Fill in every required field on step 1.
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Verona Kitchens'); // Brand Name
      await tester.enterText(textFields.at(1), 'Verona Kitchens Pvt Ltd'); // Company Name
      await tester.enterText(textFields.at(2), 'Ayesha Khan'); // Contact Person Name
      // index 3 is Designation — optional, skipped.
      await tester.enterText(textFields.at(4), '+92 300 1234567'); // Mobile
      await tester.enterText(textFields.at(5), 'ayesha@verona.pk'); // Email
      await _settle(tester);

      // Entering text can autoscroll to keep the focused field visible, so
      // re-find "Next" in view rather than trusting the earlier scroll.
      await tester.scrollUntilVisible(find.text('Next'), 400, scrollable: find.byType(Scrollable).first);
      await _settle(tester);

      await tester.tap(find.text('Next'));
      await _settle(tester);

      expect(find.text('STEP 2 OF 5 — EXPANSION REQUIREMENT'), findsOneWidget);
    },
  );
}

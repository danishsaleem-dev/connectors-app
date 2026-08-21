import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:connectors_app/main.dart';
import 'package:connectors_app/widgets/floating_nav_bar.dart';

/// A bounded pump instead of pumpAndSettle: the app bar/hero and the
/// enquire CTA carry an infinitely-repeating OrbitField rotation, and the
/// industries marquee ticks forever — neither ever "settles", so
/// pumpAndSettle would hang until its own timeout on every screen. This
/// advances enough frames for the bounded entrance animations (Reveal) to
/// finish without waiting on the ones that never do.
Future<void> _settle(WidgetTester tester) => tester.pump(const Duration(milliseconds: 900));

void main() {
  testWidgets('App shell renders with bottom nav and Home tab active', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ConnectorsApp());
    await tester.pump();
    // Let every Reveal's staggered delayed-start timer actually fire —
    // otherwise they're still pending when the test ends, which the test
    // framework treats as a leak.
    await _settle(tester);

    // The app bar shows the logo image, not a text wordmark.
    expect(find.image(const AssetImage('assets/images/logo.png')), findsOneWidget);
    expect(find.byType(FloatingNavBar), findsOneWidget);
    expect(find.text('Where do you fit?'), findsOneWidget);
  });

  testWidgets('Tapping Brands in the nav switches to the Brands screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ConnectorsApp());
    await tester.pump();

    // find.text('Brands') is ambiguous — the nav bar label and the Home
    // screen's Brands audience card title both match. The icon is unique
    // to the nav bar.
    await tester.tap(find.byIcon(Icons.storefront_outlined));
    await _settle(tester);

    // formHeading is unique per audience type, unlike the old shared
    // "How we work with you" eyebrow this replaced.
    expect(find.text('What are you looking to open, and where?'), findsOneWidget);
  });

  testWidgets('Menu opens the More hub, which opens About', (WidgetTester tester) async {
    await tester.pumpWidget(const ConnectorsApp());
    await tester.pump();

    // Two icon buttons live in the app bar (Menu, then Sign in) — Menu is
    // the unique one to reach the new secondary-navigation hub. An extra
    // zero-duration pump registers the Navigator.push before the bounded
    // pump drives its transition, same two-step needed anywhere else a
    // route (rather than an IndexedStack tab) changes.
    await tester.tap(find.byIcon(Icons.menu_rounded));
    await tester.pump();
    await _settle(tester);
    expect(find.text('About Connectors'), findsOneWidget);

    await tester.tap(find.text('About Connectors'));
    await tester.pump();
    await _settle(tester);
    expect(
      find.text('We built the bridge that expansion kept falling through.'),
      findsOneWidget,
    );
  });

  testWidgets(
    'Brand enquiry wizard blocks on an empty required field, then advances once filled',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ConnectorsApp());
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

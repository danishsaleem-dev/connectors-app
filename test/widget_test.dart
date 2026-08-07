import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:connectors_app/main.dart';

void main() {
  testWidgets('App shell renders with bottom nav and Home tab active', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ConnectorsApp());
    await tester.pump();

    // The app bar shows the logo image, not a text wordmark.
    expect(find.image(const AssetImage('assets/images/logo.png')), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Four doors into the same network.'), findsOneWidget);
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
    await tester.pumpAndSettle();

    // Eyebrow renders its text uppercased.
    expect(find.text('HOW WE WORK WITH YOU'), findsOneWidget);
  });

  testWidgets(
    'Brand enquiry wizard blocks on an empty required field, then advances once filled',
    (WidgetTester tester) async {
      await tester.pumpWidget(const ConnectorsApp());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.storefront_outlined));
      await tester.pumpAndSettle();

      // Scroll the form into view — it's below the divisions section. "Next"
      // (not the submit label, which only appears on the last step) is
      // present as soon as step 1 renders.
      await tester.scrollUntilVisible(find.text('Next'), 400, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      expect(find.text('STEP 1 OF 5 — COMPANY INFORMATION'), findsOneWidget);

      // Tapping Next with every field empty should surface the step error
      // and keep step 1 on screen.
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
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
      await tester.pumpAndSettle();

      // Entering text can autoscroll to keep the focused field visible, so
      // re-find "Next" in view rather than trusting the earlier scroll.
      await tester.scrollUntilVisible(find.text('Next'), 400, scrollable: find.byType(Scrollable).first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();

      expect(find.text('STEP 2 OF 5 — EXPANSION REQUIREMENT'), findsOneWidget);
    },
  );
}

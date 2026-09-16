import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:leak_lens/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('LeakLens App launches with neo-brutalist UI',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const LeakLensApp());
    await tester.pump();

    // Brand + version badge
    expect(find.text('LeakLens'), findsOneWidget);
    expect(find.text('v1.1'), findsOneWidget);
    expect(find.text('AIR-GAPPED'), findsOneWidget);

    // Neo nav labels (also present as toolbar stickers — allow multiple)
    expect(find.text('PASTE'), findsWidgets);
    expect(find.text('SCAN'), findsOneWidget);

    // Default status
    expect(find.text('SAFE TO PUSH'), findsOneWidget);

    // Theme toggle present
    expect(find.byTooltip('Toggle light / dark mode'), findsOneWidget);
  });

  testWidgets('Theme toggle switches between dark and light',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const LeakLensApp());
    await tester.pump();

    BuildContext appContext() => tester.element(find.text('LeakLens'));
    expect(Theme.of(appContext()).brightness, Brightness.dark);

    await tester.tap(find.byTooltip('Toggle light / dark mode'));
    await tester.pumpAndSettle();
    expect(Theme.of(appContext()).brightness, Brightness.light);

    await tester.tap(find.byTooltip('Toggle light / dark mode'));
    await tester.pumpAndSettle();
    expect(Theme.of(appContext()).brightness, Brightness.dark);
  });
}
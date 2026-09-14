import 'package:flutter_test/flutter_test.dart';
import 'package:leak_lens/main.dart';

void main() {
  testWidgets('LeakLens App launches and displays terminal UI',
      (WidgetTester tester) async {
    await tester.pumpWidget(const LeakLensApp());
    await tester.pump();

    // Verify terminal app bar title
    expect(find.text('LeakLens'), findsOneWidget);
    expect(find.text('v1.0'), findsOneWidget);
    expect(find.text('AIR-GAPPED'), findsOneWidget);
    expect(find.text('Safe to push'), findsOneWidget);
    expect(find.text('Paste Buffer'), findsOneWidget);
  });
}

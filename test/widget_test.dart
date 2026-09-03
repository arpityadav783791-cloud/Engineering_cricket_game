import 'package:flutter_test/flutter_test.dart';
import 'package:engineering_cricket/main.dart';

void main() {
  testWidgets('HandCricketApp loads and navigates successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const HandCricketApp());
    expect(find.byType(HandCricketApp), findsOneWidget);

    // Advance past splash timer
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pump();
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:engineering_cricket/widgets/exit_confirmation_dialog.dart';

void main() {
  testWidgets('ExitConfirmationDialog shows title with sad emoji and dismisses with false on stay', (tester) async {
    bool? dialogResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                dialogResult = await ExitConfirmationDialog.show(context);
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify Title with sad emoji
    expect(find.text('Leaving so soon?'), findsOneWidget);
    // Verify emoji badge
    expect(find.text('🥺'), findsOneWidget);
    // Verify action buttons
    expect(find.text('STAY & PLAY'), findsOneWidget);
    expect(find.text('LEAVE'), findsOneWidget);

    // Tap Stay & Play
    await tester.tap(find.text('STAY & PLAY'));
    await tester.pumpAndSettle();

    expect(dialogResult, isFalse);
  });

  testWidgets('ExitConfirmationDialog dismisses with true when leave button tapped', (tester) async {
    bool? dialogResult;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                dialogResult = await ExitConfirmationDialog.show(context);
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Tap Leave
    await tester.tap(find.text('LEAVE'));
    await tester.pumpAndSettle();

    expect(dialogResult, isTrue);
  });
}

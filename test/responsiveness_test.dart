import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:engineering_cricket/controllers/game_controller.dart';
import 'package:engineering_cricket/screens/home_screen.dart';
import 'package:engineering_cricket/screens/toss_screen.dart';
import 'package:engineering_cricket/screens/game_screen.dart';
import 'package:engineering_cricket/screens/result_screen.dart';

void main() {
  final testSizes = [
    const Size(320, 568), // Small phone (iPhone SE / budget Android)
    const Size(360, 640), // Standard Android
    const Size(412, 915), // Tall flagship
    const Size(700, 400), // Landscape mobile
    const Size(800, 1200), // Tablet
  ];

  for (final size in testSizes) {
    testWidgets('HomeScreen renders without overflow at ${size.width}x${size.height}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = GameController();
      await tester.pumpWidget(MaterialApp(home: HomeScreen(gameController: controller)));
      await tester.pump();
      final error = tester.takeException();
      if (error != null) {
        debugPrint(error.toString());
        if (error is FlutterError) {
          debugPrint(error.toStringDeep());
        }
      }
      expect(error, isNull);
    });

    testWidgets('TossScreen renders without overflow at ${size.width}x${size.height}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = GameController();
      await tester.pumpWidget(MaterialApp(home: TossScreen(gameController: controller)));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('GameScreen renders without overflow at ${size.width}x${size.height}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = GameController();
      controller.chooseOddEven(OddEvenChoice.odd);
      controller.chooseBatOrBowl(PlayDecision.bat);

      await tester.pumpWidget(MaterialApp(home: GameScreen(gameController: controller)));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });

    testWidgets('ResultScreen renders without overflow at ${size.width}x${size.height}', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final controller = GameController();
      controller.finishMatch(MatchResult.humanWin);

      await tester.pumpWidget(MaterialApp(home: ResultScreen(gameController: controller)));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }
}

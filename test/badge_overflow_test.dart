import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:engineering_cricket/widgets/hand_gesture_badge.dart';

void main() {
  testWidgets('HandGestureBadge does not overflow at any size or text scale', (tester) async {
    final sizes = [40.0, 44.0, 48.0, 50.0, 52.0, 56.0, 60.0];
    final textScales = [1.0, 1.2, 1.5, 2.0];
    final numbers = [1, 2, 3, 4, 5, 6, 10];

    for (final scale in textScales) {
      for (final size in sizes) {
        for (final num in numbers) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: MediaQuery(
                  data: MediaQueryData(textScaler: TextScaler.linear(scale)),
                  child: Center(
                    child: HandGestureBadge(
                      number: num,
                      size: size,
                      isSelected: true,
                      showFingers: true,
                    ),
                  ),
                ),
              ),
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull,
              reason: 'Overflow occurred for number $num at size $size with textScale $scale');
        }
      }
    }
  });
}

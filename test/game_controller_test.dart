import 'package:flutter_test/flutter_test.dart';
import 'package:engineering_cricket/controllers/game_controller.dart';

void main() {
  group('GameController Initial State', () {
    test('game starts with correct default values', () {
      final controller = GameController();

      expect(
        controller.currentPhase,
        GamePhase.tossChoice,
      );

      expect(controller.humanScore, 0);
      expect(controller.computerScore, 0);
      expect(controller.target, 0);

      expect(
        controller.matchResult,
        MatchResult.none,
      );

      expect(controller.isOut, false);
    });
  });

  group('Odd Even Selection', () {
    test('human can choose odd', () {
      final controller = GameController();

      controller.chooseOddEven(
        OddEvenChoice.odd,
      );

      expect(
        controller.humanOddEvenChoice,
        OddEvenChoice.odd,
      );

      expect(
        controller.currentPhase,
        GamePhase.tossNumberSelection,
      );
    });

    test('human can choose even', () {
      final controller = GameController();

      controller.chooseOddEven(
        OddEvenChoice.even,
      );

      expect(
        controller.humanOddEvenChoice,
        OddEvenChoice.even,
      );

      expect(
        controller.currentPhase,
        GamePhase.tossNumberSelection,
      );
    });
  });

  group('Allowed Number Validation', () {
    test('toss numbers contain only 1 to 5', () {
      expect(
        GameController.tossNumbers,
        [1, 2, 3, 4, 5],
      );
    });

    test('gameplay numbers are correct', () {
      expect(
        GameController.playNumbers,
        [1, 2, 3, 4, 5, 6, 10],
      );
    });

    test('gameplay numbers do not contain 0', () {
      expect(
        GameController.playNumbers.contains(0),
        false,
      );
    });

    test('gameplay numbers do not contain 7', () {
      expect(
        GameController.playNumbers.contains(7),
        false,
      );
    });

    test('gameplay numbers do not contain 8', () {
      expect(
        GameController.playNumbers.contains(8),
        false,
      );
    });

    test('gameplay numbers do not contain 9', () {
      expect(
        GameController.playNumbers.contains(9),
        false,
      );
    });

    test('gameplay numbers contain 10', () {
      expect(
        GameController.playNumbers.contains(10),
        true,
      );
    });
  });

  group('OUT Logic', () {
    test('same numbers mean OUT', () {
      final controller = GameController();

      final result = controller.checkOut(
        4,
        4,
      );

      expect(result, true);
    });

    test('different numbers do not mean OUT', () {
      final controller = GameController();

      final result = controller.checkOut(
        4,
        2,
      );

      expect(result, false);
    });

    test('10 and 10 mean OUT', () {
      final controller = GameController();

      final result = controller.checkOut(
        10,
        10,
      );

      expect(result, true);
    });

    test('6 and 6 mean OUT', () {
      final controller = GameController();

      final result = controller.checkOut(
        6,
        6,
      );

      expect(result, true);
    });
  });

  group('Random Number Generation', () {
    test('computer toss number is always valid', () {
      final controller = GameController();

      for (int i = 0; i < 100; i++) {
        final number =
            controller.generateComputerTossNumber();

        expect(
          GameController.tossNumbers.contains(number),
          true,
        );
      }
    });

    test('computer gameplay number is always valid', () {
      final controller = GameController();

      for (int i = 0; i < 100; i++) {
        final number =
            controller.generateComputerPlayNumber();

        expect(
          GameController.playNumbers.contains(number),
          true,
        );
      }
    });
  });

  group('Reset Logic', () {
    test('reset restores initial state', () {
      final controller = GameController();

      controller.chooseOddEven(
        OddEvenChoice.odd,
      );

      expect(
        controller.currentPhase,
        GamePhase.tossNumberSelection,
      );

      controller.resetGame();

      expect(
        controller.currentPhase,
        GamePhase.tossChoice,
      );

      expect(
        controller.humanOddEvenChoice,
        null,
      );

      expect(controller.humanScore, 0);
      expect(controller.computerScore, 0);
      expect(controller.target, 0);

      expect(
        controller.matchResult,
        MatchResult.none,
      );

      expect(controller.isOut, false);
    });
  });
}
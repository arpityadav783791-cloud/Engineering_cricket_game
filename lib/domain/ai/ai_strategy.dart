import 'dart:math';
import '../../models/match_enums.dart';
import 'rookie_ai_strategy.dart';
import 'club_ai_strategy.dart';
import 'pro_mind_reader_ai_strategy.dart';

/// Context passed to AI when deciding next play number.
class AiContext {
  const AiContext({
    required this.recentHumanNumbers,
    required this.isBatting,
    required this.currentScore,
    required this.targetScore,
    required this.random,
  });

  final List<int> recentHumanNumbers;
  final bool isBatting;
  final int currentScore;
  final int targetScore;
  final Random random;
}

/// Abstract strategy contract for AI opponents (OCP & LSP).
abstract class AiStrategy {
  const AiStrategy();

  static const List<int> tossNumbers = [1, 2, 3, 4, 5];
  static const List<int> playNumbers = [1, 2, 3, 4, 5, 6, 10];

  int generateTossNumber(Random random) {
    return tossNumbers[random.nextInt(tossNumbers.length)];
  }

  int generatePlayNumber(AiContext context);

  static AiStrategy forDifficulty(AiDifficulty difficulty) {
    switch (difficulty) {
      case AiDifficulty.rookie:
        return const RookieAiStrategy();
      case AiDifficulty.club:
        return const ClubAiStrategy();
      case AiDifficulty.pro:
        return const ProMindReaderAiStrategy();
    }
  }
}

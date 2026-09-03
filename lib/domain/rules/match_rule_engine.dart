import '../../models/match_enums.dart';
import 'classic_rule_engine.dart';
import 'three_wickets_rule_engine.dart';
import 'super_over_rule_engine.dart';

/// Contract defining match rules for various formats (Open/Closed Principle & Liskov Substitution).
abstract class MatchRuleEngine {
  const MatchRuleEngine();

  int get maxWickets;
  int get maxBalls;

  bool checkOut(int humanNumber, int computerNumber) {
    return humanNumber == computerNumber;
  }

  bool isChaseTargetExceeded(int chasingScore, int firstInningsScore) {
    return chasingScore > firstInningsScore;
  }

  bool isInningsFinished({required int wicketsFallen, required int ballsBowled});

  static MatchRuleEngine forMode(MatchMode mode) {
    switch (mode) {
      case MatchMode.classic:
        return const ClassicRuleEngine();
      case MatchMode.threeWickets:
        return const ThreeWicketsRuleEngine();
      case MatchMode.superOver:
        return const SuperOverRuleEngine();
    }
  }
}

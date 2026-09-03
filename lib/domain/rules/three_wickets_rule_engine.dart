import 'match_rule_engine.dart';

/// 3 Wickets format: 3 wickets per side, unlimited balls.
class ThreeWicketsRuleEngine extends MatchRuleEngine {
  const ThreeWicketsRuleEngine();

  @override
  int get maxWickets => 3;

  @override
  int get maxBalls => 999;

  @override
  bool isInningsFinished({required int wicketsFallen, required int ballsBowled}) {
    return wicketsFallen >= maxWickets;
  }
}

import 'match_rule_engine.dart';

/// Classic sudden death: 1 wicket per side, unlimited balls.
class ClassicRuleEngine extends MatchRuleEngine {
  const ClassicRuleEngine();

  @override
  int get maxWickets => 1;

  @override
  int get maxBalls => 999;

  @override
  bool isInningsFinished({required int wicketsFallen, required int ballsBowled}) {
    return wicketsFallen >= maxWickets;
  }
}

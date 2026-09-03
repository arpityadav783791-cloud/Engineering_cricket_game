import 'match_rule_engine.dart';

/// Super Over format: 6 balls or 1 wicket per innings.
class SuperOverRuleEngine extends MatchRuleEngine {
  const SuperOverRuleEngine();

  @override
  int get maxWickets => 1;

  @override
  int get maxBalls => 6;

  @override
  bool isInningsFinished({required int wicketsFallen, required int ballsBowled}) {
    return wicketsFallen >= maxWickets || ballsBowled >= maxBalls;
  }
}

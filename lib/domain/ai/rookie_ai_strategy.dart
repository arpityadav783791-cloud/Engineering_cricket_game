import 'ai_strategy.dart';

/// Rookie AI: Pure random play selection.
class RookieAiStrategy extends AiStrategy {
  const RookieAiStrategy();

  @override
  int generatePlayNumber(AiContext context) {
    return AiStrategy.playNumbers[context.random.nextInt(AiStrategy.playNumbers.length)];
  }
}

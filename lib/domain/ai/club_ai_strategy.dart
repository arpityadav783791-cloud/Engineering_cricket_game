import 'ai_strategy.dart';

/// Club AI: Balanced selection with preference for common cricket numbers.
class ClubAiStrategy extends AiStrategy {
  const ClubAiStrategy();

  static const List<int> _weightedPool = [1, 1, 2, 2, 3, 4, 4, 5, 6, 6, 10];

  @override
  int generatePlayNumber(AiContext context) {
    return _weightedPool[context.random.nextInt(_weightedPool.length)];
  }
}

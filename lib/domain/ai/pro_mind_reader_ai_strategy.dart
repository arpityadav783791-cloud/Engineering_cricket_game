import 'ai_strategy.dart';

/// Pro Mind Reader AI: Analyzes recent human move frequencies and counter-predicts.
class ProMindReaderAiStrategy extends AiStrategy {
  const ProMindReaderAiStrategy();

  @override
  int generatePlayNumber(AiContext context) {
    // 45% chance to predict the human's most frequent recent number
    if (context.recentHumanNumbers.isNotEmpty && context.random.nextDouble() < 0.45) {
      final counts = <int, int>{};
      for (final n in context.recentHumanNumbers) {
        counts[n] = (counts[n] ?? 0) + 1;
      }
      final mostFrequent = counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      return mostFrequent;
    }

    return AiStrategy.playNumbers[context.random.nextInt(AiStrategy.playNumbers.length)];
  }
}

import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:engineering_cricket/domain/ai/ai_strategy.dart';
import 'package:engineering_cricket/domain/rules/match_rule_engine.dart';
import 'package:engineering_cricket/controllers/toss_manager.dart';
import 'package:engineering_cricket/controllers/game_controller.dart';
import 'package:engineering_cricket/domain/repositories/career_stats_repository.dart';
import 'package:engineering_cricket/domain/repositories/match_history_repository.dart';
import 'package:engineering_cricket/domain/repositories/settings_repository.dart';

// Fake repositories for testing Dependency Inversion (DIP)
class FakeHistoryRepository implements MatchHistoryRepository {
  final List<MatchHistoryEntry> list = [];
  @override
  Future<List<MatchHistoryEntry>> getMatchHistory() async => list;
  @override
  Future<void> saveMatch(MatchHistoryEntry entry) async => list.insert(0, entry);
  @override
  Future<void> clearHistory() async => list.clear();
}

class FakeStatsRepository implements CareerStatsRepository {
  CareerStats stats = CareerStats.empty;
  @override
  Future<CareerStats> getCareerStats() async => stats;
  @override
  Future<void> saveCareerStats(CareerStats s) async => stats = s;
  @override
  Future<void> resetCareerStats() async => stats = CareerStats.empty;
}

class FakeSettingsRepository implements SettingsRepository {
  GameSettingsData data = const GameSettingsData();
  @override
  Future<GameSettingsData> getSettings() async => data;
  @override
  Future<void> saveDifficulty(AiDifficulty difficulty) async {
    data = GameSettingsData(difficulty: difficulty, matchMode: data.matchMode);
  }
  @override
  Future<void> saveMatchMode(MatchMode matchMode) async {
    data = GameSettingsData(difficulty: data.difficulty, matchMode: matchMode);
  }
}

void main() {
  group('SOLID - Rule Engines (OCP & LSP)', () {
    test('Classic rule engine ends innings after 1 wicket', () {
      final engine = MatchRuleEngine.forMode(MatchMode.classic);
      expect(engine.maxWickets, 1);
      expect(engine.maxBalls, 999);
      expect(engine.isInningsFinished(wicketsFallen: 0, ballsBowled: 5), isFalse);
      expect(engine.isInningsFinished(wicketsFallen: 1, ballsBowled: 5), isTrue);
    });

    test('Three Wickets rule engine allows 3 wickets', () {
      final engine = MatchRuleEngine.forMode(MatchMode.threeWickets);
      expect(engine.maxWickets, 3);
      expect(engine.isInningsFinished(wicketsFallen: 2, ballsBowled: 20), isFalse);
      expect(engine.isInningsFinished(wicketsFallen: 3, ballsBowled: 20), isTrue);
    });

    test('Super Over rule engine caps balls to 6', () {
      final engine = MatchRuleEngine.forMode(MatchMode.superOver);
      expect(engine.maxBalls, 6);
      expect(engine.isInningsFinished(wicketsFallen: 0, ballsBowled: 5), isFalse);
      expect(engine.isInningsFinished(wicketsFallen: 0, ballsBowled: 6), isTrue);
      expect(engine.isInningsFinished(wicketsFallen: 1, ballsBowled: 2), isTrue);
    });
  });

  group('SOLID - AI Strategies (OCP & LSP)', () {
    test('AI strategies generate valid play numbers', () {
      final random = Random(42);
      final rookie = AiStrategy.forDifficulty(AiDifficulty.rookie);
      final club = AiStrategy.forDifficulty(AiDifficulty.club);
      final pro = AiStrategy.forDifficulty(AiDifficulty.pro);

      final ctx = AiContext(
        recentHumanNumbers: [4, 4, 4, 6],
        isBatting: true,
        currentScore: 10,
        targetScore: 20,
        random: random,
      );

      expect(AiStrategy.playNumbers.contains(rookie.generatePlayNumber(ctx)), isTrue);
      expect(AiStrategy.playNumbers.contains(club.generatePlayNumber(ctx)), isTrue);
      expect(AiStrategy.playNumbers.contains(pro.generatePlayNumber(ctx)), isTrue);
    });
  });

  group('SOLID - TossManager (SRP)', () {
    test('TossManager evaluates odd/even correctly', () {
      final toss = TossManager();
      toss.chooseOddEven(OddEvenChoice.odd);

      // Human 3 + CPU 2 = 5 (Odd) -> Human wins
      toss.executeToss(humanNum: 3, computerNum: 2);
      expect(toss.total, 5);
      expect(toss.parity, OddEvenChoice.odd);
      expect(toss.winner, PlayerType.human);
      expect(toss.humanWon, isTrue);

      // Reset
      toss.reset();
      expect(toss.total, isNull);
      expect(toss.winner, isNull);
    });
  });

  group('SOLID - Dependency Inversion in GameController (DIP)', () {
    test('GameController functions seamlessly with injected fake repositories', () async {
      final fakeHistory = FakeHistoryRepository();
      final fakeStats = FakeStatsRepository();
      final fakeSettings = FakeSettingsRepository();

      final controller = GameController(
        historyRepository: fakeHistory,
        statsRepository: fakeStats,
        settingsRepository: fakeSettings,
      );

      await controller.loadMatchHistory();
      expect(controller.careerMatchesPlayed, 0);

      controller.setDifficulty(AiDifficulty.pro);
      expect(controller.difficulty, AiDifficulty.pro);
      expect(fakeSettings.data.difficulty, AiDifficulty.pro);

      controller.setMatchMode(MatchMode.threeWickets);
      expect(controller.matchMode, MatchMode.threeWickets);
      expect(controller.maxWickets, 3);
      expect(fakeSettings.data.matchMode, MatchMode.threeWickets);
    });
  });
}

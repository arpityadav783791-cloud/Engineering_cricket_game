import '../../models/match_enums.dart';

class GameSettingsData {
  const GameSettingsData({
    this.difficulty = AiDifficulty.club,
    this.matchMode = MatchMode.classic,
  });

  final AiDifficulty difficulty;
  final MatchMode matchMode;
}

/// Contract for game preferences and configuration persistence (DIP).
abstract class SettingsRepository {
  Future<GameSettingsData> getSettings();
  Future<void> saveDifficulty(AiDifficulty difficulty);
  Future<void> saveMatchMode(MatchMode matchMode);
}

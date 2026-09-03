import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../models/match_enums.dart';

class SharedPrefsSettingsRepository implements SettingsRepository {
  static const String _difficultyKey = 'hand_cricket_difficulty';
  static const String _matchModeKey = 'hand_cricket_match_mode';

  @override
  Future<GameSettingsData> getSettings() async {
    final prefs = await SharedPreferences.getInstance();

    AiDifficulty diff = AiDifficulty.club;
    final diffIndex = prefs.getInt(_difficultyKey);
    if (diffIndex != null && diffIndex >= 0 && diffIndex < AiDifficulty.values.length) {
      diff = AiDifficulty.values[diffIndex];
    }

    MatchMode mode = MatchMode.classic;
    final modeIndex = prefs.getInt(_matchModeKey);
    if (modeIndex != null && modeIndex >= 0 && modeIndex < MatchMode.values.length) {
      mode = MatchMode.values[modeIndex];
    }

    return GameSettingsData(difficulty: diff, matchMode: mode);
  }

  @override
  Future<void> saveDifficulty(AiDifficulty difficulty) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_difficultyKey, difficulty.index);
  }

  @override
  Future<void> saveMatchMode(MatchMode matchMode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_matchModeKey, matchMode.index);
  }
}

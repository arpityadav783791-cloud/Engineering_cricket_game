import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/career_stats_repository.dart';
import '../../models/career_stats.dart';

class SharedPrefsCareerStatsRepository implements CareerStatsRepository {
  static const String _storageKey = 'hand_cricket_career_stats';

  @override
  Future<CareerStats> getCareerStats() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return CareerStats.empty;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return CareerStats.fromJson(map);
    } catch (_) {
      return CareerStats.empty;
    }
  }

  @override
  Future<void> saveCareerStats(CareerStats stats) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(stats.toJson()));
  }

  @override
  Future<void> resetCareerStats() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

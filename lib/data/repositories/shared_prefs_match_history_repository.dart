import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/repositories/match_history_repository.dart';
import '../../models/match_history_entry.dart';

class SharedPrefsMatchHistoryRepository implements MatchHistoryRepository {
  static const String _storageKey = 'hand_cricket_match_history';

  @override
  Future<List<MatchHistoryEntry>> getMatchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final rawList = prefs.getStringList(_storageKey);
    if (rawList == null) return [];

    final list = <MatchHistoryEntry>[];
    for (final item in rawList) {
      try {
        final decoded = jsonDecode(item) as Map<String, dynamic>;
        list.add(MatchHistoryEntry.fromJson(decoded));
      } catch (_) {}
    }
    return list;
  }

  @override
  Future<void> saveMatch(MatchHistoryEntry entry) async {
    final current = await getMatchHistory();
    current.insert(0, entry);
    if (current.length > 20) {
      current.removeRange(20, current.length);
    }

    final prefs = await SharedPreferences.getInstance();
    final encoded = current.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_storageKey, encoded);
  }

  @override
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}

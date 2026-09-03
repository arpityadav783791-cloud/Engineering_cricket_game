import '../../models/match_history_entry.dart';

/// Contract for Match History persistence (Dependency Inversion Principle).
abstract class MatchHistoryRepository {
  Future<List<MatchHistoryEntry>> getMatchHistory();
  Future<void> saveMatch(MatchHistoryEntry entry);
  Future<void> clearHistory();
}

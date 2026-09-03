import 'match_enums.dart';

class MatchHistoryEntry {
  const MatchHistoryEntry({
    required this.humanScore,
    required this.computerScore,
    required this.result,
    required this.firstBatsman,
    required this.playedAt,
    this.humanBalls = 0,
    this.computerBalls = 0,
  });

  final int humanScore;
  final int computerScore;
  final MatchResult result;
  final PlayerType firstBatsman;
  final DateTime playedAt;
  final int humanBalls;
  final int computerBalls;

  Map<String, dynamic> toJson() {
    return {
      'humanScore': humanScore,
      'computerScore': computerScore,
      'result': result.name,
      'firstBatsman': firstBatsman.name,
      'playedAt': playedAt.toIso8601String(),
      'humanBalls': humanBalls,
      'computerBalls': computerBalls,
    };
  }

  factory MatchHistoryEntry.fromJson(Map<String, dynamic> json) {
    return MatchHistoryEntry(
      humanScore: json['humanScore'] as int,
      computerScore: json['computerScore'] as int,
      result: MatchResult.values.firstWhere(
        (value) => value.name == json['result'],
      ),
      firstBatsman: PlayerType.values.firstWhere(
        (value) => value.name == json['firstBatsman'],
      ),
      playedAt: DateTime.parse(json['playedAt'] as String),
      humanBalls: (json['humanBalls'] as int?) ?? 0,
      computerBalls: (json['computerBalls'] as int?) ?? 0,
    );
  }
}

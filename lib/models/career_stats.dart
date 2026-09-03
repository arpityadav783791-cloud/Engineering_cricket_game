class CareerStats {
  const CareerStats({
    this.matchesPlayed = 0,
    this.matchesWon = 0,
    this.highestScore = 0,
    this.totalFours = 0,
    this.totalSixes = 0,
    this.totalTens = 0,
    this.wicketsTaken = 0,
  });

  final int matchesPlayed;
  final int matchesWon;
  final int highestScore;
  final int totalFours;
  final int totalSixes;
  final int totalTens;
  final int wicketsTaken;

  double get winRate =>
      matchesPlayed > 0 ? (matchesWon / matchesPlayed * 100) : 0.0;

  CareerStats copyWith({
    int? matchesPlayed,
    int? matchesWon,
    int? highestScore,
    int? totalFours,
    int? totalSixes,
    int? totalTens,
    int? wicketsTaken,
  }) {
    return CareerStats(
      matchesPlayed: matchesPlayed ?? this.matchesPlayed,
      matchesWon: matchesWon ?? this.matchesWon,
      highestScore: highestScore ?? this.highestScore,
      totalFours: totalFours ?? this.totalFours,
      totalSixes: totalSixes ?? this.totalSixes,
      totalTens: totalTens ?? this.totalTens,
      wicketsTaken: wicketsTaken ?? this.wicketsTaken,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'matchesPlayed': matchesPlayed,
      'matchesWon': matchesWon,
      'highestScore': highestScore,
      'totalFours': totalFours,
      'totalSixes': totalSixes,
      'totalTens': totalTens,
      'wicketsTaken': wicketsTaken,
    };
  }

  factory CareerStats.fromJson(Map<String, dynamic> json) {
    return CareerStats(
      matchesPlayed: (json['matchesPlayed'] as int?) ?? 0,
      matchesWon: (json['matchesWon'] as int?) ?? 0,
      highestScore: (json['highestScore'] as int?) ?? 0,
      totalFours: (json['totalFours'] as int?) ?? 0,
      totalSixes: (json['totalSixes'] as int?) ?? 0,
      totalTens: (json['totalTens'] as int?) ?? 0,
      wicketsTaken: (json['wicketsTaken'] as int?) ?? 0,
    );
  }

  static const empty = CareerStats();
}

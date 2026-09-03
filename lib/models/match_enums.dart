/// Current stage of the match.
enum GamePhase {
  tossChoice,
  tossNumberSelection,
  tossResult,
  batBowlDecision,
  firstInnings,
  inningsBreak,
  secondInnings,
  matchFinished,
}

/// Human's Odd / Even toss choice.
enum OddEvenChoice {
  odd,
  even,
}

/// Bat or Bowl decision.
enum PlayDecision {
  bat,
  bowl,
}

/// Identifies a player.
enum PlayerType {
  human,
  computer,
}

/// Final match result.
enum MatchResult {
  none,
  humanWin,
  computerWin,
  tie,
}

/// AI Difficulty levels.
enum AiDifficulty {
  rookie,
  club,
  pro,
}

/// Match format mode.
enum MatchMode {
  classic,      // 1 Wicket sudden death
  threeWickets, // 3 Wickets per innings
  superOver,    // 6 Balls blitz per innings
}

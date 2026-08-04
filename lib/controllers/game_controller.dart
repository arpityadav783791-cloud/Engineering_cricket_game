import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Current stages of the match.
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

class MatchHistoryEntry {
  const MatchHistoryEntry({
    required this.humanScore,
    required this.computerScore,
    required this.result,
    required this.firstBatsman,
    required this.playedAt,
  });

  final int humanScore;
  final int computerScore;
  final MatchResult result;
  final PlayerType firstBatsman;
  final DateTime playedAt;

  Map<String, dynamic> toJson() {
    return {
      'humanScore': humanScore,
      'computerScore': computerScore,
      'result': result.name,
      'firstBatsman': firstBatsman.name,
      'playedAt': playedAt.toIso8601String(),
    };
  }

  factory MatchHistoryEntry.fromJson(
    Map<String, dynamic> json,
  ) {
    return MatchHistoryEntry(
      humanScore: json['humanScore'] as int,
      computerScore: json['computerScore'] as int,
      result: MatchResult.values.firstWhere(
        (value) => value.name == json['result'],
      ),
      firstBatsman: PlayerType.values.firstWhere(
        (value) => value.name == json['firstBatsman'],
      ),
      playedAt: DateTime.parse(
        json['playedAt'] as String,
      ),
    );
  }
}

class GameController extends ChangeNotifier {
  static const String _historyStorageKey = 'hand_cricket_match_history';
  final List<MatchHistoryEntry> _matchHistory = [];
  
  bool _currentMatchSaved = false;
  
  List<MatchHistoryEntry> get matchHistory => List.unmodifiable(_matchHistory);

  GameController({Random? random}) : _random = random ?? Random();

  final Random _random;

  // ============================================================
  // ALLOWED NUMBERS
  // ============================================================

  /// Toss uses only 1 to 5.
  static const List<int> tossNumbers = [1, 2, 3, 4, 5];

  /// Actual batting / bowling uses these values.
  static const List<int> playNumbers = [1, 2, 3, 4, 5, 6, 10];

  // ============================================================
  // GAME PHASE
  // ============================================================

  GamePhase _currentPhase = GamePhase.tossChoice;

  GamePhase get currentPhase => _currentPhase;

  // ============================================================
  // TOSS STATE
  // ============================================================

  OddEvenChoice? _humanOddEvenChoice;
  OddEvenChoice? _tossResultParity;

  int? _humanTossNumber;
  int? _computerTossNumber;
  int? _tossTotal;

  PlayerType? _tossWinner;

  OddEvenChoice? get humanOddEvenChoice => _humanOddEvenChoice;
  OddEvenChoice? get tossResultParity => _tossResultParity;

  int? get humanTossNumber => _humanTossNumber;
  int? get computerTossNumber => _computerTossNumber;
  int? get tossTotal => _tossTotal;

  PlayerType? get tossWinner => _tossWinner;

  // ============================================================
  // BAT / BOWL DECISION
  // ============================================================

  PlayDecision? _tossDecision;

  PlayDecision? get tossDecision => _tossDecision;

  // ============================================================
  // PLAYER ROLES
  // ============================================================

  PlayerType? _firstInningsBatsman;
  PlayerType? _secondInningsBatsman;

  PlayerType? _currentBatsman;
  PlayerType? _currentBowler;

  PlayerType? get firstInningsBatsman => _firstInningsBatsman;
  PlayerType? get secondInningsBatsman => _secondInningsBatsman;

  PlayerType? get currentBatsman => _currentBatsman;
  PlayerType? get currentBowler => _currentBowler;

  // ============================================================
  // SCORE STATE
  // ============================================================

  int _humanScore = 0;
  int _computerScore = 0;

  int _firstInningsScore = 0;
  int _target = 0;

  int get humanScore => _humanScore;
  int get computerScore => _computerScore;

  int get firstInningsScore => _firstInningsScore;
  int get target => _target;

  // ============================================================
  // TURN STATE
  // ============================================================

  int? _humanSelectedNumber;
  int? _computerSelectedNumber;

  int _turnNumber = 0;

  bool _isOut = false;
  PlayerType? _lastOutPlayer;

  int? get humanSelectedNumber => _humanSelectedNumber;
  int? get computerSelectedNumber => _computerSelectedNumber;

  int get turnNumber => _turnNumber;

  bool get isOut => _isOut;
  PlayerType? get lastOutPlayer => _lastOutPlayer;

  // ============================================================
  // MATCH RESULT
  // ============================================================

  MatchResult _matchResult = MatchResult.none;

  MatchResult get matchResult => _matchResult;

  // ============================================================
  // HELPER GETTERS
  // ============================================================

  bool get isHumanBatting => _currentBatsman == PlayerType.human;

  bool get isComputerBatting =>
      _currentBatsman == PlayerType.computer;

  bool get isFirstInnings =>
      _currentPhase == GamePhase.firstInnings;

  bool get isSecondInnings =>
      _currentPhase == GamePhase.secondInnings;

  bool get isMatchFinished =>
      _currentPhase == GamePhase.matchFinished;

  bool get humanWonToss =>
      _tossWinner == PlayerType.human;

  bool get computerWonToss =>
      _tossWinner == PlayerType.computer;

  /// Score of the player currently batting.
  int get currentBatsmanScore {
    if (_currentBatsman == PlayerType.human) {
      return _humanScore;
    }

    if (_currentBatsman == PlayerType.computer) {
      return _computerScore;
    }

    return 0;
  }

  /// During second innings, how many more runs are needed to win.
  int get runsNeeded {
    if (_currentPhase != GamePhase.secondInnings) {
      return 0;
    }

    final currentScore = currentBatsmanScore;
    final needed = _target - currentScore;

    return needed > 0 ? needed : 0;
  }

  // ============================================================
  // 1. CHOOSE ODD / EVEN
  // ============================================================

  void chooseOddEven(OddEvenChoice choice) {
    if (_currentPhase != GamePhase.tossChoice) {
      return;
    }

    _humanOddEvenChoice = choice;

    _currentPhase = GamePhase.tossNumberSelection;

    notifyListeners();
  }

  // ============================================================
  // 2. PLAY TOSS
  // ============================================================

  void playToss(int humanNumber) {
    if (_currentPhase != GamePhase.tossNumberSelection) {
      return;
    }

    if (_humanOddEvenChoice == null) {
      return;
    }

    if (!tossNumbers.contains(humanNumber)) {
      return;
    }

    _humanTossNumber = humanNumber;

    _computerTossNumber = generateComputerTossNumber();

    _tossTotal =
        _humanTossNumber! + _computerTossNumber!;

    // Determine parity of total.
    if (_tossTotal! % 2 == 0) {
      _tossResultParity = OddEvenChoice.even;
    } else {
      _tossResultParity = OddEvenChoice.odd;
    }

    // Human wins if parity matches human choice.
    if (_tossResultParity == _humanOddEvenChoice) {
      _tossWinner = PlayerType.human;
    } else {
      _tossWinner = PlayerType.computer;
    }

    _currentPhase = GamePhase.tossResult;

    notifyListeners();
  }

  // ============================================================
  // 3. CONTINUE AFTER TOSS RESULT
  // ============================================================

  void continueAfterToss() {
    if (_currentPhase != GamePhase.tossResult) {
      return;
    }

    if (_tossWinner == PlayerType.human) {
      // Human must manually choose Bat or Bowl.
      _currentPhase = GamePhase.batBowlDecision;

      notifyListeners();
      return;
    }

    if (_tossWinner == PlayerType.computer) {
      // Computer chooses automatically.
      computerChooseBatOrBowl();
    }
  }

  // ============================================================
  // 4. HUMAN CHOOSES BAT / BOWL
  // ============================================================

  void chooseBatOrBowl(PlayDecision decision) {
    if (_currentPhase != GamePhase.batBowlDecision) {
      return;
    }

    if (_tossWinner != PlayerType.human) {
      return;
    }

    _tossDecision = decision;

    _assignInningsRoles(
      decisionMaker: PlayerType.human,
      decision: decision,
    );

    _startFirstInnings();
  }

  // ============================================================
  // 5. COMPUTER CHOOSES BAT / BOWL
  // ============================================================

  void computerChooseBatOrBowl() {
    if (_tossWinner != PlayerType.computer) {
      return;
    }

    if (_currentPhase != GamePhase.tossResult &&
        _currentPhase != GamePhase.batBowlDecision) {
      return;
    }

    final randomDecision = _random.nextBool()
        ? PlayDecision.bat
        : PlayDecision.bowl;

    _tossDecision = randomDecision;

    _assignInningsRoles(
      decisionMaker: PlayerType.computer,
      decision: randomDecision,
    );

    _startFirstInnings();
  }

  // ============================================================
  // ASSIGN FIRST / SECOND INNINGS ROLES
  // ============================================================

  void _assignInningsRoles({
    required PlayerType decisionMaker,
    required PlayDecision decision,
  }) {
    if (decision == PlayDecision.bat) {
      _firstInningsBatsman = decisionMaker;

      _secondInningsBatsman =
          _opponentOf(decisionMaker);
    } else {
      _firstInningsBatsman =
          _opponentOf(decisionMaker);

      _secondInningsBatsman = decisionMaker;
    }
  }

  // ============================================================
  // START FIRST INNINGS
  // ============================================================

  void _startFirstInnings() {
    if (_firstInningsBatsman == null) {
      return;
    }

    _currentBatsman = _firstInningsBatsman;
    _currentBowler = _opponentOf(_currentBatsman!);

    _currentPhase = GamePhase.firstInnings;

    _humanSelectedNumber = null;
    _computerSelectedNumber = null;

    _isOut = false;
    _lastOutPlayer = null;

    notifyListeners();
  }

  // ============================================================
  // 6. PLAY ONE TURN
  // ============================================================

  void playTurn(int humanNumber) {
    // No turns after match finishes.
    if (_currentPhase == GamePhase.matchFinished) {
      return;
    }

    // Turns only allowed during innings.
    if (_currentPhase != GamePhase.firstInnings &&
        _currentPhase != GamePhase.secondInnings) {
      return;
    }

    // Validate human gameplay number.
    if (!playNumbers.contains(humanNumber)) {
      return;
    }

    // Store human selection.
    _humanSelectedNumber = humanNumber;

    // Generate computer selection.
    _computerSelectedNumber =
        generateComputerPlayNumber();

    _turnNumber++;

    // Always check OUT before adding score.
    if (checkOut(
      _humanSelectedNumber!,
      _computerSelectedNumber!,
    )) {
      _processOut();

      notifyListeners();
      return;
    }

    // Numbers are different.
    _isOut = false;
    _lastOutPlayer = null;

    // Add only batsman's number.
    updateScore();

    // During chase, immediately check victory.
    if (_currentPhase == GamePhase.secondInnings) {
      checkChaseTarget();
    }

    notifyListeners();
  }

  // ============================================================
  // 7. CHECK OUT
  // ============================================================

  bool checkOut(
    int humanNumber,
    int computerNumber,
  ) {
    return humanNumber == computerNumber;
  }

  // ============================================================
  // PROCESS OUT
  // ============================================================

  void _processOut() {
    _isOut = true;
    _lastOutPlayer = _currentBatsman;

    // Matching number is deliberately NOT added.

    if (_currentPhase == GamePhase.firstInnings) {
      endFirstInnings();
      return;
    }

    if (_currentPhase == GamePhase.secondInnings) {
      _finishSecondInningsAfterOut();
    }
  }

  // ============================================================
  // 8. UPDATE SCORE
  // ============================================================

  void updateScore() {
    if (_humanSelectedNumber == null ||
        _computerSelectedNumber == null ||
        _currentBatsman == null) {
      return;
    }

    // Human batting:
    // Add human selected number.
    if (_currentBatsman == PlayerType.human) {
      _humanScore += _humanSelectedNumber!;
      return;
    }

    // Computer batting:
    // Add computer selected number.
    if (_currentBatsman == PlayerType.computer) {
      _computerScore += _computerSelectedNumber!;
    }
  }

  // ============================================================
  // 9. END FIRST INNINGS
  // ============================================================

  void endFirstInnings() {
    if (_currentPhase != GamePhase.firstInnings) {
      return;
    }

    if (_currentBatsman == PlayerType.human) {
      _firstInningsScore = _humanScore;
    } else if (_currentBatsman == PlayerType.computer) {
      _firstInningsScore = _computerScore;
    } else {
      return;
    }

    // Target is one more than first innings score.
    _target = _firstInningsScore + 1;

    _currentPhase = GamePhase.inningsBreak;
  }

  // ============================================================
  // 10. START SECOND INNINGS
  // ============================================================

  void startSecondInnings() {
    if (_currentPhase != GamePhase.inningsBreak) {
      return;
    }

    if (_secondInningsBatsman == null) {
      return;
    }

    _currentBatsman = _secondInningsBatsman;
    _currentBowler = _opponentOf(_currentBatsman!);

    _humanSelectedNumber = null;
    _computerSelectedNumber = null;

    _isOut = false;
    _lastOutPlayer = null;

    _currentPhase = GamePhase.secondInnings;

    notifyListeners();
  }

  // ============================================================
  // 11. CHECK CHASE TARGET
  // ============================================================

  void checkChaseTarget() {
    if (_currentPhase != GamePhase.secondInnings) {
      return;
    }

    if (_currentBatsman == PlayerType.human) {
      // Human must exceed first innings score.
      if (_humanScore > _firstInningsScore) {
        finishMatch(MatchResult.humanWin);
      }

      return;
    }

    if (_currentBatsman == PlayerType.computer) {
      // Computer must exceed first innings score.
      if (_computerScore > _firstInningsScore) {
        finishMatch(MatchResult.computerWin);
      }
    }
  }

  // ============================================================
  // SECOND INNINGS OUT RESULT
  // ============================================================

  void _finishSecondInningsAfterOut() {
    if (_currentBatsman == null) {
      return;
    }

    final chasingScore = currentBatsmanScore;

    // Chaser OUT with equal score = tie.
    if (chasingScore == _firstInningsScore) {
      finishMatch(MatchResult.tie);
      return;
    }

    // Human was chasing and got out below target.
    if (_currentBatsman == PlayerType.human) {
      finishMatch(MatchResult.computerWin);
      return;
    }

    // Computer was chasing and got out below target.
    if (_currentBatsman == PlayerType.computer) {
      finishMatch(MatchResult.humanWin);
    }
  }

  // ============================================================
  // 12. FINISH MATCH
  // ============================================================

  void finishMatch(MatchResult result) {
    if (_currentPhase == GamePhase.matchFinished) {
      return;
    }

    _matchResult = result;
    _currentPhase = GamePhase.matchFinished;
    saveCompletedMatch();
  }

  // ============================================================
  // 13. RANDOM TOSS NUMBER
  // ============================================================

  int generateComputerTossNumber() {
    final index = _random.nextInt(tossNumbers.length);

    return tossNumbers[index];
  }

  // ============================================================
  // 14. RANDOM GAMEPLAY NUMBER
  // ============================================================

  int generateComputerPlayNumber() {
    final index = _random.nextInt(playNumbers.length);

    return playNumbers[index];
  }

  // ============================================================
  // GET OPPONENT
  // ============================================================

  PlayerType _opponentOf(PlayerType player) {
    if (player == PlayerType.human) {
      return PlayerType.computer;
    }

    return PlayerType.human;
  }

  // ============================================================
  // 15. RESET GAME
  // ============================================================

  void resetGame() {
    _currentMatchSaved = false;

    // Phase
    _currentPhase = GamePhase.tossChoice;

    // Toss
    _humanOddEvenChoice = null;
    _tossResultParity = null;

    _humanTossNumber = null;
    _computerTossNumber = null;
    _tossTotal = null;

    _tossWinner = null;

    // Decision
    _tossDecision = null;

    // Roles
    _firstInningsBatsman = null;
    _secondInningsBatsman = null;

    _currentBatsman = null;
    _currentBowler = null;

    // Scores
    _humanScore = 0;
    _computerScore = 0;

    _firstInningsScore = 0;
    _target = 0;

    // Turn
    _humanSelectedNumber = null;
    _computerSelectedNumber = null;

    _turnNumber = 0;

    // Out
    _isOut = false;
    _lastOutPlayer = null;

    // Result
    _matchResult = MatchResult.none;

    notifyListeners();
  }
  Future<void> loadMatchHistory() async {
    final preferences =
        await SharedPreferences.getInstance();

    final savedHistory =
        preferences.getStringList(_historyStorageKey);

    _matchHistory.clear();

    if (savedHistory == null) {
      notifyListeners();
      return;
    }

    for (final item in savedHistory) {
      try {
        final decoded =
            jsonDecode(item) as Map<String, dynamic>;

        _matchHistory.add(
          MatchHistoryEntry.fromJson(decoded),
        );
      } catch (_) {
      // Ignore corrupted history entries.
      }
    }

    if (_matchHistory.length > 10) {
      _matchHistory.removeRange(
        10,
        _matchHistory.length,
      );
    }

    notifyListeners();
  }

  Future<void> _saveMatchHistory() async {
    final preferences =
        await SharedPreferences.getInstance();

    final encodedHistory = _matchHistory
        .take(10)
        .map(
          (entry) => jsonEncode(entry.toJson()),
        )
        .toList();

    await preferences.setStringList(
      _historyStorageKey,
      encodedHistory,
    );
  }

  Future<void> saveCompletedMatch() async {
    if (_currentMatchSaved) {
      return;
    }

    if (currentPhase != GamePhase.matchFinished) {
      return;
    }

    if (matchResult == MatchResult.none) {
      return;
    }

    if (firstInningsBatsman == null) {
      return;
    }

    _currentMatchSaved = true;

    final entry = MatchHistoryEntry(
      humanScore: humanScore,
      computerScore: computerScore,
      result: matchResult,
      firstBatsman: firstInningsBatsman!,
      playedAt: DateTime.now(),
    );

    _matchHistory.insert(0, entry);

    if (_matchHistory.length > 10) {
      _matchHistory.removeRange(
        10,
      _matchHistory.length,
      );
    }

    notifyListeners();

    await _saveMatchHistory();
  }

  Future<void> clearMatchHistory() async {
    _matchHistory.clear();

    final preferences =
        await SharedPreferences.getInstance();

    await preferences.remove(
      _historyStorageKey,
    );

    notifyListeners();
  }  
}
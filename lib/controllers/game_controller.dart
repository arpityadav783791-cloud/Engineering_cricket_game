import 'dart:math';
import 'package:flutter/foundation.dart';

import '../data/repositories/shared_prefs_career_stats_repository.dart';
import '../data/repositories/shared_prefs_match_history_repository.dart';
import '../data/repositories/shared_prefs_settings_repository.dart';
import '../domain/ai/ai_strategy.dart';
import '../domain/repositories/career_stats_repository.dart';
import '../domain/repositories/match_history_repository.dart';
import '../domain/repositories/settings_repository.dart';
import '../domain/rules/match_rule_engine.dart';
import '../models/career_stats.dart';
import '../models/match_enums.dart';
import '../models/match_history_entry.dart';
import '../models/turn_log_entry.dart';
import 'toss_manager.dart';

// Re-export models for backward compatibility and clean presentation imports
export '../models/career_stats.dart';
export '../models/match_enums.dart';
export '../models/match_history_entry.dart';
export '../models/turn_log_entry.dart';

/// Clean Coordinator & State Notifier implementing SOLID principles (DIP, SRP, OCP, LSP).
class GameController extends ChangeNotifier {
  GameController({
    MatchHistoryRepository? historyRepository,
    CareerStatsRepository? statsRepository,
    SettingsRepository? settingsRepository,
    Random? random,
  })  : _historyRepo = historyRepository ?? SharedPrefsMatchHistoryRepository(),
        _statsRepo = statsRepository ?? SharedPrefsCareerStatsRepository(),
        _settingsRepo = settingsRepository ?? SharedPrefsSettingsRepository(),
        _random = random ?? Random(),
        _tossManager = TossManager() {
    _ruleEngine = MatchRuleEngine.forMode(_matchMode);
    _aiStrategy = AiStrategy.forDifficulty(_difficulty);
  }

  // ============================================================
  // INJECTED DEPENDENCIES (DIP)
  // ============================================================

  final MatchHistoryRepository _historyRepo;
  final CareerStatsRepository _statsRepo;
  final SettingsRepository _settingsRepo;
  final Random _random;
  final TossManager _tossManager;

  late MatchRuleEngine _ruleEngine;
  late AiStrategy _aiStrategy;

  // ============================================================
  // ALLOWED NUMBERS
  // ============================================================

  static const List<int> tossNumbers = AiStrategy.tossNumbers;
  static const List<int> playNumbers = AiStrategy.playNumbers;

  // ============================================================
  // STATE CACHES
  // ============================================================

  final List<MatchHistoryEntry> _matchHistory = [];
  final List<TurnLogEntry> _turnLogs = [];
  final List<int> _recentHumanNumbers = [];
  CareerStats _careerStats = CareerStats.empty;
  bool _currentMatchSaved = false;

  // ============================================================
  // CONFIGURATION & MODES (OCP)
  // ============================================================

  AiDifficulty _difficulty = AiDifficulty.club;
  MatchMode _matchMode = MatchMode.classic;

  AiDifficulty get difficulty => _difficulty;
  MatchMode get matchMode => _matchMode;

  void setDifficulty(AiDifficulty diff) {
    _difficulty = diff;
    _aiStrategy = AiStrategy.forDifficulty(diff);
    _settingsRepo.saveDifficulty(diff);
    notifyListeners();
  }

  void setMatchMode(MatchMode mode) {
    _matchMode = mode;
    _ruleEngine = MatchRuleEngine.forMode(mode);
    _settingsRepo.saveMatchMode(mode);
    notifyListeners();
  }

  // ============================================================
  // CAREER STATS GETTERS
  // ============================================================

  CareerStats get careerStats => _careerStats;
  int get careerMatchesPlayed => _careerStats.matchesPlayed;
  int get careerMatchesWon => _careerStats.matchesWon;
  int get careerHighestScore => _careerStats.highestScore;
  int get careerTotalFours => _careerStats.totalFours;
  int get careerTotalSixes => _careerStats.totalSixes;
  int get careerTotalTens => _careerStats.totalTens;
  int get careerWicketsTaken => _careerStats.wicketsTaken;
  double get careerWinRate => _careerStats.winRate;

  // ============================================================
  // GAME PHASE
  // ============================================================

  GamePhase _currentPhase = GamePhase.tossChoice;
  GamePhase get currentPhase => _currentPhase;

  // ============================================================
  // TOSS STATE (Delegated to TossManager - SRP)
  // ============================================================

  OddEvenChoice? get humanOddEvenChoice => _tossManager.humanChoice;
  OddEvenChoice? get tossResultParity => _tossManager.parity;
  int? get humanTossNumber => _tossManager.humanNumber;
  int? get computerTossNumber => _tossManager.computerNumber;
  int? get tossTotal => _tossManager.total;
  PlayerType? get tossWinner => _tossManager.winner;
  PlayDecision? get tossDecision => _tossManager.decision;

  bool get humanWonToss => _tossManager.humanWon;
  bool get computerWonToss => _tossManager.computerWon;

  // ============================================================
  // ROLES & PLAYERS
  // ============================================================

  PlayerType? _firstInningsBatsman;
  PlayerType? _secondInningsBatsman;
  PlayerType? _currentBatsman;
  PlayerType? _currentBowler;

  PlayerType? get firstInningsBatsman => _firstInningsBatsman;
  PlayerType? get secondInningsBatsman => _secondInningsBatsman;
  PlayerType? get currentBatsman => _currentBatsman;
  PlayerType? get currentBowler => _currentBowler;

  bool get isHumanBatting => _currentBatsman == PlayerType.human;
  bool get isComputerBatting => _currentBatsman == PlayerType.computer;

  // ============================================================
  // SCORES, WICKETS, BOUNDARIES
  // ============================================================

  int _humanScore = 0;
  int _computerScore = 0;
  int _humanWicketsFallen = 0;
  int _computerWicketsFallen = 0;
  int _humanBallsFaced = 0;
  int _computerBallsFaced = 0;

  int _humanFours = 0;
  int _humanSixes = 0;
  int _humanTens = 0;
  int _computerFours = 0;
  int _computerSixes = 0;
  int _computerTens = 0;

  int _firstInningsScore = 0;
  int _target = 0;

  int get humanScore => _humanScore;
  int get computerScore => _computerScore;
  int get humanWicketsFallen => _humanWicketsFallen;
  int get computerWicketsFallen => _computerWicketsFallen;

  int get maxWickets => _ruleEngine.maxWickets;
  int get maxBallsPerInnings => _ruleEngine.maxBalls;

  int get currentBatsmanWicketsFallen =>
      isHumanBatting ? _humanWicketsFallen : _computerWicketsFallen;

  int get humanBallsFaced => _humanBallsFaced;
  int get computerBallsFaced => _computerBallsFaced;

  int get humanFours => _humanFours;
  int get humanSixes => _humanSixes;
  int get humanTens => _humanTens;
  int get computerFours => _computerFours;
  int get computerSixes => _computerSixes;
  int get computerTens => _computerTens;

  int get firstInningsScore => _firstInningsScore;
  int get target => _target;

  int get currentBatsmanScore =>
      isHumanBatting ? _humanScore : _computerScore;

  int get runsNeeded {
    if (_currentPhase != GamePhase.secondInnings) return 0;
    final needed = _target - currentBatsmanScore;
    return needed > 0 ? needed : 0;
  }

  double get humanStrikeRate =>
      _humanBallsFaced > 0 ? (_humanScore / _humanBallsFaced * 100) : 0.0;

  double get computerStrikeRate =>
      _computerBallsFaced > 0 ? (_computerScore / _computerBallsFaced * 100) : 0.0;

  // ============================================================
  // TURN & SHOWDOWN STATE
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
  // MATCH RESULT & LOGS
  // ============================================================

  MatchResult _matchResult = MatchResult.none;
  MatchResult get matchResult => _matchResult;

  bool get isFirstInnings => _currentPhase == GamePhase.firstInnings;
  bool get isSecondInnings => _currentPhase == GamePhase.secondInnings;
  bool get isMatchFinished => _currentPhase == GamePhase.matchFinished;

  List<MatchHistoryEntry> get matchHistory => List.unmodifiable(_matchHistory);
  List<TurnLogEntry> get turnLogs => List.unmodifiable(_turnLogs);

  List<TurnLogEntry> get currentInningsLogs {
    final curInnings = isSecondInnings ? 2 : 1;
    return _turnLogs.where((l) => l.innings == curInnings).toList();
  }

  // ============================================================
  // 1. TOSS ACTIONS
  // ============================================================

  void chooseOddEven(OddEvenChoice choice) {
    if (_currentPhase != GamePhase.tossChoice) return;
    _tossManager.chooseOddEven(choice);
    _currentPhase = GamePhase.tossNumberSelection;
    notifyListeners();
  }

  void playToss(int humanNumber) {
    if (_currentPhase != GamePhase.tossNumberSelection) return;
    if (_tossManager.humanChoice == null) return;
    if (!tossNumbers.contains(humanNumber)) return;

    final computerNumber = _aiStrategy.generateTossNumber(_random);
    _tossManager.executeToss(humanNum: humanNumber, computerNum: computerNumber);

    _currentPhase = GamePhase.tossResult;
    notifyListeners();
  }

  void continueAfterToss() {
    if (_currentPhase != GamePhase.tossResult) return;

    if (_tossManager.winner == PlayerType.human) {
      _currentPhase = GamePhase.batBowlDecision;
      notifyListeners();
      return;
    }

    if (_tossManager.winner == PlayerType.computer) {
      computerChooseBatOrBowl();
    }
  }

  void chooseBatOrBowl(PlayDecision decision) {
    if (_currentPhase != GamePhase.batBowlDecision) return;
    if (_tossManager.winner != PlayerType.human) return;

    _tossManager.setDecision(decision);
    _assignInningsRoles(decisionMaker: PlayerType.human, decision: decision);
    _startFirstInnings();
  }

  void computerChooseBatOrBowl() {
    if (_tossManager.winner != PlayerType.computer) return;
    if (_currentPhase != GamePhase.tossResult &&
        _currentPhase != GamePhase.batBowlDecision) {
      return;
    }

    final decision = _random.nextBool() ? PlayDecision.bat : PlayDecision.bowl;
    _tossManager.setDecision(decision);
    _assignInningsRoles(decisionMaker: PlayerType.computer, decision: decision);
    _startFirstInnings();
  }

  void _assignInningsRoles({
    required PlayerType decisionMaker,
    required PlayDecision decision,
  }) {
    if (decision == PlayDecision.bat) {
      _firstInningsBatsman = decisionMaker;
      _secondInningsBatsman = _opponentOf(decisionMaker);
    } else {
      _firstInningsBatsman = _opponentOf(decisionMaker);
      _secondInningsBatsman = decisionMaker;
    }
  }

  void _startFirstInnings() {
    if (_firstInningsBatsman == null) return;

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
  // 2. TURN EXECUTION
  // ============================================================

  void playTurn(int humanNumber) {
    if (_currentPhase == GamePhase.matchFinished) return;
    if (_currentPhase != GamePhase.firstInnings &&
        _currentPhase != GamePhase.secondInnings) {
      return;
    }
    if (!playNumbers.contains(humanNumber)) return;

    _humanSelectedNumber = humanNumber;
    _recentHumanNumbers.add(humanNumber);
    if (_recentHumanNumbers.length > 8) _recentHumanNumbers.removeAt(0);

    // Generate AI move via Strategy (OCP & LSP)
    _computerSelectedNumber = _aiStrategy.generatePlayNumber(
      AiContext(
        recentHumanNumbers: _recentHumanNumbers,
        isBatting: isComputerBatting,
        currentScore: _computerScore,
        targetScore: _target,
        random: _random,
      ),
    );

    _turnNumber++;

    if (isHumanBatting) {
      _humanBallsFaced++;
    } else {
      _computerBallsFaced++;
    }

    // Check OUT via Rule Engine (OCP & LSP)
    final isWicket = _ruleEngine.checkOut(
      _humanSelectedNumber!,
      _computerSelectedNumber!,
    );

    if (isWicket) {
      _turnLogs.add(TurnLogEntry(
        ballNumber: _turnNumber,
        runs: 0,
        isOut: true,
        batsman: _currentBatsman!,
        humanNumber: _humanSelectedNumber!,
        computerNumber: _computerSelectedNumber!,
        innings: isSecondInnings ? 2 : 1,
      ));

      if (isComputerBatting) {
        _careerStats = _careerStats.copyWith(
          wicketsTaken: _careerStats.wicketsTaken + 1,
        );
      }

      _processOut();
      notifyListeners();
      return;
    }

    _isOut = false;
    _lastOutPlayer = null;

    final runs = isHumanBatting ? _humanSelectedNumber! : _computerSelectedNumber!;

    _turnLogs.add(TurnLogEntry(
      ballNumber: _turnNumber,
      runs: runs,
      isOut: false,
      batsman: _currentBatsman!,
      humanNumber: _humanSelectedNumber!,
      computerNumber: _computerSelectedNumber!,
      innings: isSecondInnings ? 2 : 1,
    ));

    updateScore();

    // Check balls limit via Rule Engine
    final currentBalls = isFirstInnings
        ? (_firstInningsBatsman == PlayerType.human ? _humanBallsFaced : _computerBallsFaced)
        : (_secondInningsBatsman == PlayerType.human ? _humanBallsFaced : _computerBallsFaced);

    final currentWickets = currentBatsmanWicketsFallen;

    if (_ruleEngine.isInningsFinished(
      wicketsFallen: currentWickets,
      ballsBowled: currentBalls,
    )) {
      if (isFirstInnings) {
        endFirstInnings();
        notifyListeners();
        return;
      } else {
        _finishSecondInningsByOvers();
        notifyListeners();
        return;
      }
    }

    // During chase, check target exceeded
    if (_currentPhase == GamePhase.secondInnings) {
      checkChaseTarget();
    }

    notifyListeners();
  }

  bool checkOut(int humanNumber, int computerNumber) {
    return _ruleEngine.checkOut(humanNumber, computerNumber);
  }

  void _processOut() {
    _isOut = true;
    _lastOutPlayer = _currentBatsman;

    if (isHumanBatting) {
      _humanWicketsFallen++;
    } else {
      _computerWicketsFallen++;
    }

    // Check if more wickets remain before finishing innings
    final currentBalls = isFirstInnings
        ? (_firstInningsBatsman == PlayerType.human ? _humanBallsFaced : _computerBallsFaced)
        : (_secondInningsBatsman == PlayerType.human ? _humanBallsFaced : _computerBallsFaced);

    if (!_ruleEngine.isInningsFinished(
      wicketsFallen: currentBatsmanWicketsFallen,
      ballsBowled: currentBalls,
    )) {
      return;
    }

    if (_currentPhase == GamePhase.firstInnings) {
      endFirstInnings();
      return;
    }

    if (_currentPhase == GamePhase.secondInnings) {
      _finishSecondInningsAfterOut();
    }
  }

  void updateScore() {
    if (_humanSelectedNumber == null ||
        _computerSelectedNumber == null ||
        _currentBatsman == null) {
      return;
    }

    if (isHumanBatting) {
      final runs = _humanSelectedNumber!;
      _humanScore += runs;
      if (runs == 4) {
        _humanFours++;
        _careerStats = _careerStats.copyWith(totalFours: _careerStats.totalFours + 1);
      } else if (runs == 6) {
        _humanSixes++;
        _careerStats = _careerStats.copyWith(totalSixes: _careerStats.totalSixes + 1);
      } else if (runs == 10) {
        _humanTens++;
        _careerStats = _careerStats.copyWith(totalTens: _careerStats.totalTens + 1);
      }
    } else {
      final runs = _computerSelectedNumber!;
      _computerScore += runs;
      if (runs == 4) _computerFours++;
      if (runs == 6) _computerSixes++;
      if (runs == 10) _computerTens++;
    }
  }

  void endFirstInnings() {
    if (_currentPhase != GamePhase.firstInnings) return;

    _firstInningsScore = isHumanBatting ? _humanScore : _computerScore;
    _target = _firstInningsScore + 1;
    _currentPhase = GamePhase.inningsBreak;
  }

  void startSecondInnings() {
    if (_currentPhase != GamePhase.inningsBreak) return;
    if (_secondInningsBatsman == null) return;

    _currentBatsman = _secondInningsBatsman;
    _currentBowler = _opponentOf(_currentBatsman!);

    _humanSelectedNumber = null;
    _computerSelectedNumber = null;
    _isOut = false;
    _lastOutPlayer = null;

    _currentPhase = GamePhase.secondInnings;
    notifyListeners();
  }

  void checkChaseTarget() {
    if (_currentPhase != GamePhase.secondInnings) return;

    if (isHumanBatting) {
      if (_ruleEngine.isChaseTargetExceeded(_humanScore, _firstInningsScore)) {
        finishMatch(MatchResult.humanWin);
      }
      return;
    }

    if (isComputerBatting) {
      if (_ruleEngine.isChaseTargetExceeded(_computerScore, _firstInningsScore)) {
        finishMatch(MatchResult.computerWin);
      }
    }
  }

  void _finishSecondInningsByOvers() {
    if (_currentBatsman == null) return;
    final chasingScore = currentBatsmanScore;

    if (chasingScore > _firstInningsScore) {
      finishMatch(isHumanBatting ? MatchResult.humanWin : MatchResult.computerWin);
    } else if (chasingScore == _firstInningsScore) {
      finishMatch(MatchResult.tie);
    } else {
      finishMatch(isHumanBatting ? MatchResult.computerWin : MatchResult.humanWin);
    }
  }

  void _finishSecondInningsAfterOut() {
    if (_currentBatsman == null) return;

    final chasingScore = currentBatsmanScore;

    if (chasingScore == _firstInningsScore) {
      finishMatch(MatchResult.tie);
      return;
    }

    if (isHumanBatting) {
      finishMatch(MatchResult.computerWin);
      return;
    }

    if (isComputerBatting) {
      finishMatch(MatchResult.humanWin);
    }
  }

  void finishMatch(MatchResult result) {
    if (_currentPhase == GamePhase.matchFinished) return;

    _matchResult = result;
    _currentPhase = GamePhase.matchFinished;

    final newPlayed = _careerStats.matchesPlayed + 1;
    final newWon = result == MatchResult.humanWin
        ? _careerStats.matchesWon + 1
        : _careerStats.matchesWon;
    final newHigh = _humanScore > _careerStats.highestScore
        ? _humanScore
        : _careerStats.highestScore;

    _careerStats = _careerStats.copyWith(
      matchesPlayed: newPlayed,
      matchesWon: newWon,
      highestScore: newHigh,
    );

    _statsRepo.saveCareerStats(_careerStats);
    saveCompletedMatch();
  }

  int generateComputerTossNumber() {
    return _aiStrategy.generateTossNumber(_random);
  }

  int generateComputerPlayNumber() {
    return _aiStrategy.generatePlayNumber(
      AiContext(
        recentHumanNumbers: _recentHumanNumbers,
        isBatting: isComputerBatting,
        currentScore: _computerScore,
        targetScore: _target,
        random: _random,
      ),
    );
  }

  PlayerType _opponentOf(PlayerType player) {
    return player == PlayerType.human ? PlayerType.computer : PlayerType.human;
  }

  void resetGame() {
    _currentMatchSaved = false;
    _currentPhase = GamePhase.tossChoice;
    _tossManager.reset();

    _firstInningsBatsman = null;
    _secondInningsBatsman = null;
    _currentBatsman = null;
    _currentBowler = null;

    _humanScore = 0;
    _computerScore = 0;
    _humanWicketsFallen = 0;
    _computerWicketsFallen = 0;
    _humanBallsFaced = 0;
    _computerBallsFaced = 0;
    _humanFours = 0;
    _humanSixes = 0;
    _humanTens = 0;
    _computerFours = 0;
    _computerSixes = 0;
    _computerTens = 0;

    _firstInningsScore = 0;
    _target = 0;

    _humanSelectedNumber = null;
    _computerSelectedNumber = null;
    _turnNumber = 0;
    _isOut = false;
    _lastOutPlayer = null;

    _matchResult = MatchResult.none;
    _turnLogs.clear();
    _recentHumanNumbers.clear();

    notifyListeners();
  }

  // ============================================================
  // PERSISTENCE (Delegated to Repositories - DIP & SRP)
  // ============================================================

  Future<void> loadMatchHistory() async {
    // Load Settings
    final settings = await _settingsRepo.getSettings();
    _difficulty = settings.difficulty;
    _aiStrategy = AiStrategy.forDifficulty(_difficulty);
    _matchMode = settings.matchMode;
    _ruleEngine = MatchRuleEngine.forMode(_matchMode);

    // Load Career Stats
    _careerStats = await _statsRepo.getCareerStats();

    // Load History
    final history = await _historyRepo.getMatchHistory();
    _matchHistory.clear();
    _matchHistory.addAll(history);

    notifyListeners();
  }

  Future<void> resetCareerStats() async {
    _careerStats = CareerStats.empty;
    await _statsRepo.resetCareerStats();
    notifyListeners();
  }

  Future<void> saveCompletedMatch() async {
    if (_currentMatchSaved) return;
    if (currentPhase != GamePhase.matchFinished) return;
    if (matchResult == MatchResult.none) return;
    if (firstInningsBatsman == null) return;

    _currentMatchSaved = true;

    final entry = MatchHistoryEntry(
      humanScore: humanScore,
      computerScore: computerScore,
      result: matchResult,
      firstBatsman: firstInningsBatsman!,
      playedAt: DateTime.now(),
      humanBalls: _humanBallsFaced,
      computerBalls: _computerBallsFaced,
    );

    _matchHistory.insert(0, entry);
    if (_matchHistory.length > 20) {
      _matchHistory.removeRange(20, _matchHistory.length);
    }

    notifyListeners();
    await _historyRepo.saveMatch(entry);
  }

  Future<void> clearMatchHistory() async {
    _matchHistory.clear();
    await _historyRepo.clearHistory();
    notifyListeners();
  }
}
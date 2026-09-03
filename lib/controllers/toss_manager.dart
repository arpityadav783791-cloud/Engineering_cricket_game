import '../models/match_enums.dart';

/// Single-responsibility manager for coin toss and bat/bowl decisions (SRP).
class TossManager {
  OddEvenChoice? _humanChoice;
  OddEvenChoice? _parity;
  int? _humanNumber;
  int? _computerNumber;
  int? _total;
  PlayerType? _winner;
  PlayDecision? _decision;

  OddEvenChoice? get humanChoice => _humanChoice;
  OddEvenChoice? get parity => _parity;
  int? get humanNumber => _humanNumber;
  int? get computerNumber => _computerNumber;
  int? get total => _total;
  PlayerType? get winner => _winner;
  PlayDecision? get decision => _decision;

  bool get humanWon => _winner == PlayerType.human;
  bool get computerWon => _winner == PlayerType.computer;

  void chooseOddEven(OddEvenChoice choice) {
    _humanChoice = choice;
  }

  void executeToss({required int humanNum, required int computerNum}) {
    _humanNumber = humanNum;
    _computerNumber = computerNum;
    _total = humanNum + computerNum;

    _parity = (_total! % 2 == 0) ? OddEvenChoice.even : OddEvenChoice.odd;
    _winner = (_parity == _humanChoice) ? PlayerType.human : PlayerType.computer;
  }

  void setDecision(PlayDecision dec) {
    _decision = dec;
  }

  void reset() {
    _humanChoice = null;
    _parity = null;
    _humanNumber = null;
    _computerNumber = null;
    _total = null;
    _winner = null;
    _decision = null;
  }
}

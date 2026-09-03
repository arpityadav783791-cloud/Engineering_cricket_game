import 'match_enums.dart';

class TurnLogEntry {
  const TurnLogEntry({
    required this.ballNumber,
    required this.runs,
    required this.isOut,
    required this.batsman,
    required this.humanNumber,
    required this.computerNumber,
    required this.innings,
  });

  final int ballNumber;
  final int runs;
  final bool isOut;
  final PlayerType batsman;
  final int humanNumber;
  final int computerNumber;
  final int innings;
}

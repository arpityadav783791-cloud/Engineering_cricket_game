import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import 'home_screen.dart';
import 'toss_screen.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({
    super.key,
    required this.gameController,
  });

  final GameController gameController;

  @override
  Widget build(BuildContext context) {
    final result = gameController.matchResult;

    final bool humanWon = result == MatchResult.humanWin;
    final bool computerWon = result == MatchResult.computerWin;
    final bool isTie = result == MatchResult.tie;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF07142D),
              Color(0xFF101B46),
              Color(0xFF071E27),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 60,
                left: -35,
                child: _buildStadiumLight(),
              ),
              Positioned(
                top: 60,
                right: -35,
                child: _buildStadiumLight(),
              ),
              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 20,
                ),
                child: Column(
                  children: [
                    const Text(
                      'MATCH RESULT',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 30),

                    _buildResultIcon(
                      humanWon: humanWon,
                      computerWon: computerWon,
                      isTie: isTie,
                    ),

                    const SizedBox(height: 18),

                    Text(
                      _getResultTitle(result),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _getResultColor(result),
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.3,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _getResultSubtitle(result),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 30),

                    _buildFinalScoreCard(),

                    const SizedBox(height: 20),

                    _buildMatchSummary(),

                    const SizedBox(height: 28),

                    _buildPlayAgainButton(context),

                    const SizedBox(height: 14),

                    _buildHomeButton(context),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // RESULT ICON
  // ============================================================

  Widget _buildResultIcon({
    required bool humanWon,
    required bool computerWon,
    required bool isTie,
  }) {
    IconData icon;
    Color color;

    if (humanWon) {
      icon = Icons.emoji_events_rounded;
      color = const Color(0xFFFFD600);
    } else if (computerWon) {
      icon = Icons.sentiment_dissatisfied_rounded;
      color = const Color(0xFFFF5252);
    } else if (isTie) {
      icon = Icons.handshake_rounded;
      color = const Color(0xFF82B1FF);
    } else {
      icon = Icons.sports_cricket;
      color = Colors.white;
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.12),
        border: Border.all(
          color: color.withValues(alpha: 0.40),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 35,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color,
        size: 65,
      ),
    );
  }

  // ============================================================
  // RESULT TEXT
  // ============================================================

  String _getResultTitle(MatchResult result) {
    switch (result) {
      case MatchResult.humanWin:
        return 'YOU WIN!';

      case MatchResult.computerWin:
        return 'COMPUTER WINS!';

      case MatchResult.tie:
        return 'MATCH TIED!';

      case MatchResult.none:
        return 'MATCH FINISHED';
    }
  }

  String _getResultSubtitle(MatchResult result) {
    switch (result) {
      case MatchResult.humanWin:
        return 'Brilliant performance! You won the match.';

      case MatchResult.computerWin:
        return 'The computer won this match. Try again!';

      case MatchResult.tie:
        return 'Both sides finished with the same score.';

      case MatchResult.none:
        return 'The match has ended.';
    }
  }

  Color _getResultColor(MatchResult result) {
    switch (result) {
      case MatchResult.humanWin:
        return const Color(0xFF76FF03);

      case MatchResult.computerWin:
        return const Color(0xFFFF5252);

      case MatchResult.tie:
        return const Color(0xFF82B1FF);

      case MatchResult.none:
        return Colors.white;
    }
  }

  // ============================================================
  // FINAL SCORE
  // ============================================================

  Widget _buildFinalScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'FINAL SCORE',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildScoreBox(
                  title: 'YOU',
                  score: gameController.humanScore,
                  icon: Icons.person_rounded,
                  color: const Color(0xFF00C853),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Text(
                  'VS',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.55),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),

              Expanded(
                child: _buildScoreBox(
                  title: 'COMPUTER',
                  score: gameController.computerScore,
                  icon: Icons.computer_rounded,
                  color: const Color(0xFFFF6D00),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreBox({
    required String title,
    required int score,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: color.withValues(alpha: 0.30),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 27,
          ),

          const SizedBox(height: 7),

          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            score.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MATCH SUMMARY
  // ============================================================

  Widget _buildMatchSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF2962FF)
            .withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF2962FF)
              .withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          const Text(
            'MATCH SUMMARY',
            style: TextStyle(
              color: Color(0xFF82B1FF),
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 16),

          _buildSummaryRow(
            label: 'First Innings Score',
            value: gameController.firstInningsScore.toString(),
          ),

          const SizedBox(height: 11),

          _buildSummaryRow(
            label: 'Target',
            value: gameController.target.toString(),
          ),

          const SizedBox(height: 11),

          _buildSummaryRow(
            label: 'Human Score',
            value: gameController.humanScore.toString(),
          ),

          const SizedBox(height: 11),

          _buildSummaryRow(
            label: 'Computer Score',
            value: gameController.computerScore.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.60),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PLAY AGAIN
  // ============================================================

  Widget _buildPlayAgainButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: () {
          gameController.resetGame();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => TossScreen(
                gameController: gameController,
              ),
            ),
            (route) => false,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00C853),
          foregroundColor: Colors.white,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.replay_rounded,
              size: 26,
            ),
            SizedBox(width: 10),
            Text(
              'PLAY AGAIN',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HOME
  // ============================================================

  Widget _buildHomeButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () {
          gameController.resetGame();

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(
                gameController: gameController,
              ),
            ),
            (route) => false,
          );
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.25),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(17),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.home_rounded,
              size: 24,
            ),
            SizedBox(width: 9),
            Text(
              'BACK TO HOME',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // STADIUM LIGHT
  // ============================================================

  Widget _buildStadiumLight() {
    return Container(
      width: 110,
      height: 45,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.20),
            blurRadius: 30,
            spreadRadius: 8,
          ),
        ],
      ),
      child: const Icon(
        Icons.grid_view_rounded,
        color: Colors.white60,
        size: 34,
      ),
    );
  }
}
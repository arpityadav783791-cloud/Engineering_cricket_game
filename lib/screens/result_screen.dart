import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/game_controller.dart';
import '../services/audio_service.dart';
import '../widgets/celebration_overlay.dart';
import '../widgets/stadium_background.dart';
import 'toss_screen.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({
    super.key,
    required this.gameController,
  });

  final GameController gameController;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  GameController get controller => widget.gameController;
  final CelebrationController _celebrationController = CelebrationController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.matchResult == MatchResult.humanWin) {
        AudioService.instance.playVictory();
        _celebrationController.triggerVictory();
      } else {
        AudioService.instance.wicketVibration();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final result = controller.matchResult;
    final humanWon = result == MatchResult.humanWin;
    final computerWon = result == MatchResult.computerWin;
    final isTie = result == MatchResult.tie;

    return Scaffold(
      body: StadiumBackground(
        showFloodlights: true,
        child: CelebrationOverlay(
          controller: _celebrationController,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Column(
                children: [
                  Text(
                    'MATCH RESULT',
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _buildResultTrophy(humanWon: humanWon, computerWon: computerWon, isTie: isTie),

                  const SizedBox(height: 12),

                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _getResultTitle(result),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.rajdhani(
                        color: _getResultColor(result),
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(color: _getResultColor(result).withValues(alpha: 0.5), blurRadius: 20),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    _getResultSubtitle(result),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 18),

                  _buildFinalScoreCard(),

                  const SizedBox(height: 14),

                  _buildPerformanceBreakdown(),

                  const SizedBox(height: 22),

                  _buildActionButtons(context),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultTrophy({
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
      icon = Icons.sports_cricket_rounded;
      color = Colors.white;
    }

    return Container(
      width: 105,
      height: 105,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 2.5),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 30,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Icon(icon, color: color, size: 58),
      ),
    );
  }

  String _getResultTitle(MatchResult result) {
    switch (result) {
      case MatchResult.humanWin:
        return 'GLORIOUS VICTORY!';
      case MatchResult.computerWin:
        return 'COMPUTER WINS!';
      case MatchResult.tie:
        return 'THRILLING TIE!';
      case MatchResult.none:
        return 'MATCH FINISHED';
    }
  }

  String _getResultSubtitle(MatchResult result) {
    switch (result) {
      case MatchResult.humanWin:
        return 'Spectacular finger cricket performance! You took the trophy.';
      case MatchResult.computerWin:
        return 'The AI held its nerve. Ready for a rematch?';
      case MatchResult.tie:
        return 'Incredible match! Both teams finished on exact equal runs.';
      case MatchResult.none:
        return 'Match completed.';
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

  Widget _buildFinalScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1C3E).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'FINAL SCOREBOARD',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFFFFD600),
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text('YOU', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${controller.humanScore}',
                        style: GoogleFonts.rajdhani(
                          color: const Color(0xFF76FF03),
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '${controller.humanBallsFaced} balls',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
                child: Text('VS', style: GoogleFonts.rajdhani(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text('COMPUTER', style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${controller.computerScore}',
                        style: GoogleFonts.rajdhani(
                          color: const Color(0xFFFF9100),
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      '${controller.computerBallsFaced} balls',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceBreakdown() {
    final humanSR = controller.humanStrikeRate.toStringAsFixed(1);
    final totalFours = controller.humanFours;
    final totalSixes = controller.humanSixes;
    final totalTens = controller.humanTens;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1C3E).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatItem('SR', humanSR, const Color(0xFF00E5FF))),
          Container(width: 1, height: 26, color: Colors.white10),
          Expanded(child: _buildStatItem('4s', '$totalFours', const Color(0xFF00E676))),
          Container(width: 1, height: 26, color: Colors.white10),
          Expanded(child: _buildStatItem('6s', '$totalSixes', const Color(0xFFFFD600))),
          Container(width: 1, height: 26, color: Colors.white10),
          Expanded(child: _buildStatItem('10s', '$totalTens', const Color(0xFFFF3D00))),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.rajdhani(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.45),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF00E676), Color(0xFF00C853)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E676).withValues(alpha: 0.4),
                blurRadius: 18,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              AudioService.instance.playTap();
              controller.resetGame();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => TossScreen(
                    gameController: controller,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.replay_rounded, color: Colors.white, size: 22),
                const SizedBox(width: 8),
                Text(
                  'PLAY AGAIN',
                  style: GoogleFonts.rajdhani(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 10),

        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () {
              AudioService.instance.playTap();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white24, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text(
              'RETURN TO HOME',
              style: GoogleFonts.rajdhani(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
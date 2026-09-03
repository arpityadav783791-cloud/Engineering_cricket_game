import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/game_controller.dart';
import '../services/audio_service.dart';
import '../widgets/celebration_overlay.dart';
import '../widgets/exit_confirmation_dialog.dart';
import '../widgets/hand_gesture_badge.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/stadium_background.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.gameController,
  });

  final GameController gameController;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  GameController get controller => widget.gameController;

  final CelebrationController _celebrationController = CelebrationController();
  late AnimationController _showdownAnimController;
  late Animation<double> _showdownScaleAnim;

  bool _resultScreenOpened = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerChanged);

    _showdownAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _showdownScaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _showdownAnimController,
        curve: Curves.easeOutBack,
      ),
    );
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    _showdownAnimController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});

    if (controller.currentPhase == GamePhase.matchFinished &&
        !_resultScreenOpened) {
      _resultScreenOpened = true;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ResultScreen(
              gameController: controller,
            ),
          ),
        );
      });
    }
  }

  void _playTurn(int playNum) {
    if (controller.currentPhase != GamePhase.firstInnings &&
        controller.currentPhase != GamePhase.secondInnings) {
      return;
    }

    controller.playTurn(playNum);
    _showdownAnimController.forward(from: 0.0);

    if (controller.isOut) {
      AudioService.instance.playWicket();
      _celebrationController.triggerWicket();
    } else {
      final runs = controller.isHumanBatting
          ? (controller.humanSelectedNumber ?? 0)
          : (controller.computerSelectedNumber ?? 0);

      final isBoundary = runs == 4 || runs == 6 || runs == 10;
      AudioService.instance.playBatHit(isBoundary: isBoundary);

      if (isBoundary) {
        _celebrationController.triggerBoundary(runs);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _confirmExit(context);
      },
      child: Scaffold(
      body: StadiumBackground(
        showFloodlights: true,
        child: CelebrationOverlay(
          controller: _celebrationController,
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),

                _buildBallTimelineStrip(),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Column(
                      children: [
                        _buildRoleCard(),

                        const SizedBox(height: 12),

                        _buildScoreboard(),

                        if (controller.currentPhase == GamePhase.secondInnings) ...[
                          const SizedBox(height: 10),
                          _buildTargetTracker(),
                        ],

                        const SizedBox(height: 14),

                        if (controller.currentPhase == GamePhase.inningsBreak)
                          _buildInningsBreakSection()
                        else ...[
                          _buildShowdownDuelCard(),

                          const SizedBox(height: 14),

                          _buildNumberSelectionPad(),
                        ],

                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _confirmExit(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
          Expanded(
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    _getInningsTitle(),
                    style: GoogleFonts.rajdhani(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                Text(
                  controller.matchMode == MatchMode.superOver
                      ? '⚡ SUPER OVER'
                      : (controller.matchMode == MatchMode.threeWickets ? '🏏 3 WICKETS' : '⚡ CLASSIC'),
                  style: const TextStyle(
                    color: Color(0xFF00E5FF),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => SettingsDialog.show(context, controller),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.tune_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  String _getInningsTitle() {
    switch (controller.currentPhase) {
      case GamePhase.firstInnings:
        return 'FIRST INNINGS';
      case GamePhase.inningsBreak:
        return 'INNINGS BREAK';
      case GamePhase.secondInnings:
        return 'SECOND INNINGS';
      default:
        return 'MATCH';
    }
  }

  Widget _buildBallTimelineStrip() {
    final logs = controller.currentInningsLogs;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          const Icon(Icons.timeline_rounded, color: Color(0xFFFFD600), size: 15),
          const SizedBox(width: 6),
          Text(
            'OVER:',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFFFFD600),
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: logs.isEmpty
                ? Text(
                    'Make your move',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  )
                : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    reverse: true,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: logs.map((log) {
                        Color badgeBg;
                        Color badgeText = Colors.white;
                        String label;

                        if (log.isOut) {
                          badgeBg = const Color(0xFFFF1744);
                          label = 'W';
                        } else if (log.runs == 0) {
                          badgeBg = Colors.white24;
                          label = '•';
                        } else if (log.runs == 4) {
                          badgeBg = const Color(0xFF00E5FF);
                          badgeText = Colors.black;
                          label = '4';
                        } else if (log.runs == 6) {
                          badgeBg = const Color(0xFFFFD600);
                          badgeText = Colors.black;
                          label = '6';
                        } else if (log.runs == 10) {
                          badgeBg = const Color(0xFFFF3D00);
                          label = '10';
                        } else {
                          badgeBg = const Color(0xFF0D47A1);
                          label = '${log.runs}';
                        }

                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2.5),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: badgeBg,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                color: badgeText,
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleCard() {
    final humanBatting = controller.isHumanBatting;
    final color = humanBatting ? const Color(0xFF00E676) : const Color(0xFF00B0FF);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            humanBatting ? Icons.sports_cricket_rounded : Icons.sports_baseball_rounded,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              humanBatting ? 'YOU ARE BATTING' : 'YOU ARE BOWLING',
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.rajdhani(
                color: color,
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Wkts: ${controller.currentBatsmanWicketsFallen}/${controller.maxWickets}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreboard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1C3E).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildScorePlayer(
              name: 'YOU',
              score: controller.humanScore,
              isCurrentBatsman: controller.isHumanBatting,
              color: const Color(0xFF76FF03),
              balls: controller.humanBallsFaced,
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              shape: BoxShape.circle,
            ),
            child: Text(
              'VS',
              style: GoogleFonts.rajdhani(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Expanded(
            child: _buildScorePlayer(
              name: 'COMPUTER',
              score: controller.computerScore,
              isCurrentBatsman: controller.isComputerBatting,
              color: const Color(0xFFFF9100),
              balls: controller.computerBallsFaced,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScorePlayer({
    required String name,
    required int score,
    required bool isCurrentBatsman,
    required Color color,
    required int balls,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isCurrentBatsman)
              const Padding(
                padding: EdgeInsets.only(right: 4),
                child: Icon(Icons.sports_cricket_rounded, color: Color(0xFFFFD600), size: 12),
              ),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                name,
                style: TextStyle(
                  color: isCurrentBatsman ? Colors.white : Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '$score',
            style: GoogleFonts.rajdhani(
              color: color,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              shadows: [
                Shadow(color: color.withValues(alpha: 0.5), blurRadius: 14),
              ],
            ),
          ),
        ),
        Text(
          '($balls balls)',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.45),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildTargetTracker() {
    final needed = controller.runsNeeded;
    final target = controller.target;
    final current = controller.currentBatsmanScore;
    final progress = (current / (target > 0 ? target : 1)).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'TARGET: $target',
                    style: GoogleFonts.rajdhani(
                      color: const Color(0xFFFFD600),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'NEED $needed RUNS TO WIN',
                    style: GoogleFonts.rajdhani(
                      color: const Color(0xFF76FF03),
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white12,
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00E676)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShowdownDuelCard() {
    final humanChoice = controller.humanSelectedNumber;
    final cpuChoice = controller.computerSelectedNumber;
    final isOut = controller.isOut;

    if (humanChoice == null || cpuChoice == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Icon(Icons.touch_app_rounded, color: Colors.white.withValues(alpha: 0.3), size: 32),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'CHOOSE A NUMBER BELOW TO PLAY',
                style: GoogleFonts.rajdhani(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return ScaleTransition(
      scale: _showdownScaleAnim,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isOut
              ? const Color(0xFFFF1744).withValues(alpha: 0.15)
              : const Color(0xFF0D1C3E).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isOut ? const Color(0xFFFF1744) : const Color(0xFF00E5FF).withValues(alpha: 0.35),
            width: isOut ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isOut
                  ? const Color(0xFFFF1744).withValues(alpha: 0.3)
                  : const Color(0xFF00E5FF).withValues(alpha: 0.15),
              blurRadius: 18,
            ),
          ],
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                isOut ? '⚡ WICKET! NUMBERS MATCHED ⚡' : 'BALL RESULT',
                style: GoogleFonts.rajdhani(
                  color: isOut ? const Color(0xFFFF1744) : const Color(0xFFFFD600),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildShowdownHand(
                  label: 'YOU',
                  number: humanChoice,
                  isBatsman: controller.isHumanBatting,
                ),
                Text(
                  isOut ? '==' : '≠',
                  style: GoogleFonts.rajdhani(
                    color: isOut ? const Color(0xFFFF1744) : Colors.white38,
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                _buildShowdownHand(
                  label: 'COMPUTER',
                  number: cpuChoice,
                  isBatsman: controller.isComputerBatting,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShowdownHand({
    required String label,
    required int number,
    required bool isBatsman,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isBatsman)
              const Icon(Icons.sports_cricket_rounded, color: Color(0xFFFFD600), size: 12),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        HandGestureBadge(number: number, isSelected: true, size: 60),
      ],
    );
  }

  Widget _buildNumberSelectionPad() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1C3E).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            'SELECT YOUR NEXT MOVE',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final badgeSize = ((constraints.maxWidth - 48) / 4).clamp(46.0, 58.0);
              return Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: GameController.playNumbers.map((playNum) {
                  return GestureDetector(
                    onTap: () => _playTurn(playNum),
                    child: HandGestureBadge(
                      number: playNum,
                      size: badgeSize,
                      showFingers: badgeSize >= 48,
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInningsBreakSection() {
    final firstScore = controller.firstInningsScore;
    final target = controller.target;
    final humanChasing = controller.secondInningsBatsman == PlayerType.human;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1C3E).withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.4), width: 1.8),
      ),
      child: Column(
        children: [
          const Icon(Icons.sports_score_rounded, color: Color(0xFFFFD600), size: 42),
          const SizedBox(height: 8),
          Text(
            'INNINGS BREAK',
            style: GoogleFonts.rajdhani(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '1st Innings Finished: $firstScore Runs',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Text(
                  'TARGET TO WIN',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  '$target RUNS',
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFF76FF03),
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    humanChasing ? 'You need $target runs to win' : 'Computer needs $target runs to win',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                AudioService.instance.playTap();
                controller.startSecondInnings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'START 2ND INNINGS',
                style: GoogleFonts.rajdhani(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final leave = await ExitConfirmationDialog.show(
      context,
      title: 'Are you leaving soon? 🥺',
      subtitle: 'Your match is in progress! If you leave now, this match will be forfeited.',
      stayText: 'STAY & PLAY',
      leaveText: 'LEAVE',
    );
    if (leave && context.mounted) {
      Navigator.pop(context);
    }
  }
}
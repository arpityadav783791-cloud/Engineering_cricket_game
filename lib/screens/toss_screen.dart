import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../controllers/game_controller.dart';
import '../services/audio_service.dart';
import '../widgets/coin_3d_widget.dart';
import '../widgets/exit_confirmation_dialog.dart';
import '../widgets/hand_gesture_badge.dart';
import '../widgets/stadium_background.dart';
import 'game_screen.dart';

class TossScreen extends StatefulWidget {
  const TossScreen({
    super.key,
    required this.gameController,
  });

  final GameController gameController;

  @override
  State<TossScreen> createState() => _TossScreenState();
}

class _TossScreenState extends State<TossScreen> {
  GameController get controller => widget.gameController;

  int? selectedTossNumber;
  bool _isCoinFlipping = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(_refreshScreen);
  }

  @override
  void dispose() {
    controller.removeListener(_refreshScreen);
    super.dispose();
  }

  void _refreshScreen() {
    if (mounted) setState(() {});
  }

  void _openGameScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => GameScreen(
          gameController: controller,
        ),
      ),
    );
  }

  void _onNumberTap(int tossNum) {
    AudioService.instance.playTap();
    setState(() {
      selectedTossNumber = tossNum;
    });
  }

  void _submitTossNumber() {
    if (selectedTossNumber == null) return;

    setState(() {
      _isCoinFlipping = true;
    });

    AudioService.instance.playCoinFlip();

    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      controller.playToss(selectedTossNumber!);
      setState(() {
        _isCoinFlipping = false;
      });

      if (controller.tossWinner == PlayerType.human) {
        AudioService.instance.playVictory();
      } else {
        AudioService.instance.wicketVibration();
      }
    });
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
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Column(
                      children: [
                        Coin3DWidget(
                          isFlipping: _isCoinFlipping,
                          targetOdd: controller.tossResultParity == OddEvenChoice.odd,
                          size: 115,
                        ),

                        const SizedBox(height: 14),

                        Text(
                          'THE TOSS',
                          style: GoogleFonts.rajdhani(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),

                        const SizedBox(height: 3),

                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            _getPhaseSubtitle(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        _buildCurrentPhaseContent(),

                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmExit(BuildContext context) async {
    final leave = await ExitConfirmationDialog.show(
      context,
      title: 'Leaving so soon?',
      subtitle: 'The coin is ready to flip! Are you sure you want to abandon the match?',
      stayText: 'STAY & PLAY',
      leaveText: 'LEAVE',
    );
    if (leave && context.mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
            child: Text(
              'MATCH INITIATION',
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(width: 44),
        ],
      ),
    );
  }

  String _getPhaseSubtitle() {
    switch (controller.currentPhase) {
      case GamePhase.tossChoice:
        return 'Call ODD or EVEN for the flip';
      case GamePhase.tossNumberSelection:
        return 'Throw a number from 1 to 5';
      case GamePhase.tossResult:
        return 'Toss result revealed!';
      case GamePhase.batBowlDecision:
        return 'Choose your tactical role';
      default:
        return 'Hand Cricket Tournament';
    }
  }

  Widget _buildCurrentPhaseContent() {
    if (_isCoinFlipping) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            const CircularProgressIndicator(
              color: Color(0xFFFFD600),
              strokeWidth: 3,
            ),
            const SizedBox(height: 14),
            Text(
              'COIN IN THE AIR...',
              style: GoogleFonts.rajdhani(
                color: const Color(0xFFFFD600),
                fontSize: 18,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      );
    }

    switch (controller.currentPhase) {
      case GamePhase.tossChoice:
        return _buildOddEvenSection();
      case GamePhase.tossNumberSelection:
        return _buildNumberSelectionSection();
      case GamePhase.tossResult:
        return _buildTossResultSection();
      case GamePhase.batBowlDecision:
        return _buildBatBowlDecisionSection();
      case GamePhase.firstInnings:
        return _buildStartingMatchSection();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOddEvenSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1C3E).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            'CHOOSE YOUR CALL',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFFFFD600),
              fontSize: 15,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildChoiceCard(
                  title: 'ODD',
                  subtitle: '1, 3, 5, 7, 9',
                  icon: Icons.looks_one_rounded,
                  color: const Color(0xFFFF6D00),
                  onTap: () {
                    AudioService.instance.playTap();
                    controller.chooseOddEven(OddEvenChoice.odd);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildChoiceCard(
                  title: 'EVEN',
                  subtitle: '2, 4, 6, 8, 10',
                  icon: Icons.looks_two_rounded,
                  color: const Color(0xFF2979FF),
                  onTap: () {
                    AudioService.instance.playTap();
                    controller.chooseOddEven(OddEvenChoice.even);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.8),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberSelectionSection() {
    final isOdd = controller.humanOddEvenChoice == OddEvenChoice.odd;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: (isOdd ? const Color(0xFFFF6D00) : const Color(0xFF2979FF)).withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isOdd ? const Color(0xFFFF6D00) : const Color(0xFF2979FF)),
          ),
          child: Text(
            'YOU CALLED: ${isOdd ? 'ODD' : 'EVEN'}',
            style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 12),
          ),
        ),

        const SizedBox(height: 14),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1C3E).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Text(
                'PICK YOUR TOSS NUMBER',
                style: GoogleFonts.rajdhani(
                  color: const Color(0xFFFFD600),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 14),
              LayoutBuilder(
                builder: (context, constraints) {
                  final badgeSize = ((constraints.maxWidth - 32) / 5).clamp(42.0, 56.0);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: GameController.tossNumbers.map((tossNum) {
                      final isSelected = selectedTossNumber == tossNum;
                      return GestureDetector(
                        onTap: () => _onNumberTap(tossNum),
                        child: HandGestureBadge(
                          number: tossNum,
                          isSelected: isSelected,
                          size: badgeSize,
                          showFingers: badgeSize >= 48,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: selectedTossNumber != null ? _submitTossNumber : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: Colors.black,
                    disabledBackgroundColor: Colors.white12,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'FLIP COIN',
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
        ),
      ],
    );
  }

  Widget _buildTossResultSection() {
    final humanWon = controller.humanWonToss;
    final total = controller.tossTotal ?? 0;
    final parityStr = (controller.tossResultParity == OddEvenChoice.odd) ? 'ODD' : 'EVEN';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: (humanWon ? const Color(0xFF76FF03) : const Color(0xFFFF5252)).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: (humanWon ? const Color(0xFF76FF03) : const Color(0xFFFF5252)).withValues(alpha: 0.35),
          width: 1.8,
        ),
      ),
      child: Column(
        children: [
          Icon(
            humanWon ? Icons.emoji_events_rounded : Icons.computer_rounded,
            color: humanWon ? const Color(0xFF76FF03) : const Color(0xFFFF5252),
            size: 42,
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              humanWon ? 'YOU WON THE TOSS!' : 'COMPUTER WON THE TOSS',
              textAlign: TextAlign.center,
              style: GoogleFonts.rajdhani(
                color: humanWon ? const Color(0xFF76FF03) : const Color(0xFFFF5252),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(14),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'YOU (${controller.humanTossNumber}) + CPU (${controller.computerTossNumber}) = $total ($parityStr)',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                AudioService.instance.playTap();
                if (humanWon) {
                  controller.continueAfterToss();
                } else {
                  controller.continueAfterToss();
                  if (controller.currentPhase == GamePhase.firstInnings) {
                    _openGameScreen();
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E676),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                humanWon ? 'MAKE YOUR DECISION' : 'CONTINUE TO MATCH',
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

  Widget _buildBatBowlDecisionSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1C3E).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF00E5FF).withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Text(
            'CHOOSE TO BAT OR BOWL',
            style: GoogleFonts.rajdhani(
              color: const Color(0xFFFFD600),
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildRoleDecisionCard(
                  title: 'BAT FIRST',
                  desc: 'Set a big target',
                  icon: Icons.sports_cricket_rounded,
                  color: const Color(0xFF00E676),
                  onTap: () {
                    AudioService.instance.playBatHit();
                    controller.chooseBatOrBowl(PlayDecision.bat);
                    _openGameScreen();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildRoleDecisionCard(
                  title: 'BOWL FIRST',
                  desc: 'Chase the total',
                  icon: Icons.sports_baseball_rounded,
                  color: const Color(0xFF00B0FF),
                  onTap: () {
                    AudioService.instance.playTap();
                    controller.chooseBatOrBowl(PlayDecision.bowl);
                    _openGameScreen();
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleDecisionCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.4), width: 1.8),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 8),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                desc,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartingMatchSection() {
    return Center(
      child: ElevatedButton(
        onPressed: _openGameScreen,
        child: const Text('START GAME'),
      ),
    );
  }
}
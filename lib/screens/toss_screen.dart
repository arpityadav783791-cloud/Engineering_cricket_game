import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
import 'game_screen.dart';
import 'home_screen.dart';

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
    if (mounted) {
      setState(() {});
    }
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

  void _handleComputerTossWinner() {
    controller.continueAfterToss();

    if (controller.currentPhase == GamePhase.firstInnings) {
      _openGameScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    _buildTopBar(),

                    const SizedBox(height: 28),

                    const Icon(
                      Icons.sports_cricket,
                      size: 58,
                      color: Color(0xFFFFA726),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'WIN THE TOSS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      _getSubtitle(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 26),

                    _buildCurrentPhaseContent(),

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
  // CURRENT PHASE UI
  // ============================================================

  Widget _buildCurrentPhaseContent() {
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

  // ============================================================
  // ODD / EVEN
  // ============================================================

  Widget _buildOddEvenSection() {
    return _buildSectionCard(
      title: 'CHOOSE YOUR SIDE',
      child: Column(
        children: [
          Text(
            'Choose whether the total will be odd or even',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _buildChoiceButton(
                  text: 'ODD',
                  icon: Icons.looks_one_rounded,
                  color: const Color(0xFFFF6D00),
                  onPressed: () {
                    controller.chooseOddEven(
                      OddEvenChoice.odd,
                    );
                  },
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _buildChoiceButton(
                  text: 'EVEN',
                  icon: Icons.looks_two_rounded,
                  color: const Color(0xFF2962FF),
                  onPressed: () {
                    controller.chooseOddEven(
                      OddEvenChoice.even,
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NUMBER SELECTION
  // ============================================================

  Widget _buildNumberSelectionSection() {
    return Column(
      children: [
        _buildSelectedSideCard(),

        const SizedBox(height: 18),

        _buildSectionCard(
          title: 'CHOOSE YOUR NUMBER',
          child: Column(
            children: [
              Text(
                'Pick one number from 1 to 5',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 18),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNumberButton(1),
                  _buildNumberButton(2),
                  _buildNumberButton(3),
                  _buildNumberButton(4),
                  _buildNumberButton(5),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: selectedTossNumber == null
                ? null
                : () {
                    controller.playToss(
                      selectedTossNumber!,
                    );
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.white,
              disabledBackgroundColor:
                  Colors.white.withValues(alpha: 0.10),
              disabledForegroundColor:
                  Colors.white.withValues(alpha: 0.35),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.casino_rounded,
                  size: 25,
                ),
                SizedBox(width: 10),
                Text(
                  'PLAY TOSS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedSideCard() {
    final choice = controller.humanOddEvenChoice;

    final isOdd = choice == OddEvenChoice.odd;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: isOdd
            ? const Color(0xFFFF6D00).withValues(alpha: 0.12)
            : const Color(0xFF2962FF).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOdd
              ? const Color(0xFFFF6D00).withValues(alpha: 0.30)
              : const Color(0xFF2962FF).withValues(alpha: 0.30),
        ),
      ),
      child: Text(
        'YOUR CHOICE: ${isOdd ? 'ODD' : 'EVEN'}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
    );
  }

  // ============================================================
  // TOSS RESULT
  // ============================================================

  Widget _buildTossResultSection() {
    final humanWon =
        controller.tossWinner == PlayerType.human;

    return Column(
      children: [
        _buildSectionCard(
          title: 'TOSS RESULT',
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildRevealBox(
                      label: 'YOU',
                      number:
                          controller.humanTossNumber.toString(),
                      color: const Color(0xFF00C853),
                      icon: Icons.person_rounded,
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                    ),
                    child: Text(
                      '+',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  Expanded(
                    child: _buildRevealBox(
                      label: 'CPU',
                      number:
                          controller.computerTossNumber.toString(),
                      color: const Color(0xFFFF6D00),
                      icon: Icons.computer_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Text(
                      'TOTAL: ${controller.tossTotal}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      controller.tossResultParity ==
                              OddEvenChoice.odd
                          ? 'ODD'
                          : 'EVEN',
                      style: const TextStyle(
                        color: Color(0xFFFFD600),
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: humanWon
                ? const Color(0xFF00C853)
                    .withValues(alpha: 0.13)
                : const Color(0xFFFF6D00)
                    .withValues(alpha: 0.13),
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: humanWon
                  ? const Color(0xFF00C853)
                      .withValues(alpha: 0.30)
                  : const Color(0xFFFF6D00)
                      .withValues(alpha: 0.30),
            ),
          ),
          child: Column(
            children: [
              Icon(
                humanWon
                    ? Icons.emoji_events_rounded
                    : Icons.computer_rounded,
                color: humanWon
                    ? const Color(0xFF76FF03)
                    : const Color(0xFFFFA726),
                size: 42,
              ),

              const SizedBox(height: 10),

              Text(
                humanWon
                    ? 'YOU WON THE TOSS!'
                    : 'COMPUTER WON THE TOSS!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: humanWon
                      ? const Color(0xFF76FF03)
                      : const Color(0xFFFFA726),
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: () {
              if (humanWon) {
                controller.continueAfterToss();
              } else {
                _handleComputerTossWinner();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2962FF),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              humanWon
                  ? 'CHOOSE BAT OR BOWL'
                  : 'CONTINUE',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // BAT / BOWL DECISION
  // ============================================================

  Widget _buildBatBowlDecisionSection() {
    return _buildSectionCard(
      title: 'WHAT DO YOU CHOOSE?',
      child: Column(
        children: [
          Text(
            'You won the toss. Choose your role.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.60),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildChoiceButton(
                  text: 'BAT',
                  icon: Icons.sports_cricket,
                  color: const Color(0xFF00C853),
                  onPressed: () {
                    controller.chooseBatOrBowl(
                      PlayDecision.bat,
                    );

                    _openGameScreen();
                  },
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _buildChoiceButton(
                  text: 'BOWL',
                  icon: Icons.sports_baseball_rounded,
                  color: const Color(0xFFFF6D00),
                  onPressed: () {
                    controller.chooseBatOrBowl(
                      PlayDecision.bowl,
                    );

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

  // ============================================================
  // STARTING MATCH
  // ============================================================

  Widget _buildStartingMatchSection() {
    return _buildSectionCard(
      title: 'MATCH READY',
      child: Column(
        children: [
          const Icon(
            Icons.sports_cricket,
            color: Color(0xFF76FF03),
            size: 50,
          ),

          const SizedBox(height: 12),

          Text(
            controller.isHumanBatting
                ? 'YOU WILL BAT FIRST'
                : 'COMPUTER WILL BAT FIRST',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: _openGameScreen,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'START MATCH',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TOP BAR
  // ============================================================

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: IconButton(
            onPressed: () {
              controller.resetGame();
              Navigator.pushAndRemoveUntil(
                context, 
                MaterialPageRoute(
                  builder: (context) => HomeScreen(gameController: controller),
                ),
                (route) => false,
              );
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            ),
          ),
        ),

        const Expanded(
          child: Text(
            'TOSS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
        ),

        const SizedBox(width: 46),
      ],
    );
  }

  // ============================================================
  // SUBTITLE
  // ============================================================

  String _getSubtitle() {
    switch (controller.currentPhase) {
      case GamePhase.tossChoice:
        return 'Choose Odd or Even';

      case GamePhase.tossNumberSelection:
        return 'Now choose your toss number';

      case GamePhase.tossResult:
        return 'The toss result is ready';

      case GamePhase.batBowlDecision:
        return 'Choose what you want to do';

      case GamePhase.firstInnings:
        return 'The match is ready';

      default:
        return 'Get ready to play';
    }
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }

  // ============================================================
  // CHOICE BUTTON
  // ============================================================

  Widget _buildChoiceButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 58,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // NUMBER BUTTON
  // ============================================================

  Widget _buildNumberButton(int number) {
    final isSelected =
        selectedTossNumber == number;

    return SizedBox(
      width: 48,
      height: 48,
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedTossNumber = number;
          });
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: isSelected
              ? const Color(0xFF00C853)
              : const Color(0xFF1E2D5A),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // REVEAL BOX
  // ============================================================

  Widget _buildRevealBox({
    required String label,
    required String number,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 22,
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.60),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
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
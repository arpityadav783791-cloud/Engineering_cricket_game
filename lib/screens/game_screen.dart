import 'package:flutter/material.dart';

import '../controllers/game_controller.dart';
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

class _GameScreenState extends State<GameScreen> {
  GameController get controller => widget.gameController;

  bool _resultScreenOpened = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
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

  void _playTurn(int number) {
    if (controller.currentPhase != GamePhase.firstInnings &&
        controller.currentPhase != GamePhase.secondInnings) {
      return;
    }

    controller.playTurn(number);
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
                top: 55,
                left: -35,
                child: _buildStadiumLight(),
              ),
              Positioned(
                top: 55,
                right: -35,
                child: _buildStadiumLight(),
              ),

              SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    _buildTopBar(),

                    const SizedBox(height: 22),

                    _buildRoleCard(),

                    const SizedBox(height: 20),

                    _buildScoreboard(),

                    if (controller.currentPhase ==
                        GamePhase.secondInnings) ...[
                      const SizedBox(height: 18),
                      _buildTargetCard(),
                    ],

                    const SizedBox(height: 20),

                    if (controller.currentPhase ==
                        GamePhase.inningsBreak)
                      _buildInningsBreakSection()
                    else ...[
                      _buildLastTurnSection(),

                      const SizedBox(height: 20),

                      _buildNumberSelectionSection(),

                      const SizedBox(height: 18),

                      _buildRuleHint(),
                    ],

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
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
            ),
          ),
        ),

        Expanded(
          child: Text(
            _getInningsTitle(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),

        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
            ),
          ),
        ),
      ],
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

      case GamePhase.matchFinished:
        return 'MATCH FINISHED';

      default:
        return 'HAND CRICKET';
    }
  }

  // ============================================================
  // ROLE CARD
  // ============================================================

  Widget _buildRoleCard() {
    final isBreak =
        controller.currentPhase == GamePhase.inningsBreak;

    final humanBatting = controller.isHumanBatting;

    String text;
    IconData icon;
    Color color;

    if (isBreak) {
      text = 'FIRST INNINGS COMPLETE';
      icon = Icons.pause_circle_rounded;
      color = const Color(0xFF2962FF);
    } else if (humanBatting) {
      text = 'YOU ARE BATTING';
      icon = Icons.sports_cricket;
      color = const Color(0xFF00C853);
    } else {
      text = 'YOU ARE BOWLING';
      icon = Icons.sports_baseball_rounded;
      color = const Color(0xFFFF6D00);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 27,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SCOREBOARD
  // ============================================================

  Widget _buildScoreboard() {
    return _buildSectionCard(
      title: 'SCOREBOARD',
      child: Row(
        children: [
          Expanded(
            child: _buildScoreCard(
              title: 'YOU',
              score: controller.humanScore.toString(),
              icon: Icons.person_rounded,
              color: const Color(0xFF00C853),
              isBatting:
                  controller.currentBatsman == PlayerType.human,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: _buildScoreCard(
              title: 'COMPUTER',
              score: controller.computerScore.toString(),
              icon: Icons.computer_rounded,
              color: const Color(0xFFFF6D00),
              isBatting:
                  controller.currentBatsman == PlayerType.computer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard({
    required String title,
    required String score,
    required IconData icon,
    required Color color,
    required bool isBatting,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBatting
              ? color
              : color.withValues(alpha: 0.30),
          width: isBatting ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 25,
          ),

          const SizedBox(height: 7),

          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 7),

          Text(
            score,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 31,
              fontWeight: FontWeight.w900,
            ),
          ),

          if (isBatting &&
              controller.currentPhase !=
                  GamePhase.inningsBreak) ...[
            const SizedBox(height: 5),
            Text(
              'BATTING',
              style: TextStyle(
                color: color,
                fontSize: 9,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // TARGET CARD
  // ============================================================

  Widget _buildTargetCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2962FF)
            .withValues(alpha: 0.13),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFF2962FF)
              .withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.flag_rounded,
            color: Color(0xFF82B1FF),
            size: 32,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'TARGET',
                  style: TextStyle(
                    color: Color(0xFF82B1FF),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.3,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  controller.target.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'RUNS NEEDED',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.50),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                controller.runsNeeded.toString(),
                style: const TextStyle(
                  color: Color(0xFFFFD600),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LAST TURN
  // ============================================================

  Widget _buildLastTurnSection() {
    final hasTurn =
        controller.humanSelectedNumber != null &&
        controller.computerSelectedNumber != null;

    return _buildSectionCard(
      title: 'LAST TURN',
      child: hasTurn
          ? Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _buildRevealBox(
                        label: 'YOU',
                        number: controller.humanSelectedNumber
                            .toString(),
                        color: const Color(0xFF00C853),
                        icon: Icons.person_rounded,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      child: Column(
                        children: [
                          Text(
                            'VS',
                            style: TextStyle(
                              color: Colors.white
                                  .withValues(alpha: 0.65),
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Icon(
                            Icons.flash_on_rounded,
                            color: Color(0xFFFFD600),
                            size: 24,
                          ),
                        ],
                      ),
                    ),

                    Expanded(
                      child: _buildRevealBox(
                        label: 'CPU',
                        number: controller.computerSelectedNumber
                            .toString(),
                        color: const Color(0xFFFF6D00),
                        icon: Icons.computer_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                _buildTurnMessage(),
              ],
            )
          : Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 14,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    color: Colors.white.withValues(alpha: 0.45),
                    size: 38,
                  ),

                  const SizedBox(height: 10),

                  Text(
                    controller.isHumanBatting
                        ? 'Choose a number to bat'
                        : 'Choose a number to bowl',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white
                          .withValues(alpha: 0.60),
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTurnMessage() {
    final isOut = controller.isOut;

    String message;
    Color color;

    if (isOut) {
      message = controller.lastOutPlayer == PlayerType.human
          ? 'YOU ARE OUT!'
          : 'COMPUTER IS OUT!';

      color = const Color(0xFFFF5252);
    } else if (controller.currentBatsman == PlayerType.human) {
      message =
          '+${controller.humanSelectedNumber} runs added';

      color = const Color(0xFF76FF03);
    } else {
      message =
          '+${controller.computerSelectedNumber} runs to Computer';

      color = const Color(0xFFFFA726);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: 11,
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.28),
        ),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  // ============================================================
  // NUMBER SELECTION
  // ============================================================

  Widget _buildNumberSelectionSection() {
    final canPlay =
        controller.currentPhase == GamePhase.firstInnings ||
        controller.currentPhase == GamePhase.secondInnings;

    return _buildSectionCard(
      title: 'CHOOSE YOUR NUMBER',
      child: Column(
        children: [
          Text(
            controller.isHumanBatting
                ? 'Pick your batting number'
                : 'Pick your bowling number',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.55),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 18),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNumberButton(1, canPlay),
              _buildNumberButton(2, canPlay),
              _buildNumberButton(3, canPlay),
              _buildNumberButton(4, canPlay),
              _buildNumberButton(5, canPlay),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLargeNumberButton(6, canPlay),
              const SizedBox(width: 16),
              _buildLargeNumberButton(10, canPlay),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(
    int number,
    bool enabled,
  ) {
    return SizedBox(
      width: 48,
      height: 48,
      child: ElevatedButton(
        onPressed: enabled
            ? () {
                _playTurn(number);
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: const Color(0xFF1E2D5A),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              Colors.white.withValues(alpha: 0.08),
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

  Widget _buildLargeNumberButton(
    int number,
    bool enabled,
  ) {
    return SizedBox(
      width: 82,
      height: 52,
      child: ElevatedButton(
        onPressed: enabled
            ? () {
                _playTurn(number);
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: const Color(0xFF2962FF),
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              Colors.white.withValues(alpha: 0.08),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Text(
          number.toString(),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INNINGS BREAK
  // ============================================================

  Widget _buildInningsBreakSection() {
    final firstBatsman =
        controller.firstInningsBatsman;

    final secondBatsman =
        controller.secondInningsBatsman;

    return Column(
      children: [
        _buildSectionCard(
          title: 'INNINGS COMPLETE',
          child: Column(
            children: [
              const Icon(
                Icons.sports_score_rounded,
                color: Color(0xFFFFD600),
                size: 55,
              ),

              const SizedBox(height: 14),

              Text(
                firstBatsman == PlayerType.human
                    ? 'YOU ARE OUT'
                    : 'COMPUTER IS OUT',
                style: const TextStyle(
                  color: Color(0xFFFF5252),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white
                      .withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Text(
                      'FIRST INNINGS SCORE',
                      style: TextStyle(
                        color: Colors.white
                            .withValues(alpha: 0.55),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      controller.firstInningsScore
                          .toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2962FF)
                      .withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF2962FF)
                        .withValues(alpha: 0.30),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      'TARGET TO WIN',
                      style: TextStyle(
                        color: Color(0xFF82B1FF),
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      controller.target.toString(),
                      style: const TextStyle(
                        color: Color(0xFFFFD600),
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              Text(
                secondBatsman == PlayerType.human
                    ? 'You will bat next'
                    : 'Computer will bat next',
                style: TextStyle(
                  color: Colors.white
                      .withValues(alpha: 0.70),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 22),

        SizedBox(
          width: double.infinity,
          height: 58,
          child: ElevatedButton(
            onPressed: () {
              controller.startSecondInnings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00C853),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  size: 26,
                ),
                SizedBox(width: 9),
                Text(
                  'START SECOND INNINGS',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.7,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // RULE HINT
  // ============================================================

  Widget _buildRuleHint() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD600)
            .withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFFFD600)
              .withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_rounded,
            color: Color(0xFFFFD600),
            size: 22,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              controller.isHumanBatting
                  ? 'If your number matches the computer, you are OUT!'
                  : 'Match the computer number to get it OUT!',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
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
            color: Colors.blueAccent
                .withValues(alpha: 0.20),
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
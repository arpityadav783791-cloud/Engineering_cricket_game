import 'package:flutter/material.dart';

import 'package:engineering_cricket/controllers/game_controller.dart';
import 'toss_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.gameController,});

  final GameController gameController;

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
              // Left stadium light
              Positioned(
                top: 55,
                left: -35,
                child: _buildStadiumLight(),
              ),

              // Right stadium light
              Positioned(
                top: 55,
                right: -35,
                child: _buildStadiumLight(),
              ),

              // Main content
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 35),

                    // App logo
                    const Icon(
                      Icons.sports_cricket,
                      size: 75,
                      color: Color(0xFFFFA726),
                    ),

                    const SizedBox(height: 10),

                    // Game title
                    const Text(
                      'HAND CRICKET',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),

                    const SizedBox(height: 5),

                    // Subtitle
                    const Text(
                      'FINGER CHALLENGE',
                      style: TextStyle(
                        color: Color(0xFF76FF03),
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),

                    const Spacer(),

                    // Play Game button
                    _buildMainButton(
                      icon: Icons.play_arrow_rounded,
                      text: 'PLAY GAME',
                      color: const Color(0xFF00C853),
                      onPressed: () {
                        gameController.resetGame();

                        Navigator.push(
                          context, MaterialPageRoute(
                            builder: (context) => TossScreen(
                              gameController: gameController,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // How to Play button
                    _buildMainButton(
                      icon: Icons.menu_book_rounded,
                      text: 'HOW TO PLAY',
                      color: const Color(0xFF2962FF),
                      onPressed: () {
                        _showHowToPlayDialog(context);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Match History button
                    _buildMainButton(
                      icon: Icons.history_rounded,
                      text: 'MATCH HISTORY',
                      color: const Color(0xFF7B1FA2),
                      onPressed: () {
                        _showMatchHistoryDialog(context);
                      },
                    ),

                    const SizedBox(height: 16),

                    // Settings button
                    _buildMainButton(
                      icon: Icons.settings_rounded,
                      text: 'SETTINGS',
                      color: const Color(0xFF455A64),
                      onPressed: () {},
                    ),

                    const Spacer(),

                    // Bottom text
                    Text(
                      'PLAY • SCORE • WIN',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),

                    const SizedBox(height: 22),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: color.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 26,
            ),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  void _showHowToPlayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF101B46),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 500,
              maxHeight: 600,
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.menu_book_rounded,
                        color: Color(0xFFFFD600),
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'HOW TO PLAY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _buildRuleItem(
                            '1. WIN THE TOSS',
                            'Choose ODD or EVEN, then select a number from 1 to 5. '
                            'The computer also chooses a random number. '
                            'If the total matches your ODD/EVEN choice, you win the toss.',
                          ),

                          _buildRuleItem(
                            '2. CHOOSE BAT OR BOWL',
                            'If you win the toss, choose whether to BAT or BOWL. '
                            'If the computer wins, it makes the decision automatically.',
                          ),

                          _buildRuleItem(
                            '3. CHOOSE YOUR NUMBER',
                            'During gameplay, choose from 1, 2, 3, 4, 5, 6, or 10.',
                          ),

                          _buildRuleItem(
                            '4. SCORING',
                            'If the numbers are different, only the batsman’s selected number '
                            'is added to the score.',
                          ),

                          _buildRuleItem(
                            '5. GETTING OUT',
                            'If your number and the computer number match, the current batsman '
                            'is OUT immediately. The matching number is not added.',
                          ),

                          _buildRuleItem(
                            '6. SECOND INNINGS',
                            'After the first batsman is OUT, the roles switch. '
                            'The chasing player must score more than the first innings score.',
                          ),

                          _buildRuleItem(
                            '7. WINNING',
                            'The chasing player wins immediately after exceeding the target score. '
                            'If the chasing player gets OUT below the first innings score, '
                            'the defending player wins.',
                          ),

                          _buildRuleItem(
                            '8. TIE',
                            'If the chasing player gets OUT when both scores are equal, '
                            'the match ends in a tie.',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF00C853),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'GOT IT',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRuleItem(
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFD600),
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.7,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            description,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 13,
              height: 1.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showMatchHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final history = gameController.matchHistory;
  
            return Dialog(
              backgroundColor: const Color(0xFF101B46),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 520,
                  maxHeight: 650,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.history_rounded,
                            color: Color(0xFFFFD600),
                            size: 30,
                          ),

                          const SizedBox(width: 10),

                          const Expanded(
                            child: Text(
                              'MATCH HISTORY',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 21,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
  
                          if (history.isNotEmpty)
                            IconButton(
                              tooltip: 'Clear History',
                              onPressed: () async {
                                await gameController.clearMatchHistory();
  
                                setDialogState(() {});
                              },
                              icon: const Icon(
                                Icons.delete_outline_rounded,
                                color: Color(0xFFFF5252),
                              ),
                            ),
                        ],
                      ),
  
                      const SizedBox(height: 18),
  
                      Flexible(
                        child: history.isEmpty
                            ? _buildEmptyHistory()
                            : ListView.separated(
                                shrinkWrap: true,
                                itemCount: history.length,
                                separatorBuilder: (_, __) {
                                  return const SizedBox(height: 12);
                                },
                                itemBuilder: (context, index) {
                                  final match = history[index];
  
                                  return _buildHistoryCard(
                                    match,
                                    index,
                                  );
                                },
                              ),
                      ),

                      const SizedBox(height: 18),

                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF00C853),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'CLOSE',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyHistory() {
      return Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 45,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_cricket_rounded,
              color: Colors.white.withValues(alpha: 0.30),
              size: 60,
            ),

            const SizedBox(height: 14),

            Text(
              'NO MATCHES YET',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              'Complete a match to see it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }
  
  Widget _buildHistoryCard(MatchHistoryEntry match, int index,) {
    final bool humanWon =
        match.result == MatchResult.humanWin;

    final bool computerWon =
        match.result == MatchResult.computerWin;

    final bool isTie =
        match.result == MatchResult.tie;

    String resultText;
    Color resultColor;
    IconData resultIcon;

    if (humanWon) {
      resultText = 'YOU WON';
      resultColor = const Color(0xFF76FF03);
      resultIcon = Icons.emoji_events_rounded;
    } else if (computerWon) {
      resultText = 'COMPUTER WON';
      resultColor = const Color(0xFFFF5252);
      resultIcon = Icons.computer_rounded;
    } else if (isTie) {
      resultText = 'MATCH TIED';
      resultColor = const Color(0xFF82B1FF);
      resultIcon = Icons.handshake_rounded;
    } else {
      resultText = 'MATCH FINISHED';
      resultColor = Colors.white;
      resultIcon = Icons.sports_cricket;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: resultColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: resultColor.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: resultColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  resultIcon,
                  color: resultColor,
                  size: 23,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      resultText,
                      style: TextStyle(
                        color: resultColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      _formatHistoryDate(match.playedAt),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.45),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),

              Text(
                '#${index + 1}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'YOU',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.50),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match.humanScore.toString(),
                        style: const TextStyle(
                          color: Color(0xFF76FF03),
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),

                Text(
                  'VS',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'COMPUTER',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.50),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        match.computerScore.toString(),
                        style: const TextStyle(
                          color: Color(0xFFFFA726),
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 11),

          Row(
            children: [
              Icon(
                Icons.sports_cricket,
                color: Colors.white.withValues(alpha: 0.40),
                size: 16,
              ),

              const SizedBox(width: 7),

              Expanded(
                child: Text(
                  match.firstBatsman == PlayerType.human
                      ? 'You batted first'
                      : 'Computer batted first',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.50),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatHistoryDate(DateTime dateTime) {
    final day =
        dateTime.day.toString().padLeft(2, '0');

    final month =
        dateTime.month.toString().padLeft(2, '0');

    final year = dateTime.year.toString();

    final hour =
        dateTime.hour.toString().padLeft(2, '0');

    final minute =
        dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year  $hour:$minute';
  }  
  
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:engineering_cricket/controllers/game_controller.dart';
import '../services/audio_service.dart';
import '../widgets/exit_confirmation_dialog.dart';
import '../widgets/settings_dialog.dart';
import '../widgets/stadium_background.dart';
import 'toss_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.gameController});

  final GameController gameController;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GameController get gameController => widget.gameController;

  @override
  void initState() {
    super.initState();
    gameController.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    gameController.removeListener(_onControllerChange);
    super.dispose();
  }

  void _onControllerChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final exit = await ExitConfirmationDialog.show(
          context,
          title: 'Are you leaving soon?',
          subtitle: 'The stadium is waiting for your next match! Don\'t walk back to the pavilion yet.',
          stayText: 'STAY & PLAY',
          leaveText: 'EXIT APP',
        );
        if (exit && context.mounted) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: StadiumBackground(
          showFloodlights: true,
          child: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      maxWidth: constraints.maxWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              _buildTopBar(context),
                              const SizedBox(height: 10),
                              _buildHeroHeader(),
                              const SizedBox(height: 14),
                              _buildCareerStatsCard(),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            children: [
                              _buildPlayGameButton(context),
                              const SizedBox(height: 10),
                              _buildSecondaryButtons(context),
                              const SizedBox(height: 12),
                              Text(
                                'PLAY • SCORE • CELEBRATE',
                                style: GoogleFonts.outfit(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 3,
                                ),
                              ),
                              const SizedBox(height: 6),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final diff = gameController.difficulty;
    final diffName = diff.name.toUpperCase();
    final diffColor = diff == AiDifficulty.pro
        ? const Color(0xFFFF1744)
        : (diff == AiDifficulty.club ? const Color(0xFF00E5FF) : const Color(0xFF76FF03));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: diffColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: diffColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.psychology_rounded, color: diffColor, size: 16),
              const SizedBox(width: 6),
              Text(
                'AI: $diffName',
                style: TextStyle(
                  color: diffColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            AudioService.instance.playTap();
            SettingsDialog.show(context, gameController);
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.08),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
          ),
          icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 22),
        ),
      ],
    );
  }

  Widget _buildHeroHeader() {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const RadialGradient(
              colors: [Color(0xFFFFB300), Color(0xFFFF6D00)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF9100).withValues(alpha: 0.5),
                blurRadius: 24,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.sports_cricket_rounded,
            size: 38,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'HAND CRICKET',
          textAlign: TextAlign.center,
          style: GoogleFonts.rajdhani(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 2.5,
          ),
        ),
        Text(
          'THE ULTIMATE FINGER DUEL',
          style: GoogleFonts.outfit(
            color: const Color(0xFF76FF03),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildCareerStatsCard() {
    final played = gameController.careerMatchesPlayed;
    final won = gameController.careerMatchesWon;
    final winRate = gameController.careerWinRate.toStringAsFixed(0);
    final high = gameController.careerHighestScore;
    final fours = gameController.careerTotalFours;
    final sixes = gameController.careerTotalSixes;
    final tens = gameController.careerTotalTens;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D1C3E).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
        ),
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
          Row(
            children: [
              const Icon(Icons.leaderboard_rounded, color: Color(0xFFFFD600), size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'CAREER STATS',
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.rajdhani(
                    color: const Color(0xFFFFD600),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF76FF03).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'WIN RATE $winRate%',
                  style: const TextStyle(
                    color: Color(0xFF76FF03),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatColumn('MATCHES', '$won/$played', const Color(0xFF00E5FF))),
              _buildStatDivider(),
              Expanded(child: _buildStatColumn('HIGHEST', '$high', const Color(0xFFFFD600))),
              _buildStatDivider(),
              Expanded(child: _buildStatColumn('BOUNDARIES', '${fours + sixes + tens}', const Color(0xFFFF5252))),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white12,
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: GoogleFonts.rajdhani(
              color: color,
              fontSize: 20,
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
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayGameButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF00E676), Color(0xFF00C853)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00E676).withValues(alpha: 0.45),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          AudioService.instance.playTap();
          gameController.resetGame();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TossScreen(
                gameController: gameController,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.sports_cricket_rounded,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'START MATCH',
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildSecondaryButton(
            icon: Icons.menu_book_rounded,
            text: 'RULES',
            color: const Color(0xFF2979FF),
            onPressed: () {
              AudioService.instance.playTap();
              _showHowToPlayDialog(context);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSecondaryButton(
            icon: Icons.history_rounded,
            text: 'HISTORY',
            color: const Color(0xFFAB47BC),
            onPressed: () {
              AudioService.instance.playTap();
              _showMatchHistoryDialog(context);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildSecondaryButton(
            icon: Icons.tune_rounded,
            text: 'SETTINGS',
            color: const Color(0xFF00B0FF),
            onPressed: () {
              AudioService.instance.playTap();
              SettingsDialog.show(context, gameController);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSecondaryButton({
    required IconData icon,
    required String text,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0D1C3E).withValues(alpha: 0.8),
          foregroundColor: Colors.white,
          elevation: 0,
          side: BorderSide(color: color.withValues(alpha: 0.35), width: 1.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHowToPlayDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF0C1635),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Container(
            constraints: BoxConstraints(
              maxWidth: 500,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.menu_book_rounded, color: Color(0xFFFFD600), size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'HOW TO PLAY',
                        style: GoogleFonts.rajdhani(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close, color: Colors.white60),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildRuleItem('1. 🪙 WIN THE TOSS', 'Pick ODD or EVEN, then throw a number (1-5). If total parity matches your call, you win the toss!'),
                        _buildRuleItem('2. 🏏 CHOOSE BAT OR BOWL', 'Toss winner decides whether to Bat first or Bowl first.'),
                        _buildRuleItem('3. ✋ SELECT YOUR NUMBER', 'Each ball, choose a number: 1, 2, 3, 4, 5, 6, or MAXIMUM 10.'),
                        _buildRuleItem('4. 💥 SCORING RUNS', 'If your number differs from the bowler, the batsman gets those runs! Boundaries (4, 6, 10) trigger special fireworks!'),
                        _buildRuleItem('5. ⚡ GETTING OUT', 'If batsman and bowler throw the EXACT SAME number, the batsman is OUT! No runs are awarded for that ball.'),
                        _buildRuleItem('6. 🎯 THE CHASE (2ND INNINGS)', 'The chasing player must exceed the 1st innings target before losing their wicket(s).'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00E676),
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('LET\'S PLAY!', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRuleItem(String title, String desc) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFD600),
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            desc,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 12,
              height: 1.35,
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
              backgroundColor: const Color(0xFF0C1635),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: 520,
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history_rounded, color: Color(0xFFFFD600), size: 24),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'MATCH HISTORY',
                            style: GoogleFonts.rajdhani(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5,
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
                            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFFF5252)),
                          ),
                        IconButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          icon: const Icon(Icons.close, color: Colors.white60),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.white12),
                    Expanded(
                      child: history.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.sports_cricket_rounded, size: 50, color: Colors.white.withValues(alpha: 0.2)),
                                  const SizedBox(height: 10),
                                  Text(
                                    'NO MATCHES YET',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.6),
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              physics: const BouncingScrollPhysics(),
                              itemCount: history.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 10),
                              itemBuilder: (context, index) {
                                final match = history[index];
                                return _buildHistoryCard(match, index);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryCard(MatchHistoryEntry match, int index) {
    final humanWon = match.result == MatchResult.humanWin;
    final computerWon = match.result == MatchResult.computerWin;
    final isTie = match.result == MatchResult.tie;

    Color resultColor;
    String resultText;
    IconData resultIcon;

    if (humanWon) {
      resultColor = const Color(0xFF76FF03);
      resultText = 'YOU WON';
      resultIcon = Icons.emoji_events_rounded;
    } else if (computerWon) {
      resultColor = const Color(0xFFFF5252);
      resultText = 'COMPUTER WON';
      resultIcon = Icons.computer_rounded;
    } else if (isTie) {
      resultColor = const Color(0xFF82B1FF);
      resultText = 'MATCH TIED';
      resultIcon = Icons.handshake_rounded;
    } else {
      resultColor = Colors.white;
      resultText = 'COMPLETED';
      resultIcon = Icons.sports_cricket_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: resultColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: resultColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(resultIcon, color: resultColor, size: 18),
              const SizedBox(width: 8),
              Text(
                resultText,
                style: TextStyle(
                  color: resultColor,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                '#${index + 1}',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text('YOU', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold)),
                  Text('${match.humanScore}', style: const TextStyle(color: Color(0xFF76FF03), fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ),
              Text('VS', style: TextStyle(color: Colors.white.withValues(alpha: 0.3), fontSize: 11, fontWeight: FontWeight.bold)),
              Column(
                children: [
                  Text('COMPUTER', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10, fontWeight: FontWeight.bold)),
                  Text('${match.computerScore}', style: const TextStyle(color: Color(0xFFFF9100), fontSize: 18, fontWeight: FontWeight.w900)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
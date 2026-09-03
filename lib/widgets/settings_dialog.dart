import 'package:flutter/material.dart';
import '../controllers/game_controller.dart';
import '../services/audio_service.dart';

/// Full-featured, modern glassmorphic Settings modal dialog.
class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key, required this.gameController});

  final GameController gameController;

  static Future<void> show(BuildContext context, GameController controller) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (_) => SettingsDialog(gameController: controller),
    );
  }

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  GameController get controller => widget.gameController;
  final AudioService audio = AudioService.instance;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1635).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
              blurRadius: 35,
              spreadRadius: 2,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.8),
              blurRadius: 25,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 22, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.4),
                      ),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Color(0xFF00E5FF),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'GAME SETTINGS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white12, height: 1),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('AUDIO & HAPTICS', Icons.volume_up_rounded),
                    const SizedBox(height: 10),
                    _buildToggleTile(
                      title: 'Sound Effects',
                      subtitle: 'Realistic bat cracks, cheers & umpire sounds',
                      value: audio.soundEnabled,
                      icon: Icons.music_note_rounded,
                      onChanged: (val) async {
                        await audio.setSoundEnabled(val);
                        if (val) audio.playCoinFlip();
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 10),
                    _buildToggleTile(
                      title: 'Haptic Feedback',
                      subtitle: 'Tactile device vibrations on hits and wickets',
                      value: audio.hapticEnabled,
                      icon: Icons.vibration_rounded,
                      onChanged: (val) async {
                        await audio.setHapticEnabled(val);
                        if (val) audio.heavyImpact();
                        setState(() {});
                      },
                    ),

                    const SizedBox(height: 24),

                    _buildSectionHeader('AI DIFFICULTY', Icons.psychology_rounded),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildDifficultyOption(
                          label: 'ROOKIE',
                          desc: 'Casual & Fun',
                          diff: AiDifficulty.rookie,
                          color: const Color(0xFF76FF03),
                        ),
                        const SizedBox(width: 8),
                        _buildDifficultyOption(
                          label: 'CLUB',
                          desc: 'Balanced',
                          diff: AiDifficulty.club,
                          color: const Color(0xFF00E5FF),
                        ),
                        const SizedBox(width: 8),
                        _buildDifficultyOption(
                          label: 'PRO',
                          desc: 'Mind Reader',
                          diff: AiDifficulty.pro,
                          color: const Color(0xFFFF1744),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    _buildSectionHeader('MATCH FORMAT', Icons.sports_cricket_rounded),
                    const SizedBox(height: 10),
                    _buildMatchModeTile(
                      title: 'Classic 1-Wicket',
                      subtitle: 'Fast-paced sudden death Hand Cricket',
                      mode: MatchMode.classic,
                      icon: Icons.flash_on_rounded,
                    ),
                    const SizedBox(height: 8),
                    _buildMatchModeTile(
                      title: '3-Wickets Innings',
                      subtitle: 'Deep strategic match with wickets in hand',
                      mode: MatchMode.threeWickets,
                      icon: Icons.format_list_numbered_rounded,
                    ),
                    const SizedBox(height: 8),
                    _buildMatchModeTile(
                      title: 'Super Over Blitz',
                      subtitle: 'High stakes showdown: 6 balls per side',
                      mode: MatchMode.superOver,
                      icon: Icons.timer_rounded,
                    ),

                    const SizedBox(height: 24),

                    _buildSectionHeader('DATA MANAGEMENT', Icons.storage_rounded),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF5252),
                        side: BorderSide(
                          color: const Color(0xFFFF5252).withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                      onPressed: () => _confirmResetStats(context),
                      icon: const Icon(Icons.restart_alt_rounded),
                      label: const Text(
                        'RESET CAREER STATS',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Credits
                    Center(
                      child: Text(
                        'Engineering Hand Cricket v1.2 • Pro Edition',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.35),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFFFD600), size: 16),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFD600),
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildToggleTile({
    required String title,
    required String subtitle,
    required bool value,
    required IconData icon,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF00E5FF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeTrackColor: const Color(0xFF76FF03),
            activeThumbColor: Colors.black,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyOption({
    required String label,
    required String desc,
    required AiDifficulty diff,
    required Color color,
  }) {
    final isSelected = controller.difficulty == diff;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          audio.playTap();
          controller.setDifficulty(diff);
          setState(() {});
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.22) : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? color : Colors.white.withValues(alpha: 0.1),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? color : Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMatchModeTile({
    required String title,
    required String subtitle,
    required MatchMode mode,
    required IconData icon,
  }) {
    final isSelected = controller.matchMode == mode;
    const activeColor = Color(0xFF00E5FF);

    return GestureDetector(
      onTap: () {
        audio.playTap();
        controller.setMatchMode(mode);
        setState(() {});
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? activeColor : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : Colors.white60,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.45),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: activeColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  void _confirmResetStats(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0C1635),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Career Stats?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: const Text(
          'This will permanently clear your match records, boundaries, and win count. Are you sure?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF1744),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await controller.resetCareerStats();
              if (ctx.mounted) Navigator.pop(ctx);
              setState(() {});
            },
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }
}

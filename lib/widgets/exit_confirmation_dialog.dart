import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';

class ExitConfirmationDialog extends StatelessWidget {
  const ExitConfirmationDialog({
    super.key,
    this.title = 'Leaving so soon?',
    this.subtitle = 'The stadium is waiting for your next big shot! Don\'t abandon the pitch yet.',
    this.stayText = 'STAY & PLAY',
    this.leaveText = 'LEAVE',
  });

  final String title;
  final String subtitle;
  final String stayText;
  final String leaveText;

  static Future<bool> show(
    BuildContext context, {
    String title = 'Leaving so soon?',
    String subtitle = 'The stadium is waiting for your next big shot! Don\'t abandon the pitch yet.',
    String stayText = 'STAY & PLAY',
    String leaveText = 'LEAVE',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => ExitConfirmationDialog(
        title: title,
        subtitle: subtitle,
        stayText: stayText,
        leaveText: leaveText,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF0C1635),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFFF5252).withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: const Color(0xFFFF5252).withValues(alpha: 0.15),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Sad emoji badge
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF5252).withValues(alpha: 0.12),
                border: Border.all(
                  color: const Color(0xFFFF5252).withValues(alpha: 0.4),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF5252).withValues(alpha: 0.25),
                    blurRadius: 18,
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  '🥺',
                  style: TextStyle(fontSize: 40),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Title with requested exact text and sad emoji
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 13,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 22),

            // Actions
            Row(
              children: [
                // Leave button
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: OutlinedButton(
                      onPressed: () {
                        AudioService.instance.playTap();
                        Navigator.of(context).pop(true);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFFF5252),
                        side: BorderSide(
                          color: const Color(0xFFFF5252).withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          leaveText,
                          style: GoogleFonts.rajdhani(
                            color: const Color(0xFFFF5252),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Stay & Play button (Recommended)
                Expanded(
                  child: Container(
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00E676), Color(0xFF00C853)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withValues(alpha: 0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        AudioService.instance.playTap();
                        Navigator.of(context).pop(false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          stayText,
                          style: GoogleFonts.rajdhani(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Renders a distinctive hand cricket number badge with stylized finger gestures,
/// glowing accent colors, and tactile micro-animation response.
class HandGestureBadge extends StatelessWidget {
  const HandGestureBadge({
    super.key,
    required this.number,
    this.isSelected = false,
    this.size = 56,
    this.showFingers = true,
  });

  final int number;
  final bool isSelected;
  final double size;
  final bool showFingers;

  Color get _badgeColor {
    switch (number) {
      case 1:
        return const Color(0xFF00E5FF); // Electric Cyan
      case 2:
        return const Color(0xFF76FF03); // Neon Green
      case 3:
        return const Color(0xFFFFD600); // Solar Yellow
      case 4:
        return const Color(0xFFFF9100); // Vivid Orange (Boundary)
      case 5:
        return const Color(0xFFE040FB); // Magenta
      case 6:
        return const Color(0xFFFF1744); // Crimson (Sixer)
      case 10:
        return const Color(0xFFFF3D00); // Fire (Maximum 10)
      default:
        return Colors.white;
    }
  }

  String get _fingerLabel {
    switch (number) {
      case 1:
        return '☝️ Index';
      case 2:
        return '✌️ Peace';
      case 3:
        return '🤟 Three';
      case 4:
        return '🖖 Four';
      case 5:
        return '🖐️ Palm';
      case 6:
        return '🤙 Six';
      case 10:
        return '🙌 Both';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _badgeColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isSelected
            ? color.withValues(alpha: 0.35)
            : const Color(0xFF101C42).withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(
          color: isSelected ? color : color.withValues(alpha: 0.35),
          width: isSelected ? 2.5 : 1.5,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(size * 0.08),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  number.toString(),
                  style: TextStyle(
                    color: isSelected ? Colors.white : color,
                    fontSize: size * 0.44,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    height: 1.0,
                    shadows: isSelected
                        ? [
                            Shadow(
                              color: color,
                              blurRadius: 10,
                            ),
                          ]
                        : null,
                  ),
                ),
                if (showFingers && size >= 54) ...[
                  SizedBox(height: size * 0.04),
                  Text(
                    _fingerLabel.split(' ').first,
                    style: TextStyle(
                      fontSize: size * 0.20,
                      height: 1.0,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

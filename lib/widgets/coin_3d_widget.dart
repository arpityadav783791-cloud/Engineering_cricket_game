import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/audio_service.dart';

/// 3D Animated Coin Flip Widget for the Toss with genuine perspective rotation,
/// metallic gold/blue finishes, and tactile feedback.
class Coin3DWidget extends StatefulWidget {
  const Coin3DWidget({
    super.key,
    required this.isFlipping,
    this.targetOdd,
    this.onFlipComplete,
    this.size = 140,
  });

  final bool isFlipping;
  final bool? targetOdd; // true for ODD, false for EVEN
  final VoidCallback? onFlipComplete;
  final double size;

  @override
  State<Coin3DWidget> createState() => _Coin3DWidgetState();
}

class _Coin3DWidgetState extends State<Coin3DWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _setupAnimation();

    if (widget.isFlipping) {
      _startFlip();
    }
  }

  void _setupAnimation() {
    // 5 full rotations (10 * pi) plus target side landing
    final targetEnd = (widget.targetOdd ?? true) ? (10 * math.pi) : (11 * math.pi);

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: targetEnd,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onFlipComplete?.call();
      }
    });
  }

  void _startFlip() {
    AudioService.instance.playCoinFlip();
    _controller.reset();
    _setupAnimation();
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant Coin3DWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipping && !oldWidget.isFlipping) {
      _startFlip();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _rotationAnimation.value;
        final normalizedAngle = angle % (2 * math.pi);
        final isFront = normalizedAngle <= (math.pi / 2) || normalizedAngle >= (3 * math.pi / 2);

        // Calculate bounce height
        final bounce = math.sin(_controller.value * math.pi) * 35;

        return Transform.translate(
          offset: Offset(0, -bounce),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002) // 3D perspective
              ..rotateX(angle),
            alignment: Alignment.center,
            child: _buildCoinFace(isFront: isFront),
          ),
        );
      },
    );
  }

  Widget _buildCoinFace({required bool isFront}) {
    final isOdd = isFront;
    final primaryColor = isOdd ? const Color(0xFFFFB300) : const Color(0xFF2979FF);
    final secondaryColor = isOdd ? const Color(0xFFFF6D00) : const Color(0xFF00E5FF);

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.4),
          radius: 0.9,
          colors: [
            Colors.white.withValues(alpha: 0.9),
            primaryColor,
            secondaryColor,
            const Color(0xFF0D1B2A),
          ],
          stops: const [0.0, 0.35, 0.8, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.4),
            blurRadius: 25,
            spreadRadius: 4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 3.5,
        ),
      ),
      child: Center(
        child: Container(
          width: widget.size * 0.78,
          height: widget.size * 0.78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.45),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isOdd ? Icons.sports_cricket_rounded : Icons.shield_rounded,
                color: Colors.white,
                size: widget.size * 0.30,
              ),
              const SizedBox(height: 4),
              Text(
                isOdd ? 'ODD' : 'EVEN',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.size * 0.15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.8),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

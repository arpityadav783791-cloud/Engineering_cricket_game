import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A rich, animated cricket stadium atmosphere background with floodlights,
/// glowing beam flares, and floating particles.
class StadiumBackground extends StatefulWidget {
  const StadiumBackground({
    super.key,
    required this.child,
    this.showFloodlights = true,
  });

  final Widget child;
  final bool showFloodlights;

  @override
  State<StadiumBackground> createState() => _StadiumBackgroundState();
}

class _StadiumBackgroundState extends State<StadiumBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          stops: [0.0, 0.45, 0.85, 1.0],
          colors: [
            Color(0xFF040B1E), // Deep night stadium sky
            Color(0xFF0C1938), // Floodlit upper atmosphere
            Color(0xFF0A222C), // Boundary haze
            Color(0xFF04151B), // Stadium turf shadow
          ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Animated light dust & atmospheric particles
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: _StadiumParticlesPainter(progress: _controller.value),
              );
            },
          ),

          // Floodlight beams from top corners
          if (widget.showFloodlights) ...[
            const Positioned(
              top: -60,
              left: -40,
              child: _FloodlightCone(isLeft: true),
            ),
            const Positioned(
              top: -60,
              right: -40,
              child: _FloodlightCone(isLeft: false),
            ),
            const Positioned(
              top: 50,
              left: -20,
              child: StadiumLightFixture(isLeft: true),
            ),
            const Positioned(
              top: 50,
              right: -20,
              child: StadiumLightFixture(isLeft: false),
            ),
          ],

          // Stadium field turf subtle line at bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 120,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      const Color(0xFF00E676).withValues(alpha: 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main child content
          widget.child,
        ],
      ),
    );
  }
}

/// Stadium Floodlight Tower Widget with realistic neon LED clusters and lens glow.
class StadiumLightFixture extends StatelessWidget {
  const StadiumLightFixture({super.key, required this.isLeft});

  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: isLeft ? 0.22 : -0.22,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: const Color(0xFF0E1A38).withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.25),
              blurRadius: 28,
              spreadRadius: 4,
            ),
            BoxShadow(
              color: const Color(0xFF76FF03).withValues(alpha: 0.15),
              blurRadius: 15,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: 11,
              height: 18,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Color(0xFFE0F7FA),
                    Color(0xFF80DEEA),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.9),
                    blurRadius: 6,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _FloodlightCone extends StatelessWidget {
  const _FloodlightCone({required this.isLeft});

  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Transform.rotate(
        angle: isLeft ? 0.45 : -0.45,
        child: Container(
          width: 260,
          height: 380,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: isLeft ? Alignment.topLeft : Alignment.topRight,
              radius: 1.2,
              colors: [
                const Color(0xFF00E5FF).withValues(alpha: 0.22),
                const Color(0xFF00B0FF).withValues(alpha: 0.08),
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

class _StadiumParticlesPainter extends CustomPainter {
  _StadiumParticlesPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(12345);
    final count = 35;

    for (int i = 0; i < count; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;
      final speed = 0.2 + random.nextDouble() * 0.8;
      final radius = 1.0 + random.nextDouble() * 2.2;
      final opacityBase = 0.15 + random.nextDouble() * 0.4;

      final currentY = (baseY - (progress * speed * size.height)) % size.height;
      final currentX = baseX + math.sin((progress + i) * math.pi * 2) * 12;

      final paint = Paint()
        ..color = (i % 3 == 0
                ? const Color(0xFF76FF03)
                : (i % 3 == 1 ? const Color(0xFF00E5FF) : const Color(0xFFFFD600)))
            .withValues(alpha: opacityBase);

      canvas.drawCircle(Offset(currentX, currentY), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _StadiumParticlesPainter oldDelegate) => true;
}

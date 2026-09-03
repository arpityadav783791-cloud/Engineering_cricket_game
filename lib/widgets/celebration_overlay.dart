import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Interactive celebration overlay providing confetti, fireworks, screen shake,
/// and electric boundary/wicket alert banners.
class CelebrationOverlay extends StatefulWidget {
  const CelebrationOverlay({
    super.key,
    required this.child,
    this.controller,
  });

  final Widget child;
  final CelebrationController? controller;

  @override
  State<CelebrationOverlay> createState() => _CelebrationOverlayState();
}

class CelebrationController extends ChangeNotifier {
  _CelebrationOverlayState? _state;

  void triggerBoundary(int runs) {
    _state?._triggerBoundary(runs);
  }

  void triggerWicket() {
    _state?._triggerWicket();
  }

  void triggerVictory() {
    _state?._triggerVictory();
  }
}

class _CelebrationOverlayState extends State<CelebrationOverlay>
    with TickerProviderStateMixin {
  // Screen shake controller
  late AnimationController _shakeController;

  // Banner anim controller
  late AnimationController _bannerController;
  late Animation<double> _bannerScaleAnimation;
  late Animation<double> _bannerFadeAnimation;

  // Particle controller for confetti & fireworks
  late AnimationController _particleController;
  final List<_CelebrationParticle> _particles = [];
  final math.Random _random = math.Random();

  String _bannerTitle = '';
  String _bannerSubtitle = '';
  Color _bannerColor = const Color(0xFF76FF03);
  IconData _bannerIcon = Icons.sports_cricket;
  bool _isWicket = false;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _bannerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _bannerScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 1.15).chain(CurveTween(curve: Curves.easeOutBack)), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.8).chain(CurveTween(curve: Curves.easeIn)), weight: 15),
    ]).animate(_bannerController);

    _bannerFadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_bannerController);

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..addListener(() {
        setState(() {
          for (final p in _particles) {
            p.update();
          }
        });
      });
  }

  @override
  void didUpdateWidget(covariant CelebrationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  @override
  void dispose() {
    _shakeController.dispose();
    _bannerController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  void _triggerBoundary(int runs) {
    _isWicket = false;
    if (runs == 4) {
      _bannerTitle = 'FOUR!';
      _bannerSubtitle = 'CRACKING SHOT TO THE FENCE';
      _bannerColor = const Color(0xFF00E5FF);
      _bannerIcon = Icons.flash_on_rounded;
    } else if (runs == 6) {
      _bannerTitle = 'SIXER!';
      _bannerSubtitle = 'HIGH AND HANDSOME INTO THE STANDS';
      _bannerColor = const Color(0xFFFFD600);
      _bannerIcon = Icons.rocket_launch_rounded;
    } else if (runs == 10) {
      _bannerTitle = 'MAXIMUM 10!';
      _bannerSubtitle = 'UNBELIEVABLE POWER HIT';
      _bannerColor = const Color(0xFFFF1744);
      _bannerIcon = Icons.local_fire_department_rounded;
    } else {
      return;
    }

    _spawnParticles(count: runs * 12, isCelebration: true);
    _bannerController.forward(from: 0.0);
  }

  void _triggerWicket() {
    _isWicket = true;
    _bannerTitle = 'OUT!';
    _bannerSubtitle = 'FINGER GOES UP! TIMBER SHATTERED';
    _bannerColor = const Color(0xFFFF1744);
    _bannerIcon = Icons.dangerous_rounded;

    _shakeController.forward(from: 0.0);
    _bannerController.forward(from: 0.0);
  }

  void _triggerVictory() {
    _isWicket = false;
    _bannerTitle = 'VICTORY!';
    _bannerSubtitle = 'CHAMPION OF HAND CRICKET';
    _bannerColor = const Color(0xFF76FF03);
    _bannerIcon = Icons.emoji_events_rounded;

    _spawnParticles(count: 80, isCelebration: true);
    _bannerController.forward(from: 0.0);
  }

  void _spawnParticles({required int count, required bool isCelebration}) {
    _particles.clear();
    final colors = [
      const Color(0xFF76FF03),
      const Color(0xFF00E5FF),
      const Color(0xFFFFD600),
      const Color(0xFFFF6D00),
      const Color(0xFFFF1744),
      Colors.white,
    ];

    for (int i = 0; i < count; i++) {
      final angle = _random.nextDouble() * 2 * math.pi;
      final speed = 3.0 + _random.nextDouble() * 9.0;
      _particles.add(
        _CelebrationParticle(
          x: 200, // centered dynamically in paint
          y: 300,
          vx: math.cos(angle) * speed,
          vy: math.sin(angle) * speed - 3.5,
          color: colors[_random.nextInt(colors.length)],
          size: 4.0 + _random.nextDouble() * 6.0,
          gravity: 0.22,
          drag: 0.96,
        ),
      );
    }
    _particleController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeController,
      builder: (context, child) {
        final shake = math.sin(_shakeController.value * math.pi * 8) * (1.0 - _shakeController.value) * 12;
        return Transform.translate(
          offset: Offset(shake, 0),
          child: child,
        );
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          widget.child,

          // Particle overlay
          if (_particles.isNotEmpty)
            IgnorePointer(
              child: CustomPaint(
                painter: _ParticleCanvasPainter(particles: _particles),
              ),
            ),

          // Flash overlay on wicket
          if (_isWicket)
            IgnorePointer(
              child: AnimatedBuilder(
                animation: _bannerFadeAnimation,
                builder: (context, _) {
                  return Container(
                    color: const Color(0xFFFF1744).withValues(alpha: _bannerFadeAnimation.value * 0.18),
                  );
                },
              ),
            ),

          // Banner popup
          Positioned(
            left: 20,
            right: 20,
            top: 140,
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _bannerController,
                builder: (context, _) {
                  if (_bannerController.value == 0.0 || _bannerController.value == 1.0) {
                    return const SizedBox.shrink();
                  }

                  return Opacity(
                    opacity: _bannerFadeAnimation.value.clamp(0.0, 1.0),
                    child: Transform.scale(
                      scale: _bannerScaleAnimation.value,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C1735).withValues(alpha: 0.95),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _bannerColor,
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _bannerColor.withValues(alpha: 0.5),
                              blurRadius: 30,
                              spreadRadius: 4,
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.7),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: _bannerColor.withValues(alpha: 0.18),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: _bannerColor.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Icon(
                                _bannerIcon,
                                color: _bannerColor,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _bannerTitle,
                                    style: TextStyle(
                                      color: _bannerColor,
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _bannerSubtitle,
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
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
        ],
      ),
    );
  }
}

class _CelebrationParticle {
  _CelebrationParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.size,
    required this.gravity,
    required this.drag,
  });

  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double size;
  double gravity;
  double drag;
  double opacity = 1.0;

  void update() {
    x += vx;
    y += vy;
    vy += gravity;
    vx *= drag;
    vy *= drag;
    opacity = (opacity - 0.016).clamp(0.0, 1.0);
  }
}

class _ParticleCanvasPainter extends CustomPainter {
  _ParticleCanvasPainter({required this.particles});

  final List<_CelebrationParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (p.opacity <= 0) continue;
      final paint = Paint()
        ..color = p.color.withValues(alpha: p.opacity)
        ..style = PaintingStyle.fill;

      // Draw particle relative to center top
      canvas.drawCircle(Offset((size.width / 2) + p.x - 200, (size.height * 0.3) + p.y - 300), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticleCanvasPainter oldDelegate) => true;
}

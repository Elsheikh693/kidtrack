import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A soft field of little stars that gently twinkle behind the reveal. Purely
/// decorative — positions are seeded once so they stay put while only their
/// brightness pulses.
class StarTwinkleField extends StatefulWidget {
  const StarTwinkleField({super.key});

  @override
  State<StarTwinkleField> createState() => _StarTwinkleFieldState();
}

class _StarTwinkleFieldState extends State<StarTwinkleField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    final rnd = math.Random(42);
    _stars = List.generate(46, (_) {
      return _Star(
        dx: rnd.nextDouble(),
        dy: rnd.nextDouble(),
        radius: 0.6 + rnd.nextDouble() * 1.8,
        phase: rnd.nextDouble() * math.pi * 2,
        speed: 0.6 + rnd.nextDouble() * 1.2,
      );
    });
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => CustomPaint(
        painter: _TwinklePainter(_stars, _c.value),
        size: Size.infinite,
      ),
    );
  }
}

class _Star {
  const _Star({
    required this.dx,
    required this.dy,
    required this.radius,
    required this.phase,
    required this.speed,
  });

  final double dx;
  final double dy;
  final double radius;
  final double phase;
  final double speed;
}

class _TwinklePainter extends CustomPainter {
  _TwinklePainter(this.stars, this.t);

  final List<_Star> stars;
  final double t;

  static const _gold = Color(0xFFF5C542);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final s in stars) {
      final pulse =
          0.5 + 0.5 * math.sin(t * math.pi * 2 * s.speed + s.phase);
      final alpha = 0.15 + pulse * 0.6;
      paint.color = (s.radius > 1.6 ? _gold : Colors.white)
          .withValues(alpha: alpha);
      canvas.drawCircle(
        Offset(s.dx * size.width, s.dy * size.height),
        s.radius * (0.7 + pulse * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TwinklePainter old) => old.t != t;
}

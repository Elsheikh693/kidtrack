import 'dart:math' as math;

import '../../../../index/index_main.dart';
import 'onboard_data.dart';

/// Fully Flutter-drawn animated hero scene for an onboarding page.
///
/// Composes several continuously animated layers — drifting gradient blobs,
/// floating sparkle particles, a radar-style pulsing ring, a bobbing central
/// hero card and a ring of orbiting icon chips — plus a one-shot intro that
/// scales/fades the whole thing in. Everything is driven by two controllers so
/// the frame cost stays low.
class OnboardScene extends StatefulWidget {
  const OnboardScene({super.key, required this.data});

  final OnboardData data;

  @override
  State<OnboardScene> createState() => _OnboardSceneState();
}

class _OnboardSceneState extends State<OnboardScene>
    with TickerProviderStateMixin {
  late final AnimationController _loop;
  late final AnimationController _intro;

  static final List<_Particle> _particles = _buildParticles();

  static List<_Particle> _buildParticles() {
    final rnd = math.Random(7);
    return List.generate(
      14,
      (_) => _Particle(
        x: rnd.nextDouble(),
        y: rnd.nextDouble(),
        size: 2 + rnd.nextDouble() * 4,
        speed: 0.4 + rnd.nextDouble() * 0.8,
        phase: rnd.nextDouble(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..forward();
  }

  @override
  void dispose() {
    _loop.dispose();
    _intro.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    return AnimatedBuilder(
      animation: Listenable.merge([_loop, _intro]),
      builder: (context, _) {
        final t = _loop.value;
        final intro = Curves.easeOutBack.transform(_intro.value);
        final fade = Curves.easeOut.transform(_intro.value.clamp(0.0, 1.0));

        return LayoutBuilder(
          builder: (context, c) {
            final size = Size(c.maxWidth, c.maxHeight);
            final shortest = math.min(size.width, size.height);

            return ClipRect(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  ..._blobs(t, size, d),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _ParticlePainter(t, _particles, d.accentColor),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RingPainter(t, shortest * 0.30, d.accentColor),
                    ),
                  ),
                  Opacity(
                    opacity: fade,
                    child: Transform.scale(
                      scale: 0.7 + 0.3 * intro,
                      child: _hero(t, shortest, d),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ── layers ────────────────────────────────────────────────────────────────

  List<Widget> _blobs(double t, Size size, OnboardData d) {
    final a = math.sin(t * 2 * math.pi);
    final b = math.cos(t * 2 * math.pi);
    return [
      Positioned(
        left: size.width * 0.02 + a * 14,
        top: size.height * 0.04 + b * 14,
        child: _blob(size.width * 0.62, d.accentLight),
      ),
      Positioned(
        right: size.width * 0.0 - a * 16,
        bottom: size.height * 0.02 - b * 16,
        child: _blob(size.width * 0.60, d.accentColor2.withValues(alpha: 0.14)),
      ),
    ];
  }

  Widget _blob(double s, Color c) => Container(
        width: s,
        height: s,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [c, c.withValues(alpha: 0)],
          ),
        ),
      );

  Widget _hero(double t, double shortest, OnboardData d) {
    final orbitR = shortest * 0.34;
    final bob = math.sin(t * 2 * math.pi) * 7;
    final cardSize = shortest * 0.42;

    return SizedBox(
      width: shortest,
      height: shortest,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (int i = 0; i < d.satellites.length; i++)
            _satellite(i, d.satellites.length, t, orbitR, shortest,
                d.satellites[i]),
          Transform.translate(
            offset: Offset(0, bob),
            child: _centralCard(cardSize, d),
          ),
        ],
      ),
    );
  }

  Widget _satellite(int i, int n, double t, double radius, double shortest,
      OnboardSatellite s) {
    final angle = (i / n) * 2 * math.pi + t * 2 * math.pi;
    final dx = math.cos(angle) * radius;
    final dy = math.sin(angle) * radius * 0.86;
    final localBob = math.sin(t * 2 * math.pi * 2 + i * 1.7) * 4;
    final chip = shortest * 0.165;

    return Transform.translate(
      offset: Offset(dx, dy + localBob),
      child: Container(
        width: chip,
        height: chip,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(chip * 0.34),
          boxShadow: [
            BoxShadow(
              color: s.color.withValues(alpha: 0.22),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Icon(s.icon, color: s.color, size: chip * 0.5),
      ),
    );
  }

  Widget _centralCard(double size, OnboardData d) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(size * 0.32),
        boxShadow: [
          BoxShadow(
            color: d.accentColor.withValues(alpha: 0.28),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.66,
          height: size * 0.66,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [d.accentColor, d.accentColor2],
            ),
            boxShadow: [
              BoxShadow(
                color: d.accentColor.withValues(alpha: 0.4),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Icon(d.heroIcon, color: AppColors.white, size: size * 0.34),
        ),
      ),
    );
  }
}

// ── particles ─────────────────────────────────────────────────────────────

class _Particle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double phase;

  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
  });
}

class _ParticlePainter extends CustomPainter {
  _ParticlePainter(this.t, this.particles, this.color);

  final double t;
  final List<_Particle> particles;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (final p in particles) {
      final prog = (p.y - (t * p.speed) + p.phase) % 1.0;
      final dy = prog * size.height;
      final dx = p.x * size.width +
          math.sin((prog + p.phase) * 2 * math.pi) * 14;
      final fade = math.sin(prog * math.pi);
      paint.color = color.withValues(alpha: 0.10 + 0.22 * fade);
      canvas.drawCircle(Offset(dx, dy), p.size, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter old) => old.t != t || old.color != color;
}

// ── pulsing rings ───────────────────────────────────────────────────────────

class _RingPainter extends CustomPainter {
  _RingPainter(this.t, this.baseRadius, this.color);

  final double t;
  final double baseRadius;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    for (int i = 0; i < 3; i++) {
      final prog = ((t * 1.0) + i / 3) % 1.0;
      final radius = baseRadius * (0.7 + prog * 1.5);
      final fade = (1 - prog) * 0.5;
      paint.color = color.withValues(alpha: fade);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.t != t || old.color != color || old.baseRadius != baseRadius;
}

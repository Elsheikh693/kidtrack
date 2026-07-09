import 'dart:math' as math;

import '../../../../../index/index_main.dart';

/// Slowly drifting soft light orbs behind the activation landing — gives the
/// gradient depth and motion without stealing focus from the logo.
class ActivationLandingBackground extends StatefulWidget {
  const ActivationLandingBackground({super.key});

  @override
  State<ActivationLandingBackground> createState() =>
      _ActivationLandingBackgroundState();
}

class _ActivationLandingBackgroundState
    extends State<ActivationLandingBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
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
      builder: (context, _) {
        final t = _c.value * 2 * math.pi;
        return Stack(
          children: [
            _orb(-0.7, -0.75, 180, math.sin(t) * 12, math.cos(t) * 16, 0.12),
            _orb(0.75, -0.85, 130, math.cos(t) * 14, math.sin(t) * 10, 0.10),
            _orb(0.85, -0.1, 220, math.sin(t + 1) * 16, math.cos(t + 1) * 14, 0.07),
            _orb(-0.8, 0.05, 110, math.cos(t + 2) * 12, math.sin(t + 2) * 12, 0.09),
          ],
        );
      },
    );
  }

  Widget _orb(double ax, double ay, double size, double dx, double dy,
      double alpha) {
    return Align(
      alignment: Alignment(ax, ay),
      child: Transform.translate(
        offset: Offset(dx, dy),
        child: Container(
          width: size.w,
          height: size.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.white.withValues(alpha: alpha),
                AppColors.white.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

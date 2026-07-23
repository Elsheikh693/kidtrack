import '../../../../../index/index_main.dart';

/// A small dot that softly pulses to signal "live / happening right now".
/// Used in the live-teaching header and on each running-session card.
class LivePulseDot extends StatefulWidget {
  const LivePulseDot({super.key, this.color, this.size});

  final Color? color;
  final double? size;

  @override
  State<LivePulseDot> createState() => _LivePulseDotState();
}

class _LivePulseDotState extends State<LivePulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.activityGreen;
    final size = widget.size ?? 8.w;
    return SizedBox(
      width: size * 2.2,
      height: size * 2.2,
      child: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, child) {
            final t = _ctrl.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: size + (size * 1.2 * t),
                  height: size + (size * 1.2 * t),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.28 * (1 - t)),
                  ),
                ),
                child!,
              ],
            );
          },
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          ),
        ),
      ),
    );
  }
}

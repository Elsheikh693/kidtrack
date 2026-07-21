import '../../../../../index/index_main.dart';

/// Shared entrance + press motion for Analytics Center cards. Fades and slides
/// the [child] up with a per-[index] stagger, then scales it down while pressed.
class AnalyticsReveal extends StatefulWidget {
  final int index;
  final VoidCallback? onTap;
  final Widget child;

  const AnalyticsReveal({
    super.key,
    required this.index,
    required this.child,
    this.onTap,
  });

  @override
  State<AnalyticsReveal> createState() => _AnalyticsRevealState();
}

class _AnalyticsRevealState extends State<AnalyticsReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  double _scale = 1;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 480));
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.14), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(
      Duration(milliseconds: 120 + widget.index * 70),
      () {
        if (mounted) _c.forward();
      },
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _setScale(double v) => setState(() => _scale = v);

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: GestureDetector(
          onTapDown: widget.onTap == null ? null : (_) => _setScale(0.97),
          onTapUp: widget.onTap == null ? null : (_) => _setScale(1),
          onTapCancel: widget.onTap == null ? null : () => _setScale(1),
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 130),
            curve: Curves.easeOut,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

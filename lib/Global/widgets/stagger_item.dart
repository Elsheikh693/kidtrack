import 'package:flutter/material.dart';

/// Wraps a single widget with a staggered fade-in + slide-up entrance.
///
/// Usage inside a SliverChildListDelegate or Column:
///   StaggerItem(index: 0, child: MySection()),
///   StaggerItem(index: 1, child: AnotherSection()),
///
/// Each item delays by [index] × [itemDelayMs] ms, then animates for [duration].
/// No shared controller needed — drop it anywhere.
class StaggerItem extends StatefulWidget {
  const StaggerItem({
    super.key,
    required this.index,
    required this.child,
    this.itemDelayMs = 90,
    this.duration = const Duration(milliseconds: 420),
    this.offsetY = 22.0,
  });

  final int index;
  final Widget child;
  final int itemDelayMs;
  final Duration duration;
  final double offsetY;

  @override
  State<StaggerItem> createState() => _StaggerItemState();
}

class _StaggerItemState extends State<StaggerItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);

    final delayMs = widget.index * widget.itemDelayMs;
    if (delayMs == 0) {
      _ctrl.forward();
    } else {
      Future.delayed(Duration(milliseconds: delayMs), () {
        if (mounted) _ctrl.forward();
      });
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      child: widget.child,
      builder: (_, w) => Opacity(
        opacity: _anim.value,
        child: Transform.translate(
          offset: Offset(0, widget.offsetY * (1 - _anim.value)),
          child: w,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// A quick, delightful center "logged ✓" confirmation that pops in (elastic
/// scale + fade) over everything and removes itself — the satisfying feedback
/// after logging a child event (toilet, ate…), on top of the undo snackbar.
void showEventLoggedBurst(String label) {
  final ctx = Get.overlayContext ?? Get.context;
  if (ctx == null) return;
  HapticFeedback.mediumImpact();
  final overlay = Overlay.of(ctx);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _EventLoggedBurst(label: label, onDone: entry.remove),
  );
  overlay.insert(entry);
}

class _EventLoggedBurst extends StatefulWidget {
  const _EventLoggedBurst({required this.label, required this.onDone});
  final String label;
  final VoidCallback onDone;

  @override
  State<_EventLoggedBurst> createState() => _EventLoggedBurstState();
}

class _EventLoggedBurstState extends State<_EventLoggedBurst>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  static const _green = Color(0xFF16A34A);

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 55,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 45),
    ]).animate(_c);
    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 15,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 60),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(_c);
    _c.forward();
    _c.addStatusListener((s) {
      if (s == AnimationStatus.completed) widget.onDone();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Center(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) => Opacity(
              opacity: _opacity.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        color: _green,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: _green.withValues(alpha: 0.4),
                            blurRadius: 28,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check_rounded,
                          color: Colors.white, size: 54),
                    ),
                    if (widget.label.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          widget.label,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'dart:math' as math;
import '../../../../../index/index_main.dart';
import '../models/teaching_slice.dart';

/// Paints the donut: one equal arc per class in session, each carrying the
/// subject being taught at its midpoint. Equal arcs on purpose — the ring is a
/// categorical "what is each class doing" view, not a magnitude chart.
class TeachingRingPainter extends CustomPainter {
  TeachingRingPainter({required this.slices, required this.labelStyle});

  final List<TeachingSlice> slices;
  final TextStyle labelStyle;

  // Radian gap between slices so adjacent arcs read as separate segments.
  static const _gap = 0.06;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final stroke = size.width * 0.17;
    final radius = (size.width - stroke) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    if (slices.isEmpty) {
      canvas.drawArc(
        rect,
        0,
        2 * math.pi,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = AppColors.chartTrack,
      );
      return;
    }

    final n = slices.length;
    final gap = n == 1 ? 0.0 : _gap;
    final sweep = (2 * math.pi - gap * n) / n;
    var start = -math.pi / 2 + gap / 2;

    for (var i = 0; i < n; i++) {
      canvas.drawArc(
        rect,
        start,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = n == 1 ? StrokeCap.butt : StrokeCap.round
          ..color = slices[i].color,
      );

      final mid = start + sweep / 2;
      final tp = TextPainter(
        text: TextSpan(text: slices[i].subjectLabel, style: labelStyle),
        textDirection: TextDirection.rtl,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: stroke * 2.6);
      tp.paint(
        canvas,
        Offset(
          center.dx + radius * math.cos(mid) - tp.width / 2,
          center.dy + radius * math.sin(mid) - tp.height / 2,
        ),
      );

      start += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant TeachingRingPainter old) =>
      old.slices != slices || old.labelStyle != labelStyle;
}

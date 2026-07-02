import 'dart:math' as math;
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../../index/index_main.dart';
import '../models/monthly_finance_point.dart';

/// Grouped bar chart of collected vs expenses over the last few months, drawn
/// with [CustomPaint] (no chart dependency): value axis, gridlines, rounded
/// bars. Display-only — renders pre-computed [MonthlyFinancePoint]s.
class FinanceTrendChart extends StatelessWidget {
  const FinanceTrendChart({
    super.key,
    required this.points,
    this.selectedIndex,
    this.onTapMonth,
  });

  final List<MonthlyFinancePoint> points;

  /// Index into [points] of the month to highlight (the one the screen is on).
  final int? selectedIndex;

  /// Tapping a bar selects that month.
  final void Function(int index)? onTapMonth;

  static const _collected = Color(0xFF16A34A);
  static const _expenses = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _LegendDot(color: _collected, labelKey: 'owner_fin_collected'),
              const SizedBox(width: 16),
              _LegendDot(color: _expenses, labelKey: 'owner_fin_expenses_section'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: LayoutBuilder(
              builder: (context, c) {
                final rtl = Directionality.of(context) == TextDirection.rtl;
                final chart = CustomPaint(
                  size: Size(c.maxWidth, 190),
                  painter: _BarsPainter(
                    points: points,
                    selectedIndex: selectedIndex,
                    collectedColor: _collected,
                    expensesColor: _expenses,
                    labelColor: AppColors.textSecondaryParagraph,
                    gridColor: const Color(0xFFE2E8F0),
                    highlightColor: AppColors.primary.withValues(alpha: 0.07),
                    rtl: rtl,
                  ),
                );
                if (onTapMonth == null) return chart;
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (d) =>
                      _handleTap(d.localPosition.dx, c.maxWidth, rtl),
                  child: chart,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(double dx, double width, bool rtl) {
    const gutter = 38.0;
    final plotLeft = rtl ? 0.0 : gutter;
    final plotRight = rtl ? width - gutter : width;
    final plotW = plotRight - plotLeft;
    if (plotW <= 0 || points.isEmpty) return;
    var slotPos = ((dx - plotLeft) / (plotW / points.length)).floor();
    if (slotPos < 0) slotPos = 0;
    if (slotPos > points.length - 1) slotPos = points.length - 1;
    final idx = rtl ? points.length - 1 - slotPos : slotPos;
    onTapMonth?.call(idx);
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.labelKey});

  final Color color;
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration:
              BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 6),
        Text(
          labelKey.tr,
          style: TextStyle(
            color: AppColors.textDefault,
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BarsPainter extends CustomPainter {
  _BarsPainter({
    required this.points,
    required this.selectedIndex,
    required this.collectedColor,
    required this.expensesColor,
    required this.labelColor,
    required this.gridColor,
    required this.highlightColor,
    required this.rtl,
  });

  final List<MonthlyFinancePoint> points;
  final int? selectedIndex;
  final Color collectedColor;
  final Color expensesColor;
  final Color labelColor;
  final Color gridColor;
  final Color highlightColor;
  final bool rtl;

  static const _gutter = 38.0; // left space for axis value labels
  static const _labelH = 24.0; // bottom space for month labels
  static const _gridSteps = 4;

  @override
  void paint(Canvas canvas, Size size) {
    final plotLeft = rtl ? 0.0 : _gutter;
    final plotRight = rtl ? size.width - _gutter : size.width;
    final plotW = plotRight - plotLeft;
    final chartTop = 6.0;
    final baseY = size.height - _labelH;
    final plotH = baseY - chartTop;

    final rawMax = points
        .map((p) => math.max(p.collected, p.expenses))
        .fold(0.0, math.max);
    final niceMax = _niceMax(rawMax);

    // ── Gridlines + value axis ───────────────────────────────────────────────
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var s = 0; s <= _gridSteps; s++) {
      final y = baseY - (plotH * s / _gridSteps);
      canvas.drawLine(Offset(plotLeft, y), Offset(plotRight, y), gridPaint);
      final value = niceMax * s / _gridSteps;
      _axisLabel(canvas, _abbr(value), plotLeft, plotRight, y);
    }

    // ── Bars ─────────────────────────────────────────────────────────────────
    final scale = niceMax > 0 ? plotH / niceMax : 0.0;
    final slot = plotW / points.length;
    final barW = (slot * 0.26).clamp(8.0, 22.0);
    const gap = 5.0;

    // Too many months → labels collide. Thin them, anchored to the newest month
    // so the latest is always labelled; the selected month is always shown too.
    final labelStep = points.length > 8 ? 2 : 1;

    for (var i = 0; i < points.length; i++) {
      final idx = rtl ? points.length - 1 - i : i;
      final p = points[idx];
      final cx = plotLeft + slot * i + slot / 2;

      if (idx == selectedIndex) {
        final hl = RRect.fromRectAndCorners(
          Rect.fromLTRB(
              plotLeft + slot * i + 1, chartTop, plotLeft + slot * (i + 1) - 1, baseY),
          topLeft: const Radius.circular(8),
          topRight: const Radius.circular(8),
        );
        canvas.drawRRect(hl, Paint()..color = highlightColor);
      }

      _bar(canvas, cx - barW - gap / 2, barW, baseY, p.collected * scale,
          collectedColor);
      _bar(canvas, cx + gap / 2, barW, baseY, p.expenses * scale, expensesColor);

      final fromNewest = points.length - 1 - idx;
      if (fromNewest % labelStep == 0 || idx == selectedIndex) {
        _monthLabel(
            canvas, _shortMonth(p.year, p.month), cx, baseY + 7, size.width);
      }
    }
  }

  void _bar(Canvas canvas, double x, double w, double baseY, double h, Color c) {
    final hh = h <= 0 ? 0.0 : math.max(h, 3.0);
    if (hh == 0) return;
    final rect = RRect.fromRectAndCorners(
      Rect.fromLTWH(x, baseY - hh, w, hh),
      topLeft: const Radius.circular(5),
      topRight: const Radius.circular(5),
    );
    canvas.drawRRect(rect, Paint()..color = c);
  }

  void _axisLabel(Canvas canvas, String text, double l, double r, double y) {
    final tp = _tp(text, 9.5, labelColor);
    final dx = rtl ? r + 6 : l - tp.width - 6;
    tp.paint(canvas, Offset(dx, y - tp.height / 2));
  }

  void _monthLabel(Canvas canvas, String text, double cx, double y, double maxW) {
    final tp = _tp(text, 10.5, labelColor, bold: true);
    var dx = cx - tp.width / 2;
    if (dx < 0) dx = 0;
    if (dx + tp.width > maxW) dx = maxW - tp.width;
    tp.paint(canvas, Offset(dx, y));
  }

  TextPainter _tp(String text, double size, Color color, {bool bold = false}) =>
      TextPainter(
        text: TextSpan(
          text: text,
          style: TextStyle(
            color: color,
            fontSize: size,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

  String _shortMonth(int year, int month) =>
      DateFormat.MMM(Get.locale?.toString()).format(DateTime(year, month));

  double _niceMax(double v) {
    if (v <= 0) return 100;
    final mag = math.pow(10, (math.log(v) / math.ln10).floor()).toDouble();
    final n = v / mag;
    final nice = n <= 1 ? 1.0 : (n <= 2 ? 2.0 : (n <= 5 ? 5.0 : 10.0));
    return nice * mag;
  }

  String _abbr(double v) {
    if (v >= 1000000) {
      final m = v / 1000000;
      return '${m == m.roundToDouble() ? m.toStringAsFixed(0) : m.toStringAsFixed(1)}M';
    }
    if (v >= 1000) {
      final k = v / 1000;
      return '${k == k.roundToDouble() ? k.toStringAsFixed(0) : k.toStringAsFixed(1)}k';
    }
    return v.toStringAsFixed(0);
  }

  @override
  bool shouldRepaint(_BarsPainter old) =>
      old.points != points || old.selectedIndex != selectedIndex;
}

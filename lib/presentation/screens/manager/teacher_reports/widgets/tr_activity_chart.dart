import '../../../../../index/index_main.dart';
import '../models/teacher_report_models.dart';
import 'tr_format.dart';

enum _Metric { sessions, minutes }

/// Ranked horizontal bar chart comparing teachers by activities or working
/// time. Animated bars, value labels, toggle between the two metrics.
class TrActivityChart extends StatefulWidget {
  const TrActivityChart({
    super.key,
    required this.teachers,
    required this.accent,
  });

  final List<TeacherPerformance> teachers;
  final Color accent;

  @override
  State<TrActivityChart> createState() => _TrActivityChartState();
}

class _TrActivityChartState extends State<TrActivityChart> {
  _Metric _metric = _Metric.sessions;

  int _value(TeacherPerformance t) =>
      _metric == _Metric.sessions ? t.sessionCount : t.workingMinutes;

  String _label(int v) =>
      _metric == _Metric.sessions ? '$v' : trDuration(v);

  @override
  Widget build(BuildContext context) {
    final ranked = widget.teachers.where((t) => t.hasActivity).toList()
      ..sort((a, b) => _value(b).compareTo(_value(a)));
    final top = ranked.take(6).toList();
    final maxV = top.isEmpty
        ? 1
        : top.map(_value).reduce((a, b) => a > b ? a : b).clamp(1, 1 << 30);

    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'tr_chart_title'.tr,
                  style: context.typography.displaySmBold.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDefault,
                  ),
                ),
              ),
              _toggle(),
            ],
          ),
          SizedBox(height: 16.h),
          if (top.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 18.h),
              child: Center(
                child: Text(
                  'tr_chart_empty'.tr,
                  style: context.typography.smSemiBold.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              ),
            )
          else
            for (int i = 0; i < top.length; i++) ...[
              if (i > 0) SizedBox(height: 12.h),
              _Bar(
                rank: i + 1,
                name: top[i].name,
                value: _value(top[i]),
                label: _label(_value(top[i])),
                fraction: _value(top[i]) / maxV,
                color: i == 0
                    ? widget.accent
                    : Color.lerp(widget.accent, Colors.white, 0.32)!,
              ),
            ],
        ],
      ),
    );
  }

  Widget _toggle() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          _toggleBtn('tr_metric_sessions'.tr, _Metric.sessions),
          _toggleBtn('tr_metric_time'.tr, _Metric.minutes),
        ],
      ),
    );
  }

  Widget _toggleBtn(String label, _Metric m) {
    final selected = _metric == m;
    return GestureDetector(
      onTap: () => setState(() => _metric = m),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 6.r,
                    offset: Offset(0, 2.h),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: selected
                ? widget.accent
                : AppColors.textSecondaryParagraph,
          ),
        ),
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({
    required this.rank,
    required this.name,
    required this.value,
    required this.label,
    required this.fraction,
    required this.color,
  });

  final int rank;
  final String name;
  final int value;
  final String label;
  final double fraction;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$rank.',
              style: context.typography.displaySmBold.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.displaySmBold.copyWith(
                  fontSize: 13,
                  color: AppColors.textDefault,
                ),
              ),
            ),
            Text(
              label,
              style: context.typography.displaySmBold.copyWith(
                fontSize: 12.5,
                fontWeight: FontWeight.w900,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(8.r),
          child: LayoutBuilder(
            builder: (context, c) => Stack(
              children: [
                Container(height: 9.h, color: const Color(0xFFEEF1F5)),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: fraction.clamp(0.04, 1.0)),
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => Container(
                    height: 9.h,
                    width: c.maxWidth * v,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

import '../../../../../index/index_main.dart';
import '../models/teacher_report_models.dart';
import '../widgets/tr_format.dart';

/// Detailed feedback for one teacher over the span: header stats + a timeline of
/// every completed activity with its evaluations, notes and photo count.
class TeacherDayDetailView extends StatelessWidget {
  const TeacherDayDetailView({
    super.key,
    required this.data,
    required this.rangeLabel,
    required this.isDayMode,
  });

  final TeacherPerformance data;
  final String rangeLabel;
  final bool isDayMode;

  static const _accent = AppColors.activityBlue;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF6F8FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0.5,
          centerTitle: true,
          title: Text(
            data.name,
            style: context.typography.mdBold.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.textDefault,
            ),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                size: 18.sp, color: AppColors.textDefault),
            onPressed: Get.back,
          ),
        ),
        body: ListView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
          children: [
            _Header(data: data, rangeLabel: rangeLabel, accent: _accent),
            SizedBox(height: 20.h),
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: _accent,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  'tr_detail_timeline'.tr,
                  style: context.typography.mdBold.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDefault,
                  ),
                ),
              ],
            ),
            SizedBox(height: 14.h),
            ..._buildTimeline(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTimeline() {
    final widgets = <Widget>[];
    String? lastDay;
    for (final a in data.activities) {
      final d = DateTime.fromMillisecondsSinceEpoch(a.startedAt);
      final dayKey = '${d.year}-${d.month}-${d.day}';
      if (!isDayMode && dayKey != lastDay) {
        if (widgets.isNotEmpty) widgets.add(SizedBox(height: 8.h));
        widgets.add(_DayDivider(label: trDayLabel(d)));
        widgets.add(SizedBox(height: 12.h));
        lastDay = dayKey;
      }
      widgets.add(_ActivityCard(activity: a, accent: _accent));
      widgets.add(SizedBox(height: 12.h));
    }
    return widgets;
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.data, required this.rangeLabel, required this.accent});
  final TeacherPerformance data;
  final String rangeLabel;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22.r),
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [accent, Color.lerp(accent, Colors.black, 0.3)!],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                backgroundImage: (data.photo != null && data.photo!.isNotEmpty)
                    ? appCachedImageProvider(data.photo!)
                    : null,
                child: (data.photo == null || data.photo!.isEmpty)
                    ? Text(
                        trInitial(data.name),
                        style: context.typography.xlBold.copyWith(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: context.typography.mdBold.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      data.classroomNames.isEmpty
                          ? rangeLabel
                          : '${data.classroomNames.join(' · ')} · $rangeLabel',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.smSemiBold.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.16)),
          SizedBox(height: 14.h),
          Row(
            children: [
              _Stat(value: '${data.sessionCount}', labelKey: 'tr_metric_sessions'),
              _div(),
              _Stat(
                  value: trDuration(data.workingMinutes),
                  labelKey: 'tr_metric_time'),
              _div(),
              _Stat(value: '${data.workingDays}', labelKey: 'tr_metric_days'),
              _div(),
              _Stat(
                  value: '${data.evaluationCount}', labelKey: 'tr_metric_evals'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _div() => Container(
      width: 1, height: 30.h, color: Colors.white.withValues(alpha: 0.16));
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.labelKey});
  final String value;
  final String labelKey;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: context.typography.displaySmBold.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            labelKey.tr,
            style: context.typography.smSemiBold.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayDivider extends StatelessWidget {
  const _DayDivider({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: context.typography.displaySmBold.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondaryParagraph,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(child: Container(height: 1, color: const Color(0xFFE6EAF0))),
      ],
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({required this.activity, required this.accent});
  final ClassroomActivityModel activity;
  final Color accent;

  ({int excellent, int follow, int attention}) get _evalCounts {
    var e = 0, f = 0, a = 0;
    for (final v in activity.evaluations.values) {
      switch (EvalLevel.fromKey(v)) {
        case EvalLevel.excellent:
          e++;
          break;
        case EvalLevel.needsFollow:
          f++;
          break;
        case EvalLevel.needsAttention:
          a++;
          break;
      }
    }
    return (excellent: e, follow: f, attention: a);
  }

  int get _minutes {
    final end = activity.endedAt ?? activity.startedAt;
    return ((end - activity.startedAt) / 60000).round().clamp(0, 1 << 30);
  }

  @override
  Widget build(BuildContext context) {
    final counts = _evalCounts;
    final note = activity.groupNote?.trim();
    final childNotes = activity.notes.length;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFFEDF0F4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(9.w),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(Icons.auto_awesome_rounded, size: 18.sp, color: accent),
              ),
              SizedBox(width: 11.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.displaySmBold.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDefault,
                      ),
                    ),
                    if ((activity.subjectName ?? '').isNotEmpty)
                      Text(
                        activity.subjectName!,
                        style: context.typography.smSemiBold.copyWith(
                          fontSize: 12,
                          color: AppColors.textSecondaryParagraph,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    trClock(activity.startedAt),
                    style: context.typography.displaySmBold.copyWith(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDefault,
                    ),
                  ),
                  Text(
                    trDuration(_minutes),
                    style: context.typography.smSemiBold.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (counts.excellent > 0)
                _Tag(
                  color: AppColors.activityGreen,
                  icon: Icons.circle,
                  label: '${counts.excellent} ${'tr_eval_excellent'.tr}',
                ),
              if (counts.follow > 0)
                _Tag(
                  color: AppColors.activityAmberBrand,
                  icon: Icons.circle,
                  label: '${counts.follow} ${'tr_eval_follow'.tr}',
                ),
              if (counts.attention > 0)
                _Tag(
                  color: AppColors.errorForeground,
                  icon: Icons.circle,
                  label: '${counts.attention} ${'tr_eval_attention'.tr}',
                ),
              if (activity.photos.isNotEmpty)
                _Tag(
                  color: AppColors.activityPurple,
                  icon: Icons.photo_camera_rounded,
                  label: '${activity.photos.length}',
                ),
              if (childNotes > 0)
                _Tag(
                  color: AppColors.activityBlue,
                  icon: Icons.sticky_note_2_rounded,
                  label: '$childNotes ${'tr_tag_notes'.tr}',
                ),
            ],
          ),
          if (note != null && note.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(11.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8EC),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                note,
                style: context.typography.smSemiBold.copyWith(
                  fontSize: 12.5,
                  height: 1.5,
                  color: const Color(0xFF8A5A00),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.color, required this.icon, required this.label});
  final Color color;
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(9.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: color),
          SizedBox(width: 5.w),
          Text(
            label,
            style: context.typography.displaySmBold.copyWith(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

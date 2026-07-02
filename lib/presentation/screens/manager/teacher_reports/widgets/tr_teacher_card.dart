import '../../../../../index/index_main.dart';
import '../models/teacher_report_models.dart';
import 'tr_format.dart';

/// Per-teacher summary card: avatar, classrooms, key metrics, optional span
/// sparkline. Tappable into the detailed feedback timeline when active.
class TrTeacherCard extends StatelessWidget {
  const TrTeacherCard({
    super.key,
    required this.data,
    required this.accent,
    required this.showSparkline,
    required this.onTap,
  });

  final TeacherPerformance data;
  final Color accent;
  final bool showSparkline;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final idle = !data.hasActivity;
    return Opacity(
      opacity: idle ? 0.62 : 1,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        child: InkWell(
          onTap: idle ? null : onTap,
          borderRadius: BorderRadius.circular(20.r),
          child: Container(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 12.w, 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: const Color(0xFFEDF0F4)),
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Avatar(name: data.name, photo: data.photo, accent: accent),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.typography.displaySmBold.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDefault,
                            ),
                          ),
                          SizedBox(height: 3.h),
                          Text(
                            idle
                                ? 'tr_no_activity'.tr
                                : (data.classroomNames.isEmpty
                                    ? 'tr_role_teacher'.tr
                                    : data.classroomNames.join(' · ')),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.typography.smSemiBold.copyWith(
                              fontSize: 12,
                              color: AppColors.textSecondaryParagraph,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!idle)
                      Icon(Icons.chevron_right_rounded,
                          color: AppColors.textSecondaryParagraph, size: 24.sp),
                  ],
                ),
                if (!idle) ...[
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      _Metric(
                        icon: Icons.play_circle_outline_rounded,
                        value: '${data.sessionCount}',
                        labelKey: 'tr_metric_sessions',
                        color: accent,
                      ),
                      _Metric(
                        icon: Icons.timer_outlined,
                        value: trDuration(data.workingMinutes),
                        labelKey: 'tr_metric_time',
                        color: AppColors.activityBlue,
                      ),
                      _Metric(
                        icon: Icons.event_available_rounded,
                        value: '${data.workingDays}',
                        labelKey: 'tr_metric_days',
                        color: AppColors.activityPurple,
                      ),
                      _Metric(
                        icon: Icons.verified_outlined,
                        value: '${data.evaluationCount}',
                        labelKey: 'tr_metric_evals',
                        color: AppColors.activityGreen,
                      ),
                    ],
                  ),
                  if (showSparkline && data.dailyCounts.length > 1) ...[
                    SizedBox(height: 14.h),
                    _Sparkline(counts: data.dailyCounts, color: accent),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.photo, required this.accent});
  final String name;
  final String? photo;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    if (photo != null && photo!.isNotEmpty) {
      return CircleAvatar(radius: 24, backgroundImage: appCachedImageProvider(photo!));
    }
    return Container(
      width: 48.w,
      height: 48.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: accent.withValues(alpha: 0.12),
      ),
      child: Text(
        trInitial(name),
        style: context.typography.lgBold.copyWith(
          fontSize: 19,
          fontWeight: FontWeight.w900,
          color: accent,
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.icon,
    required this.value,
    required this.labelKey,
    required this.color,
  });
  final IconData icon;
  final String value;
  final String labelKey;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(height: 5.h),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.typography.displaySmBold.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: AppColors.textDefault,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            labelKey.tr,
            style: context.typography.smSemiBold.copyWith(
              fontSize: 10,
              color: AppColors.textSecondaryParagraph,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tiny per-day activity bars across the span (oldest → newest).
class _Sparkline extends StatelessWidget {
  const _Sparkline({required this.counts, required this.color});
  final List<int> counts;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final maxV = counts.fold<int>(1, (a, b) => b > a ? b : a);
    return SizedBox(
      height: 30.h,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < counts.length; i++) ...[
            Expanded(
              child: Container(
                height: counts[i] == 0 ? 4.h : 4.h + 26.h * (counts[i] / maxV),
                decoration: BoxDecoration(
                  color: counts[i] == 0
                      ? const Color(0xFFEAEEF3)
                      : color.withValues(alpha: 0.55 + 0.45 * (counts[i] / maxV)),
                  borderRadius: BorderRadius.circular(3.r),
                ),
              ),
            ),
            if (i != counts.length - 1) SizedBox(width: 3.w),
          ],
        ],
      ),
    );
  }
}

import '../../../../../../index/index_main.dart';
import '../../../teacher_reports/widgets/tr_format.dart';

/// One activity row in the teacher's day timeline. Shows what was taught, in
/// which class, when, and — for the running one — a live "in progress" badge.
class TtActivityCard extends StatelessWidget {
  const TtActivityCard({
    super.key,
    required this.activity,
    required this.className,
    required this.accent,
  });

  final ClassroomActivityModel activity;
  final String className;
  final Color accent;

  int get _minutes {
    final end = activity.endedAt ?? activity.startedAt;
    return ((end - activity.startedAt) / 60000).round().clamp(0, 1 << 30);
  }

  @override
  Widget build(BuildContext context) {
    final subject = (activity.subjectName ?? '').trim();
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: activity.isActive
              ? accent.withValues(alpha: 0.45)
              : AppColors.chartTrack,
        ),
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
                child: Icon(Icons.auto_awesome_rounded,
                    size: 18.sp, color: accent),
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
                      style: context.typography.smSemiBold.copyWith(
                        color: AppColors.textDefault,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subject.isEmpty ? className : '$subject · $className',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.typography.xsRegular.copyWith(
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              activity.isActive
                  ? _liveBadge(context)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          trClock(activity.startedAt),
                          style: context.typography.xsMedium.copyWith(
                            color: AppColors.textDefault,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          trDuration(_minutes),
                          style: context.typography.xsRegular.copyWith(
                            color: AppColors.textSecondaryParagraph,
                          ),
                        ),
                      ],
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _liveBadge(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: AppColors.activityGreen.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            decoration: const BoxDecoration(
              color: AppColors.activityGreen,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 5.w),
          Text(
            'live_teaching_in_progress'.tr,
            style: context.typography.xsMedium.copyWith(
              color: AppColors.activityGreen,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

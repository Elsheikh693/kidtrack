import '../../../../../index/index_main.dart';

/// Empty state for the manager schedule editor — either no classrooms exist yet
/// or the selected classroom/day has no slots.
class ManagerScheduleEmpty extends StatelessWidget {
  const ManagerScheduleEmpty({super.key, this.noClassrooms = false});

  final bool noClassrooms;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                color: AppColors.activityBlue.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                noClassrooms
                    ? Icons.meeting_room_outlined
                    : Icons.event_note_rounded,
                size: 44.sp,
                color: AppColors.activityBlue,
              ),
            ),
            SizedBox(height: 18.h),
            Text(
              noClassrooms
                  ? 'schedule_no_classrooms'.tr
                  : 'schedule_empty_day'.tr,
              textAlign: TextAlign.center,
              style: context.typography.smSemiBold
                  .copyWith(color: AppColors.textDefault),
            ),
            if (!noClassrooms) ...[
              SizedBox(height: 6.h),
              Text(
                'schedule_empty_hint'.tr,
                textAlign: TextAlign.center,
                style: context.typography.xsRegular
                    .copyWith(color: AppColors.textSecondaryParagraph),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

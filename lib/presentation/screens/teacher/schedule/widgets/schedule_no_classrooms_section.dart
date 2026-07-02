import '../../../../../index/index_main.dart';

class ScheduleNoClassroomsSection extends StatelessWidget {
  const ScheduleNoClassroomsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.activityMuted.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.class_rounded,
                color: AppColors.activityMuted,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'teacher_schedule_no_classrooms'.tr,
              style: context.typography.smSemiBold
                  .copyWith(color: AppColors.activitySlate),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'teacher_schedule_no_classrooms_hint'.tr,
              style: context.typography.xsRegular
                  .copyWith(color: AppColors.activityMuted),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

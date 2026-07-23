import '../../../../../index/index_main.dart';

/// Horizontal weekday picker (Saturday → Friday) for the selected classroom.
class ScheduleDayBar extends StatelessWidget {
  const ScheduleDayBar({super.key, required this.controller});

  final ManagerScheduleController controller;

  @override
  Widget build(BuildContext context) {
    final today = ManagerScheduleController.todayKey;
    return SizedBox(
      height: 46.h,
      child: Obx(() {
        final selected = controller.selectedDay.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          itemCount: ManagerScheduleController.days.length,
          separatorBuilder: (_, _) => SizedBox(width: 6.w),
          itemBuilder: (_, i) {
            final day = ManagerScheduleController.days[i];
            final isActive = day == selected;
            final isToday = day == today;
            return GestureDetector(
              onTap: () => controller.selectDay(day),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.activityBlue
                      : AppColors.backgroundNeutralDefault,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isToday) ...[
                      Container(
                        width: 5.w,
                        height: 5.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? AppColors.white
                              : AppColors.activityGreen,
                        ),
                      ),
                      SizedBox(width: 5.w),
                    ],
                    Text(
                      'schedule_day_$day'.tr,
                      style: context.typography.smMedium.copyWith(
                        color: isActive
                            ? AppColors.white
                            : AppColors.textSecondaryParagraph,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

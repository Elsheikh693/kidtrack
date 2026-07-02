import '../../../../../index/index_main.dart';

class ScheduleFilterBar extends StatelessWidget {
  const ScheduleFilterBar({super.key, required this.controller});

  final TeacherWeeklyScheduleController controller;

  @override
  Widget build(BuildContext context) {
    final today = TeacherWeeklyScheduleController.todayKey;
    return Container(
      color: AppColors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Obx(() {
              final selected = controller.selectedDay.value;
              return SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: TeacherWeeklyScheduleController.days.length,
                  separatorBuilder: (ctx, i) => const SizedBox(width: 8),
                  itemBuilder: (ctx, i) {
                    final day = TeacherWeeklyScheduleController.days[i];
                    final isSel = day == selected;
                    final isToday = day == today;
                    return GestureDetector(
                      onTap: () => controller.selectDay(day),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isSel
                              ? AppColors.activityGreen
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSel
                                ? AppColors.activityGreen
                                : isToday
                                    ? AppColors.activityGreen
                                    : const Color(0xFFE2E8F0),
                            width: isToday && !isSel ? 1.5 : 1.0,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isToday && !isSel)
                              Padding(
                                padding:
                                    const EdgeInsetsDirectional.only(end: 5),
                                child: Container(
                                  width: 5,
                                  height: 5,
                                  decoration: BoxDecoration(
                                    color: AppColors.activityGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            Text(
                              'schedule_day_$day'.tr,
                              style: ctx.typography.smRegular.copyWith(
                                color: isSel
                                    ? AppColors.white
                                    : AppColors.activityMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
          Obx(() {
            if (controller.myClassrooms.length <= 1) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderNeutralPrimary),
                ),
                child: DropdownButton<ClassroomModel>(
                  value: controller.selectedClassroom.value,
                  isExpanded: true,
                  underline: const SizedBox(),
                  style: context.typography.smMedium
                      .copyWith(color: AppColors.activitySlate),
                  dropdownColor: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.activityMuted,
                  ),
                  items: controller.myClassrooms
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Row(
                            children: [
                              const Icon(
                                Icons.class_rounded,
                                size: 16,
                                color: AppColors.activityBlue,
                              ),
                              const SizedBox(width: 8),
                              Text(c.name),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) controller.selectClassroom(v);
                  },
                ),
              ),
            );
          }),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
        ],
      ),
    );
  }
}

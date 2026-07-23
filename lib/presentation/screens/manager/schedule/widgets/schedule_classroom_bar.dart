import '../../../../../index/index_main.dart';

/// Horizontal classroom picker — the manager builds a separate timetable per
/// classroom, so this scopes everything below it to one classroom.
class ScheduleClassroomBar extends StatelessWidget {
  const ScheduleClassroomBar({super.key, required this.controller});

  final ManagerScheduleController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46.h,
      child: Obx(() {
        final classrooms = controller.classrooms;
        final selected = controller.selectedClassroom.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
          itemCount: classrooms.length,
          separatorBuilder: (_, _) => SizedBox(width: 8.w),
          itemBuilder: (_, i) {
            final c = classrooms[i];
            final isActive = c.key == selected?.key;
            return GestureDetector(
              onTap: () => controller.selectClassroom(c),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.activityBlue
                      : AppColors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(
                    color: isActive
                        ? AppColors.activityBlue
                        : AppColors.borderNeutralPrimary,
                  ),
                ),
                child: Text(
                  c.name,
                  style: context.typography.smMedium.copyWith(
                    color: isActive ? AppColors.white : AppColors.textDefault,
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

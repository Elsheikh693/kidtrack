import '../../../../../index/index_main.dart';

class IdleClassroomSection extends StatelessWidget {
  const IdleClassroomSection({super.key, required this.ctrl});

  final TeacherActivityController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final classrooms = ctrl.myClassrooms;
      if (classrooms.length <= 1) return const SizedBox.shrink();
      return Container(
        color: AppColors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                physics: const BouncingScrollPhysics(),
                children: classrooms.map((c) {
                  return Obx(() {
                    final isActive =
                        ctrl.selectedClassroomId.value == c.key;
                    final count = ctrl.children
                        .where((ch) => ch.classroomId == c.key)
                        .length;
                    return GestureDetector(
                      onTap: () => ctrl.setActiveClassroom(c.key ?? ''),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.activityGreen
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive
                                ? AppColors.activityGreen
                                : AppColors.borderNeutralPrimary
                                    .withValues(alpha: 0.6),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              c.name,
                              style: context.typography.smSemiBold.copyWith(
                                color: isActive
                                    ? AppColors.white
                                    : AppColors.textSecondaryParagraph,
                              ),
                            ),
                            if (count > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.white.withValues(alpha: 0.2)
                                      : AppColors.activityGreen
                                          .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '$count',
                                  style: context.typography.xsMedium.copyWith(
                                    color: isActive
                                        ? AppColors.white
                                        : AppColors.activityGreen,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  });
                }).toList(),
              ),
            ),
            Container(
              height: 1,
              color: AppColors.borderNeutralPrimary.withValues(alpha: 0.15),
            ),
          ],
        ),
      );
    });
  }
}

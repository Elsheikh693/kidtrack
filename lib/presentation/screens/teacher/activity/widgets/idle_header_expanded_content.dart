import '../../../../../index/index_main.dart';
import 'idle_classroom_chip.dart';

class IdleHeaderExpandedContent extends StatelessWidget {
  const IdleHeaderExpandedContent({super.key, required this.ctrl});
  final TeacherActivityController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final classrooms = ctrl.myClassrooms;
      final active = ctrl.activeActivity.value;
      final subtitle = active != null
          ? 'نشاط جارٍ: ${active.title}'
          : 'teacher_activity_no_active'.tr;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.play_circle_rounded,
                  color: AppColors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'teacher_tab_activities'.tr,
                      style: context.typography.xlBold
                          .copyWith(color: AppColors.white, height: 1.1),
                    ),
                    Text(
                      subtitle,
                      style: context.typography.xsRegular.copyWith(
                          color: AppColors.white.withValues(alpha: 0.75)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (classrooms.length > 1) ...[
            const SizedBox(height: 14),
            SizedBox(
              height: 46,
              child: ListView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                physics: const BouncingScrollPhysics(),
                children: classrooms
                    .map((c) => Obx(() => IdleClassroomChip(
                          classroom: c,
                          isActive:
                              ctrl.selectedClassroomId.value == c.key,
                          studentCount: ctrl.children
                              .where((ch) => ch.classroomId == c.key)
                              .length,
                          onTap: () =>
                              ctrl.setActiveClassroom(c.key ?? ''),
                        )))
                    .toList(),
              ),
            ),
          ] else if (classrooms.length == 1) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.school_rounded,
                          color: AppColors.white, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        classrooms.first.name,
                        style: context.typography.smMedium
                            .copyWith(color: AppColors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      );
    });
  }
}

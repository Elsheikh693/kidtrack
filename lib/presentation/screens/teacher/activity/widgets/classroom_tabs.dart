import '../../../../../index/index_main.dart';

/// Classroom switcher — floating pills. A single classroom hides it. Selecting a
/// pill switches the day shown below it.
class ClassroomTabs extends StatelessWidget {
  const ClassroomTabs({super.key, required this.ctrl});

  final TeacherActivityController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final classrooms = ctrl.myClassrooms;
      if (classrooms.length <= 1) return const SizedBox.shrink();
      return SizedBox(
        height: 54.h,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 4.h),
          physics: const BouncingScrollPhysics(),
          itemCount: classrooms.length,
          separatorBuilder: (_, _) => SizedBox(width: 10.w),
          itemBuilder: (_, i) => _Pill(ctrl: ctrl, classroom: classrooms[i]),
        ),
      );
    });
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.ctrl, required this.classroom});

  final TeacherActivityController ctrl;
  final ClassroomModel classroom;

  static const _accent = AppColors.activityGreen;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isActive = ctrl.selectedClassroomId.value == classroom.key;
      final count = ctrl.children
          .where((ch) => ch.classroomId == classroom.key)
          .length;
      return GestureDetector(
        onTap: () {
          if (isActive) return;
          HapticFeedback.selectionClick();
          ctrl.setActiveClassroom(classroom.key ?? '');
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: 22.w),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? _accent : AppColors.white,
            borderRadius: BorderRadius.circular(26.r),
            border: Border.all(
              color: isActive
                  ? _accent
                  : AppColors.borderNeutralPrimary.withValues(alpha: 0.7),
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: _accent.withValues(alpha: 0.30),
                      blurRadius: 12.r,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                classroom.name,
                style: context.typography.smSemiBold.copyWith(
                  color: isActive ? AppColors.white : AppColors.textDefault,
                ),
              ),
              if (isActive && count > 0) ...[
                SizedBox(width: 6.w),
                Container(
                  constraints: BoxConstraints(minWidth: 18.w),
                  height: 18.w,
                  alignment: Alignment.center,
                  padding: EdgeInsets.symmetric(horizontal: 5.w),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Text(
                    '$count',
                    style: context.typography.xsMedium
                        .copyWith(color: AppColors.white),
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}

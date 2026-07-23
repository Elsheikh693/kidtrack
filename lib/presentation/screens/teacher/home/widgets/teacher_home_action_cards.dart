import '../../../../../index/index_main.dart';
import '../../activity/widgets/start_activity_sheet.dart';

/// Quick-action grid on the teacher home, three-per-row (mirrors the reception
/// home): child states, evaluation levels, subjects, activity log, learn the
/// app, and — the primary action — start a new activity, which opens the
/// start-activity sheet right here instead of switching to the Activities tab.
class TeacherHomeActionCards extends StatelessWidget {
  const TeacherHomeActionCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.groups_rounded,
                  title: 'teacher_action_start_class'.tr,
                  subtitle: 'teacher_action_start_class_sub'.tr,
                  colors: const [Color(0xFFF59E0B), Color(0xFFEA580C)],
                  onTap: () => _startActivity(context, mode: 'class'),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ActionCard(
                  icon: Icons.auto_awesome_rounded,
                  title: 'teacher_action_start_activity'.tr,
                  subtitle: 'teacher_action_start_activity_sub'.tr,
                  colors: const [Color(0xFFF43F5E), Color(0xFFE11D48)],
                  onTap: () => _startActivity(context, mode: 'activity'),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ActionCard(
                  icon: Icons.star_rounded,
                  title: 'teacher_action_eval_levels'.tr,
                  subtitle: 'teacher_action_eval_levels_sub'.tr,
                  colors: const [Color(0xFF16A34A), Color(0xFF15803D)],
                  onTap: () => Get.toNamed(evalLevelsView),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.fact_check_rounded,
                  title: 'teacher_action_assessments'.tr,
                  subtitle: 'teacher_action_assessments_sub'.tr,
                  colors: const [Color(0xFF7C3AED), Color(0xFF6D28D9)],
                  onTap: () => Get.toNamed(evaluationReasonsView),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ActionCard(
                  icon: Icons.history_rounded,
                  title: 'teacher_action_activity_log'.tr,
                  subtitle: 'teacher_action_activity_log_sub'.tr,
                  colors: const [Color(0xFF4F46E5), Color(0xFF4338CA)],
                  onTap: () => Get.find<MainPageViewModel>().changePage(2),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ActionCard(
                  icon: Icons.emoji_emotions_rounded,
                  title: 'teacher_action_child_states'.tr,
                  subtitle: 'teacher_action_child_states_sub'.tr,
                  colors: const [Color(0xFF0891B2), Color(0xFF0E7490)],
                  onTap: () => Get.toNamed(childStatesView),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.h),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _ActionCard(
                  icon: Icons.assignment_turned_in_rounded,
                  title: 'teacher_action_quizzes'.tr,
                  subtitle: 'teacher_action_quizzes_sub'.tr,
                  colors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
                  onTap: () => Get.toNamed(teacherAssessmentsView),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _ActionCard(
                  icon: Icons.history_edu_rounded,
                  title: 'teacher_action_exams'.tr,
                  subtitle: 'teacher_action_exams_sub'.tr,
                  colors: const [Color(0xFF0D9488), Color(0xFF0F766E)],
                  onTap: () => _openExams(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Exams live per-classroom. Pick the teacher's class first (or jump straight
  /// in when they lead only one), then open its exams screen.
  Future<void> _openExams(BuildContext context) async {
    final ctrl = Get.find<TeacherActivityController>();
    Loader.show();
    await ctrl.ensureLoaded();
    Loader.dismiss();
    final classes = ctrl.myClassrooms;
    if (classes.isEmpty) {
      Loader.showError('teacher_action_exams_no_class'.tr);
      return;
    }
    if (classes.length == 1) {
      _goToExams(classes.first);
      return;
    }
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ExamClassPicker(classes: classes, onPick: _goToExams),
    );
  }

  void _goToExams(ClassroomModel c) {
    Get.to(
      () => const ClassroomExamsView(),
      arguments: {'classroomId': c.key, 'classroomName': c.name},
      transition: Transition.rightToLeft,
    );
  }

  /// Opens the start-activity sheet directly on the home — ensures the activity
  /// controller has loaded its classrooms/subjects first (it may have just been
  /// created), so the pickers are never empty.
  Future<void> _startActivity(
    BuildContext context, {
    required String mode,
  }) async {
    final ctrl = Get.find<TeacherActivityController>();
    Loader.show();
    await ctrl.ensureLoaded();
    Loader.dismiss();
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StartActivitySheet(
        ctrl: ctrl,
        mode: mode,
        subjects: ctrl.subjects,
        classrooms: ctrl.myClassrooms,
        defaultClassroomId: ctrl.activeClassroomId.isNotEmpty
            ? ctrl.activeClassroomId
            : null,
        onStart: (title, subjectId, subjectName, classroomId, childIds) {
          ctrl.startActivity(
            title: title,
            subjectId: subjectId,
            subjectName: subjectName,
            classroomId: classroomId,
            mode: mode,
            childIds: childIds,
          );
          // Started from the home card — jump to the Activities tab so the
          // teacher lands on the running activity, not back on the home.
          Get.find<MainPageViewModel>().changePage(1);
        },
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> colors;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.colors,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.3),
              blurRadius: 14.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40.w,
              height: 40.h,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: Colors.white, size: 20.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.mdBold.copyWith(
                color: Colors.white,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.typography.xsMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 10.5,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bottom sheet that lets the teacher choose which of their classes to open the
/// exams screen for (shown only when they lead more than one class).
class _ExamClassPicker extends StatelessWidget {
  final List<ClassroomModel> classes;
  final ValueChanged<ClassroomModel> onPick;

  const _ExamClassPicker({required this.classes, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text('teacher_action_exams_pick_class'.tr,
                style: context.typography.mdBold
                    .copyWith(color: const Color(0xFF1E293B))),
            SizedBox(height: 12.h),
            for (final c in classes)
              GestureDetector(
                onTap: () {
                  Get.back<void>();
                  onPick(c);
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.meeting_room_rounded,
                          color: Color(0xFF0D9488), size: 20),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(c.name,
                            style: context.typography.smSemiBold
                                .copyWith(color: const Color(0xFF1E293B))),
                      ),
                      const Icon(Icons.arrow_forward_ios_outlined,
                          size: 13, color: Color(0xFF94A3B8)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

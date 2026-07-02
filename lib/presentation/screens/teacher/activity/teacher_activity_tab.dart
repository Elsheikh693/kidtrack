import '../../../../index/index_main.dart';
import 'widgets/start_activity_sheet.dart';
import 'widgets/activity_end_sheet.dart';
import 'widgets/active_activity_view.dart';
import 'widgets/idle_activity_view.dart';
import 'widgets/activity_shimmer.dart';

class TeacherActivityTab extends StatefulWidget {
  const TeacherActivityTab({super.key});

  @override
  State<TeacherActivityTab> createState() => _TeacherActivityTabState();
}

class _TeacherActivityTabState extends State<TeacherActivityTab> {
  late final TeacherActivityController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.find<TeacherActivityController>();
  }

  void _showStartSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StartActivitySheet(
        ctrl: _ctrl,
        subjects: _ctrl.subjects,
        classrooms: _ctrl.myClassrooms,
        defaultClassroomId: _ctrl.activeClassroomId.isNotEmpty
            ? _ctrl.activeClassroomId
            : null,
        onStart: (title, subjectId, subjectName, classroomId) =>
            _ctrl.startActivity(
              title: title,
              subjectId: subjectId,
              subjectName: subjectName,
              classroomId: classroomId,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (_ctrl.isLoading.value) {
        return CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            TeacherClassicAppBar(title: 'teacher_tab_activities'.tr),
            const SliverToBoxAdapter(child: ActivityShimmer()),
          ],
        );
      }
      final active = _ctrl.activeActivity.value;
      if (active != null) {
        return ActiveActivityView(
          ctrl: _ctrl,
          activity: active,
          onEnd: () => showActivityEndSheet(context, _ctrl),
        );
      }
      return IdleActivityView(ctrl: _ctrl, onStart: _showStartSheet);
    });
  }
}

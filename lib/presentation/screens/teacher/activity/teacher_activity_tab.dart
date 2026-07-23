import '../../../../index/index_main.dart';
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
      return IdleActivityView(ctrl: _ctrl);
    });
  }
}

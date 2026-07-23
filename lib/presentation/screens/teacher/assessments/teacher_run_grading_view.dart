import '../../../../index/index_main.dart';
import 'widgets/grade_child_tile.dart';

/// Child list for one run — the teacher taps a child to grade them.
class TeacherRunGradingView extends StatefulWidget {
  const TeacherRunGradingView({super.key});

  @override
  State<TeacherRunGradingView> createState() => _TeacherRunGradingViewState();
}

class _TeacherRunGradingViewState extends State<TeacherRunGradingView> {
  late final TeacherRunGradingController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TeacherRunGradingController>();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: controller.run.value?.title ?? 'assessment_runs_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.rows.isEmpty) {
            return Center(
              child: Text('assessment_grade_no_children'.tr,
                  style: context.typography.mdRegular
                      .copyWith(color: const Color(0xFF94A3B8))),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: controller.rows.length,
            itemBuilder: (_, i) {
              final row = controller.rows[i];
              return GradeChildTile(
                name: controller.childName(row.childId),
                imageUrl: controller.childImage(row.childId),
                row: row,
                onTap: () => controller.openGrade(row.childId),
              );
            },
          );
        }),
      ),
    );
  }
}

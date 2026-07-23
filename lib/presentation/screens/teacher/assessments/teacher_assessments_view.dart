import '../../../../index/index_main.dart';
import 'widgets/teacher_assessment_run_card.dart';

class TeacherAssessmentsView extends StatefulWidget {
  const TeacherAssessmentsView({super.key});

  @override
  State<TeacherAssessmentsView> createState() => _TeacherAssessmentsViewState();
}

class _TeacherAssessmentsViewState extends State<TeacherAssessmentsView> {
  late final TeacherAssessmentsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<TeacherAssessmentsController>();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'assessment_runs_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.runs.isEmpty) {
            return _empty(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: controller.runs.length,
            itemBuilder: (_, i) {
              final run = controller.runs[i];
              final (graded, total) = controller.progressFor(run.key ?? '');
              return TeacherAssessmentRunCard(
                run: run,
                graded: graded,
                total: total,
                onTap: () => controller.openRun(run),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _empty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.grading_outlined,
                size: 44, color: Color(0xFF4F46E5)),
          ),
          const SizedBox(height: 16),
          Text('assessment_teacher_empty'.tr,
              style: context.typography.mdRegular
                  .copyWith(color: const Color(0xFF94A3B8))),
          const SizedBox(height: 6),
          Text('assessment_teacher_empty_sub'.tr,
              style: context.typography.xsRegular
                  .copyWith(color: const Color(0xFFCBD5E1)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

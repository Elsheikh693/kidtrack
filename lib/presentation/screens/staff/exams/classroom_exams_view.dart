import '../../../../index/index_main.dart';
import '../../shared/assessment/assessment_list_shimmer.dart';
import 'classroom_exams_controller.dart';
import 'grading/exam_grading_view.dart';
import 'widgets/exam_list_card.dart';
import 'widgets/exams_empty.dart';
import 'widgets/new_exam_sheet.dart';

/// Per-classroom exams list for staff (teacher + manager). Opened via
/// `Get.to(() => const ClassroomExamsView(), arguments: {classroomId, classroomName})`.
class ClassroomExamsView extends StatelessWidget {
  const ClassroomExamsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ClassroomExamsController>(
      init: ClassroomExamsController(),
      builder: (controller) => Directionality(
        textDirection: appTextDirection,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: HomeAppBar(
            title: controller.classroomName.isEmpty
                ? 'exams_title'.tr
                : '${'exams_title'.tr} — ${controller.classroomName}',
            showNotificationDot: false,
            showFilterIcon: false,
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            onPressed: () => _openNewExam(context, controller),
            icon: const Icon(Icons.add_rounded, color: Colors.white),
            label: AppText(
              text: 'exam_new'.tr,
              textStyle: context.typography.smSemiBold
                  .copyWith(color: AppColors.white),
            ),
          ),
          body: Obx(() {
            if (controller.isLoading.value && controller.exams.isEmpty) {
              return const AssessmentListShimmer();
            }
            if (controller.exams.isEmpty) {
              return const ExamsEmpty();
            }
            return ListView.separated(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 96.h),
              itemCount: controller.exams.length,
              separatorBuilder: (_, i) => SizedBox(height: 12.h),
              itemBuilder: (_, i) {
                final exam = controller.exams[i];
                return ExamListCard(
                  exam: exam,
                  gradedCount: controller.gradedCounts[exam.key] ?? 0,
                  rosterSize: controller.rosterSize.value,
                  onTap: () => Get.to(
                    () => const ExamGradingView(),
                    arguments: {'exam': exam},
                    transition: Transition.rightToLeft,
                  )?.then((_) => controller.load()),
                  onDelete: () => controller.deleteExam(exam.key ?? ''),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  void _openNewExam(
    BuildContext context,
    ClassroomExamsController controller,
  ) {
    Get.bottomSheet(
      NewExamSheet(
        classroomName: controller.classroomName,
        onSubmit: (subject, title, date) => controller.createExam(
          subject: subject,
          title: title,
          date: date,
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

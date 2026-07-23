import '../../../../../index/index_main.dart';
import 'exam_grading_controller.dart';
import 'widgets/grading_child_card.dart';

/// Grading screen for one exam: the classroom roster, each child graded
/// independently. Opened via
/// `Get.to(() => const ExamGradingView(), arguments: {exam})`.
class ExamGradingView extends StatelessWidget {
  const ExamGradingView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ExamGradingController>(
      init: ExamGradingController(),
      builder: (controller) => Directionality(
        textDirection: appTextDirection,
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: HomeAppBar(
            title: controller.exam.title.trim().isNotEmpty
                ? controller.exam.title
                : controller.exam.subjectName,
            showNotificationDot: false,
            showFilterIcon: false,
          ),
          body: Obx(() {
            if (controller.isLoading.value && controller.children.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.children.isEmpty) {
              return Center(
                child: AppText(
                  text: 'exam_no_children'.tr,
                  textStyle: context.typography.smRegular
                      .copyWith(color: AppColors.textSecondaryParagraph),
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
              itemCount: controller.children.length + 1,
              itemBuilder: (_, i) {
                if (i == 0) return _header(context, controller);
                final child = controller.children[i - 1];
                return GradingChildCard(
                  key: ValueKey(child.key),
                  child: child,
                  existing: controller.existingFor(child.key ?? ''),
                  onSave: (grade, file, existingUrl, note) =>
                      controller.saveResult(
                    child: child,
                    grade: grade,
                    paperFile: file,
                    existingPaperUrl: existingUrl,
                    note: note,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, ExamGradingController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          Icon(Icons.groups_rounded, size: 18.r, color: AppColors.primary),
          SizedBox(width: 8.w),
          AppText(
            text:
                '${controller.gradedCount}/${controller.children.length} ${'exam_graded_suffix'.tr}',
            textStyle: context.typography.smSemiBold
                .copyWith(color: AppColors.textPrimaryParagraph),
          ),
        ],
      ),
    );
  }
}

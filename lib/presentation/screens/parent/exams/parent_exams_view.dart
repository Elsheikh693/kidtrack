import '../../../../index/index_main.dart';
import '../education/widgets/journal_meta.dart';
import 'parent_exams_controller.dart';
import 'exam_result_detail_view.dart';
import 'widgets/exam_result_card.dart';

/// The active child's written-exam results, opened from the Link Book. Tapping a
/// result plays the celebratory reveal.
class ParentExamsView extends StatelessWidget {
  const ParentExamsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParentExamsController>(
      init: ParentExamsController(),
      builder: (controller) => Directionality(
        textDirection: appTextDirection,
        child: Scaffold(
          backgroundColor: kJBg,
          appBar: AppBar(
            backgroundColor: kJBg,
            surfaceTintColor: kJBg,
            elevation: 0,
            centerTitle: true,
            iconTheme: const IconThemeData(color: kJInk),
            title: Text(
              'exams_title'.tr,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: kJInk,
              ),
            ),
          ),
          body: Obx(() {
            if (controller.isLoading.value && controller.results.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.results.isEmpty) {
              return const _Empty();
            }
            return RefreshIndicator(
              onRefresh: controller.load,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                itemCount: controller.results.length,
                itemBuilder: (_, i) {
                  final result = controller.results[i];
                  return ExamResultCard(
                    result: result,
                    onTap: () => Get.to(
                      () => ExamResultDetailView(
                        result: result,
                        childName: controller.childName,
                        nurseryName: controller.nurseryName.value,
                        nurseryLogo: controller.nurseryLogo.value,
                      ),
                      fullscreenDialog: true,
                      transition: Transition.fadeIn,
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFF6C4DDB).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(Icons.assignment_rounded,
                  size: 44, color: Color(0xFF6C4DDB)),
            ),
            const SizedBox(height: 18),
            Text(
              'exam_parent_empty_title'.tr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: kJInk,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'exam_parent_empty_hint'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.6,
                fontWeight: FontWeight.w500,
                color: kJMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

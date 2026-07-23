import '../../../../index/index_main.dart';
import 'widgets/parent_assessment_card.dart';

class ParentAssessmentsView extends StatefulWidget {
  const ParentAssessmentsView({super.key});

  @override
  State<ParentAssessmentsView> createState() => _ParentAssessmentsViewState();
}

class _ParentAssessmentsViewState extends State<ParentAssessmentsView> {
  late final ParentAssessmentsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ParentAssessmentsController>();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'assessment_parent_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.rows.isEmpty) {
            return _empty(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            itemCount: controller.rows.length,
            itemBuilder: (_, i) {
              final row = controller.rows[i];
              final run = controller.runFor(row.runId);
              if (run == null) return const SizedBox.shrink();
              return ParentAssessmentCard(
                row: row,
                run: run,
                onTap: () => controller.openResult(row),
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
            child: const Icon(Icons.assignment_turned_in_outlined,
                size: 44, color: Color(0xFF4F46E5)),
          ),
          const SizedBox(height: 16),
          Text('assessment_parent_empty'.tr,
              style: context.typography.mdRegular
                  .copyWith(color: const Color(0xFF94A3B8))),
          const SizedBox(height: 6),
          Text('assessment_parent_empty_sub'.tr,
              style: context.typography.xsRegular
                  .copyWith(color: const Color(0xFFCBD5E1)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

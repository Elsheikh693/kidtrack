import '../../../../../index/index_main.dart';
import 'widgets/assessment_run_card.dart';
import 'widgets/run_template_picker_sheet.dart';

class AssessmentRunsView extends StatefulWidget {
  const AssessmentRunsView({super.key});

  @override
  State<AssessmentRunsView> createState() => _AssessmentRunsViewState();
}

class _AssessmentRunsViewState extends State<AssessmentRunsView> {
  late final AssessmentRunsController controller;

  static const _accent = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    controller = Get.find<AssessmentRunsController>();
  }

  void _openPicker() {
    Get.bottomSheet(
      RunTemplatePickerSheet(
        templates: controller.templates.toList(),
        onPick: (t) {
          Get.back();
          controller.openCreate(t);
        },
        onManageTemplates: () {
          Get.back();
          controller.openTemplates();
        },
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'assessment_runs_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
          // Gear opens the template library (manage reusable plans).
          onSettingsTap: controller.openTemplates,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _openPicker,
          backgroundColor: _accent,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text('assessment_run_new'.tr,
              style: context.typography.smSemiBold.copyWith(color: Colors.white)),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.items.isEmpty) {
            return _empty(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: controller.items.length,
            itemBuilder: (_, i) {
              final run = controller.items[i];
              return AssessmentRunCard(
                run: run,
                classesLabel: run.classroomIds
                    .map(controller.classroomName)
                    .where((n) => n.isNotEmpty)
                    .join('holidays16_list_separator'.tr),
                onPublish: () => controller.publish(run),
                onOpen: () => controller.openRun(run),
                onDelete: () => controller.deleteRun(run),
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
              color: _accent.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.assignment_outlined,
                size: 44, color: _accent),
          ),
          const SizedBox(height: 16),
          Text('assessment_runs_empty'.tr,
              style: context.typography.mdRegular
                  .copyWith(color: const Color(0xFF94A3B8))),
          const SizedBox(height: 6),
          Text('assessment_runs_empty_sub'.tr,
              style: context.typography.xsRegular
                  .copyWith(color: const Color(0xFFCBD5E1)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

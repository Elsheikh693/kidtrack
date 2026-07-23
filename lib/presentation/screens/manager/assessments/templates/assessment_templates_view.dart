import '../../../../../index/index_main.dart';
import 'widgets/assessment_template_card.dart';

class AssessmentTemplatesView extends StatefulWidget {
  const AssessmentTemplatesView({super.key});

  @override
  State<AssessmentTemplatesView> createState() =>
      _AssessmentTemplatesViewState();
}

class _AssessmentTemplatesViewState extends State<AssessmentTemplatesView> {
  late final AssessmentTemplatesController controller;

  static const _accent = Color(0xFF4F46E5);

  @override
  void initState() {
    super.initState();
    controller = Get.find<AssessmentTemplatesController>();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'assessment_templates_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: _accent,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'assessment_template_add'.tr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
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
            itemBuilder: (_, i) => AssessmentTemplateCard(
              item: controller.items[i],
              onEdit: () => controller.openEdit(controller.items[i]),
              onDelete: () => controller.delete(controller.items[i]),
            ),
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
            child: const Icon(Icons.description_outlined,
                size: 44, color: _accent),
          ),
          const SizedBox(height: 16),
          Text(
            'assessment_templates_empty'.tr,
            style: context.typography.mdRegular
                .copyWith(color: const Color(0xFF94A3B8)),
          ),
          const SizedBox(height: 6),
          Text(
            'assessment_templates_empty_sub'.tr,
            style: context.typography.xsRegular
                .copyWith(color: const Color(0xFFCBD5E1)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

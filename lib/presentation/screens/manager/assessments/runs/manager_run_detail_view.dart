import '../../../../../index/index_main.dart';
import 'widgets/manager_child_status_tile.dart';

/// Manager review of a run: a status summary, the child list, and a bulk
/// "publish all completed" action.
class ManagerRunDetailView extends StatefulWidget {
  const ManagerRunDetailView({super.key});

  @override
  State<ManagerRunDetailView> createState() => _ManagerRunDetailViewState();
}

class _ManagerRunDetailViewState extends State<ManagerRunDetailView> {
  late final ManagerRunDetailController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ManagerRunDetailController>();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: controller.run.value?.title ?? 'assessment_runs_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        floatingActionButton: Obx(() => controller.hasCompletedToPublish
            ? FloatingActionButton.extended(
                onPressed: controller.publishAllCompleted,
                backgroundColor: const Color(0xFF16A34A),
                icon: const Icon(Icons.publish_rounded, color: Colors.white),
                label: Text('assessment_publish_all'.tr,
                    style: context.typography.smSemiBold
                        .copyWith(color: Colors.white)),
              )
            : const SizedBox.shrink()),
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
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              _summary(context),
              const SizedBox(height: 16),
              for (final row in controller.rows)
                ManagerChildStatusTile(
                  name: controller.childName(row.childId),
                  imageUrl: controller.childImage(row.childId),
                  row: row,
                  onTap: () => controller.openChild(row),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _summary(BuildContext context) {
    Widget cell(String labelKey, int value, Color color) => Expanded(
          child: Column(
            children: [
              Text('$value',
                  style: context.typography.xlBold.copyWith(color: color)),
              const SizedBox(height: 2),
              Text(labelKey.tr,
                  style: context.typography.xsRegular
                      .copyWith(color: const Color(0xFF94A3B8)),
                  textAlign: TextAlign.center),
            ],
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          cell('assessment_summary_pending', controller.pendingCount,
              const Color(0xFF94A3B8)),
          cell('assessment_summary_completed', controller.completedCount,
              const Color(0xFFD97706)),
          cell('assessment_summary_published', controller.publishedCount,
              const Color(0xFF16A34A)),
        ],
      ),
    );
  }
}

import '../../../../index/index_main.dart';

class ChildStatesView extends StatefulWidget {
  const ChildStatesView({super.key});

  @override
  State<ChildStatesView> createState() => _ChildStatesViewState();
}

class _ChildStatesViewState extends State<ChildStatesView> {
  late final ChildStatesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ChildStatesController>();
  }

  static const _accent = Color(0xFF0891B2);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'child_state_templates_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: _accent,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'child_state_add'.tr,
            style:
                context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🧸', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 16),
                  Text(
                    'child_state_empty'.tr,
                    style: context.typography.mdRegular
                        .copyWith(color: const Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'child_state_empty_sub'.tr,
                    style: context.typography.xsRegular
                        .copyWith(color: const Color(0xFFCBD5E1)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: controller.items.length,
            itemBuilder: (_, i) => StateCard(
              item: controller.items[i],
              onEdit: () => controller.openEdit(controller.items[i]),
              onDelete: () => controller.delete(controller.items[i]),
              onToggle: () => controller.toggle(controller.items[i]),
            ),
          );
        }),
      ),
    );
  }
}

import '../../../../index/index_main.dart';

class ChildLeaveRequestView extends StatefulWidget {
  const ChildLeaveRequestView({super.key});

  @override
  State<ChildLeaveRequestView> createState() => _ChildLeaveRequestViewState();
}

class _ChildLeaveRequestViewState extends State<ChildLeaveRequestView> {
  late final ChildLeaveRequestController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ChildLeaveRequestController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'child_leave_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'child_leave_add_fab'.tr,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
        body: Column(
          children: [
            ChildLeaveFilterBar(controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const ChildLeaveShimmer();
                }
                if (controller.items.isEmpty) {
                  return ChildLeaveEmpty(onAdd: controller.openAdd);
                }
                return RefreshIndicator(
                  onRefresh: controller.loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: controller.items.length,
                    itemBuilder: (_, i) => ChildLeaveCard(
                      item: controller.items[i],
                      childName: controller.childName(
                        controller.items[i].childId,
                      ),
                      childImage: controller.childImage(
                        controller.items[i].childId,
                      ),
                      onEdit: () => controller.openEdit(controller.items[i]),
                      onDelete: () => controller.delete(controller.items[i]),
                      onApprove: () => controller.updateStatus(
                        controller.items[i],
                        'approved',
                      ),
                      onReject: () => controller.updateStatus(
                        controller.items[i],
                        'rejected',
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

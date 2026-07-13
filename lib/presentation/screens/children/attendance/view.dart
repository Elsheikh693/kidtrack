import '../../../../index/index_main.dart';

class ChildAttendanceView extends StatefulWidget {
  const ChildAttendanceView({super.key});

  @override
  State<ChildAttendanceView> createState() => _ChildAttendanceViewState();
}

class _ChildAttendanceViewState extends State<ChildAttendanceView> {
  late final ChildAttendanceController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ChildAttendanceController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'checkin_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'checkin_add_fab'.tr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            AttendanceChildFilterBar(controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const AttendanceChildShimmer();
                }
                if (controller.items.isEmpty) {
                  return AttendanceChildEmpty(onAdd: controller.openAdd);
                }
                return RefreshIndicator(
                  onRefresh: controller.loadData,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
                    itemCount: controller.items.length,
                    itemBuilder: (_, i) => AttendanceChildCard(
                      item: controller.items[i],
                      childName: controller.childName(controller.items[i].childId),
                      childImage: controller.childImage(controller.items[i].childId),
                      branchName: controller.branchName(controller.items[i].branchId),
                      onEdit: () => controller.openEdit(controller.items[i]),
                      onDelete: () => controller.delete(controller.items[i]),
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

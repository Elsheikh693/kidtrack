import '../../../../index/index_main.dart';

class StaffListView extends StatefulWidget {
  const StaffListView({super.key});

  @override
  State<StaffListView> createState() => _StaffListViewState();
}

class _StaffListViewState extends State<StaffListView> {
  late final StaffListController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => StaffListController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'staff_screen_title'.tr,
            style: context.typography.lgBold.copyWith(
              color: const Color(0xFF1E293B),
              fontSize: 18,
            ),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: const Color(0xFF6366F1),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'staff_add_fab'.tr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.staffList.isEmpty) {
            return StaffEmpty(onAdd: controller.openAdd);
          }
          return RefreshIndicator(
            onRefresh: controller.loadStaff,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              itemCount: controller.staffList.length,
              itemBuilder: (_, i) {
                final staff = controller.staffList[i];
                return StaffCard(
                  staff: staff,
                  branchName: controller.branchName(staff.branchId),
                  onEdit: () => controller.openEdit(staff),
                  onToggleActive: () => controller.toggleActive(staff),
                  onPermissions: () => controller.openPermissions(staff),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

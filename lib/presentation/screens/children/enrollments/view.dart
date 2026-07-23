import '../../../../index/index_main.dart';

class EnrollmentListView extends StatefulWidget {
  const EnrollmentListView({super.key});

  @override
  State<EnrollmentListView> createState() => _EnrollmentListViewState();
}

class _EnrollmentListViewState extends State<EnrollmentListView> {
  late final EnrollmentListController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => EnrollmentListController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          title: Text('enrollment_screen_title'.tr, style: context.typography.mdBold.copyWith(color: const Color(0xFF1E293B), fontSize: 18)),
          iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: const Color(0xFF6366F1),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text('enrollment_add_fab'.tr, style: context.typography.smSemiBold.copyWith(color: Colors.white)),
        ),
        body: Obx(() {
          if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
          if (controller.items.isEmpty) return EnrollmentEmpty(onAdd: controller.openAdd);
          return RefreshIndicator(
            onRefresh: controller.loadData,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              itemCount: controller.items.length,
              itemBuilder: (_, i) {
                final e = controller.items[i];
                return EnrollmentCard(
                  enrollment: e,
                  childName: controller.childName(e.childId),
                  branchName: controller.branchName(e.branchId),
                  classroomName: controller.classroomName(e.classroomId),
                  statusLabel: controller.statusLabel(e.status),
                  onEdit: () => controller.openEdit(e),
                  onDelete: () => controller.delete(e),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

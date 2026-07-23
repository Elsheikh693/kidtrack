import '../../../../index/index_main.dart';

class ClassroomListView extends StatefulWidget {
  const ClassroomListView({super.key});

  @override
  State<ClassroomListView> createState() => _ClassroomListViewState();
}

class _ClassroomListViewState extends State<ClassroomListView> {
  late final ClassroomListController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ClassroomListController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'classroom_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'classroom_add_fab'.tr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const ClassroomShimmer();
          }
          if (controller.items.isEmpty) {
            return ClassroomEmpty(onAdd: controller.openAdd);
          }
          return RefreshIndicator(
            onRefresh: controller.loadData,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              itemCount: controller.items.length,
              itemBuilder: (_, i) => ClassroomCard(
                classroom: controller.items[i],
                branchName: controller.branchScopeLabel(controller.items[i]),
                teacherName: controller.teacherName(controller.items[i].teacherId),
                onTap: () => controller.openDetail(controller.items[i]),
                onEdit: () => controller.openEdit(controller.items[i]),
                onDelete: () => controller.delete(controller.items[i]),
              ),
            ),
          );
        }),
      ),
    );
  }
}

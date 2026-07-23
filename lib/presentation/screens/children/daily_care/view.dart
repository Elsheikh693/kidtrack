import '../../../../index/index_main.dart';

class DailyCareView extends StatefulWidget {
  const DailyCareView({super.key});

  @override
  State<DailyCareView> createState() => _DailyCareViewState();
}

class _DailyCareViewState extends State<DailyCareView> {
  late final DailyCareController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => DailyCareController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'care_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'care_add_fab'.tr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) return const DailyCareShimmer();
          if (controller.items.isEmpty) {
            return DailyCareEmpty(onAdd: controller.openAdd);
          }
          return RefreshIndicator(
            onRefresh: controller.loadData,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              itemCount: controller.items.length,
              itemBuilder: (_, i) => DailyCareCard(
                item: controller.items[i],
                childName: controller.childName(controller.items[i].childId),
                classroomName: controller.classroomName(
                  controller.items[i].classroomId,
                ),
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

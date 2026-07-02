import '../../../../index/index_main.dart';

class BranchListView extends StatefulWidget {
  const BranchListView({super.key});

  @override
  State<BranchListView> createState() => _BranchListViewState();
}

class _BranchListViewState extends State<BranchListView> {
  late final BranchListController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => BranchListController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'branch_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'branch_add_fab'.tr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const BranchShimmer();
          }
          if (controller.items.isEmpty) {
            return BranchEmpty(onAdd: controller.openAdd);
          }
          return RefreshIndicator(
            onRefresh: controller.loadData,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              itemCount: controller.items.length,
              itemBuilder: (_, i) => BranchCard(
                branch: controller.items[i],
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

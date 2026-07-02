import '../../../../index/index_main.dart';

class ProgramListView extends StatefulWidget {
  const ProgramListView({super.key});

  @override
  State<ProgramListView> createState() => _ProgramListViewState();
}

class _ProgramListViewState extends State<ProgramListView> {
  late final ProgramListController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ProgramListController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'program_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'program_add_fab'.tr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const ProgramShimmer();
          }
          if (controller.items.isEmpty) {
            return ProgramEmpty(onAdd: controller.openAdd);
          }
          return RefreshIndicator(
            onRefresh: controller.loadData,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              itemCount: controller.items.length,
              itemBuilder: (_, i) => ProgramCard(
                program: controller.items[i],
                branchScope: controller.branchScopeLabel(controller.items[i]),
                onEdit: () => controller.openEdit(controller.items[i]),
                onDelete: () => controller.delete(controller.items[i]),
                onSubjects: () => controller.openSubjects(controller.items[i]),
              ),
            ),
          );
        }),
      ),
    );
  }
}

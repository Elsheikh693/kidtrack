import '../../../../index/index_main.dart';

class SubjectListView extends StatefulWidget {
  const SubjectListView({super.key});

  @override
  State<SubjectListView> createState() => _SubjectListViewState();
}

class _SubjectListViewState extends State<SubjectListView> {
  late final SubjectListController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => SubjectListController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(() => Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'subject_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'subject_add_fab'.tr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
        body: controller.isLoading.value
            ? const SubjectShimmer()
            : controller.items.isEmpty
                ? SubjectEmpty(onAdd: controller.openAdd)
                : RefreshIndicator(
                    onRefresh: controller.loadData,
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                      itemCount: controller.items.length,
                      itemBuilder: (_, i) => SubjectCard(
                        subject: controller.items[i],
                        branchScope: controller.branchScopeLabel(controller.items[i]),
                        isAllBranches: controller.items[i].isAllBranches,
                        onEdit: () => controller.openEdit(controller.items[i]),
                        onDelete: () => controller.delete(controller.items[i]),
                      ),
                    ),
                  ),
      )),
    );
  }
}

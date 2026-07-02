import '../../../../index/index_main.dart';

class ChildListView extends StatefulWidget {
  const ChildListView({super.key});

  @override
  State<ChildListView> createState() => _ChildListViewState();
}

class _ChildListViewState extends State<ChildListView> {
  late final ChildListController controller;

  late final HandleKeyboardService _keyboardService;
  late final List<String> _keys;

  @override
  void initState() {
    super.initState();

    controller = initController(() => ChildListController());

    _keyboardService = HandleKeyboardService();
    _keys = _keyboardService.generateKeys('child_search', 3);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),

      appBar: HomeAppBar(
        title: 'child_list_title'.tr,
        showNotificationDot: false,
        showFilterIcon: false,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => controller.openAdd(_keyboardService, _keys),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'child_add_fab'.tr,
          style: context.typography.smSemiBold.copyWith(
            color: Colors.white,
          ),
        ),
      ),
      body: KeyboardActions(
        config: _keyboardService.buildConfig(context, _keys),
        disableScroll: true,
        child: Column(
          children: [
            ChildSearchBar(
              controller: controller,
              focusNode: _keyboardService.getFocusNode(_keys[0]),
            ),

            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const ChildShimmer();
                }

                if (controller.items.isEmpty) {
                  return ChildEmpty(
                    onAdd: () => controller.openAdd(_keyboardService, _keys),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.loadData,
                  child: ListView.builder(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 120.h),
                    itemCount: controller.items.length,
                    itemBuilder: (_, i) => ChildCard(
                      child: controller.items[i],
                      branchName: controller.branchName(
                        controller.items[i].branchId,
                      ),
                      classroomName: controller.classroomName(
                        controller.items[i].classroomId,
                      ),
                      onTap: () => controller.openProfile(controller.items[i]),
                      onEdit: () => controller.openEdit(
                        controller.items[i],
                        _keyboardService,
                        _keys,
                      ),
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

import '../../../../index/index_main.dart';

class NurseryListView extends StatefulWidget {
  const NurseryListView({super.key});

  @override
  State<NurseryListView> createState() => _NurseryListViewState();
}

class _NurseryListViewState extends State<NurseryListView> {
  late final NurseryListController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => NurseryListController());
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
            'nursery_screen_title'.tr,
            style: context.typography.mdBold.copyWith(
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
            'nursery_add_fab'.tr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.items.isEmpty) {
            return NurseryEmpty(onAdd: controller.openAdd);
          }
          return RefreshIndicator(
            onRefresh: controller.loadData,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              itemCount: controller.items.length,
              itemBuilder: (_, i) {
                final nursery = controller.items[i];
                return NurseryCard(
                  nursery: nursery,
                  onToggleActive: () => controller.toggleActive(nursery),
                  onDelete: () => controller.delete(nursery),
                  onOpenOwners: () => controller.openDetails(nursery),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

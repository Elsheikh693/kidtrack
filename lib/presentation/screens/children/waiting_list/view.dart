import '../../../../index/index_main.dart';

class WaitingListView extends StatefulWidget {
  const WaitingListView({super.key});

  @override
  State<WaitingListView> createState() => _WaitingListViewState();
}

class _WaitingListViewState extends State<WaitingListView> {
  late final WaitingListController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => WaitingListController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: Colors.white, elevation: 0, centerTitle: true,
          title: Text('waiting_screen_title'.tr, style: context.typography.mdBold.copyWith(color: const Color(0xFF1E293B), fontSize: 18)),
          iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: const Color(0xFF8B5CF6),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text('waiting_add_fab'.tr, style: context.typography.smSemiBold.copyWith(color: Colors.white)),
        ),
        body: Obx(() {
          if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
          if (controller.items.isEmpty) return WaitingEmpty(onAdd: controller.openAdd);
          return RefreshIndicator(
            onRefresh: controller.loadData,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              itemCount: controller.items.length,
              itemBuilder: (_, i) {
                final w = controller.items[i];
                return WaitingCard(
                  waiting: w,
                  statusLabel: controller.statusLabel(w.status),
                  statusColor: controller.statusColor(w.status),
                  onEdit: () => controller.openEdit(w),
                  onDelete: () => controller.delete(w),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

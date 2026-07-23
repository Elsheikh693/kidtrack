import '../../../../index/index_main.dart';

class GuardianListView extends StatefulWidget {
  const GuardianListView({super.key});

  @override
  State<GuardianListView> createState() => _GuardianListViewState();
}

class _GuardianListViewState extends State<GuardianListView> {
  late final GuardianListController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => GuardianListController());
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
          title: Text(
            'guardian_screen_title'.tr,
            style: context.typography.mdBold.copyWith(
              color: const Color(0xFF1E293B),
              fontSize: 18,
            ),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: controller.openCreate,
          backgroundColor: const Color(0xFF6366F1),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: Obx(() {
          if (controller.isLoading.value)
            return const Center(child: CircularProgressIndicator());
          if (controller.items.isEmpty) return GuardianEmpty();
          return RefreshIndicator(
            onRefresh: controller.loadData,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
              itemCount: controller.items.length,
              itemBuilder: (_, i) {
                final p = controller.items[i];
                return GuardianCard(
                  guardian: p,
                  onEdit: () => controller.openEdit(p),
                  onToggleActive: () => controller.toggleActive(p),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

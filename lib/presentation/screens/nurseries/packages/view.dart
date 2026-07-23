import '../../../../index/index_main.dart';

class PackageListView extends StatefulWidget {
  const PackageListView({super.key});

  @override
  State<PackageListView> createState() => _PackageListViewState();
}

class _PackageListViewState extends State<PackageListView> {
  late final PackageListController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => PackageListController());
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
            'package_screen_title'.tr,
            style: context.typography.mdBold.copyWith(color: const Color(0xFF1E293B), fontSize: 18),
          ),
          iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: const Color(0xFF6366F1),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text('package_add_fab'.tr, style: context.typography.smSemiBold.copyWith(color: Colors.white)),
        ),
        body: Obx(() {
          if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
          if (controller.items.isEmpty) return PackageEmpty(onAdd: controller.openAdd);
          return RefreshIndicator(
            onRefresh: controller.loadData,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              itemCount: controller.items.length,
              itemBuilder: (_, i) {
                final pkg = controller.items[i];
                return PackageCard(
                  pkg: pkg,
                  branchName: controller.branchNameFor(pkg),
                  onEdit: () => controller.openEdit(pkg),
                  onToggleActive: () => controller.toggleActive(pkg),
                  onDelete: () => controller.delete(pkg),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

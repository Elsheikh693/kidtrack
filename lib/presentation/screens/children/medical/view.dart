import '../../../../index/index_main.dart';

class MedicalListView extends StatefulWidget {
  const MedicalListView({super.key});

  @override
  State<MedicalListView> createState() => _MedicalListViewState();
}

class _MedicalListViewState extends State<MedicalListView> {
  late final MedicalListController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => MedicalListController());
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
          title: Text('medical_screen_title'.tr, style: context.typography.mdBold.copyWith(color: const Color(0xFF1E293B), fontSize: 18)),
          iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: const Color(0xFFEF4444),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text('medical_add_fab'.tr, style: context.typography.smSemiBold.copyWith(color: Colors.white)),
        ),
        body: Obx(() {
          if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
          if (controller.items.isEmpty) return MedicalEmpty(onAdd: controller.openAdd);
          return RefreshIndicator(
            onRefresh: controller.loadData,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              itemCount: controller.items.length,
              itemBuilder: (_, i) {
                final m = controller.items[i];
                return MedicalCard(
                  medical: m,
                  childName: controller.childName(m.childId),
                  onEdit: () => controller.openEdit(m),
                  onDelete: () => controller.delete(m),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

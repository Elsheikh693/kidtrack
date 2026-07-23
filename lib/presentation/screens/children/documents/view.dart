import '../../../../index/index_main.dart';

class DocumentListView extends StatefulWidget {
  const DocumentListView({super.key});

  @override
  State<DocumentListView> createState() => _DocumentListViewState();
}

class _DocumentListViewState extends State<DocumentListView> {
  late final DocumentListController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => DocumentListController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: Colors.white, elevation: 0, centerTitle: true,
          title: Text('document_screen_title'.tr, style: context.typography.mdBold.copyWith(color: const Color(0xFF1E293B), fontSize: 18)),
          iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: const Color(0xFF0EA5E9),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text('document_add_fab'.tr, style: context.typography.smSemiBold.copyWith(color: Colors.white)),
        ),
        body: Obx(() {
          if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
          if (controller.items.isEmpty) return DocumentEmpty(onAdd: controller.openAdd);
          return RefreshIndicator(
            onRefresh: controller.loadData,
            child: ListView.builder(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              itemCount: controller.items.length,
              itemBuilder: (_, i) {
                final d = controller.items[i];
                return DocumentCard(
                  document: d,
                  childName: controller.childName(d.childId),
                  typeLabel: controller.typeLabel(d.type),
                  onEdit: () => controller.openEdit(d),
                  onDelete: () => controller.delete(d),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}

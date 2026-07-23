import '../../../../index/index_main.dart';

class InvoiceView extends StatefulWidget {
  const InvoiceView({super.key});

  @override
  State<InvoiceView> createState() => _InvoiceViewState();
}

class _InvoiceViewState extends State<InvoiceView> {
  late final InvoiceController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => InvoiceController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'invoice_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'invoice_add_fab'.tr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            InvoiceFilterBar(controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const InvoiceShimmer();
                if (controller.items.isEmpty) {
                  return InvoiceEmpty(onAdd: controller.openAdd);
                }
                return RefreshIndicator(
                  onRefresh: controller.loadData,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
                    itemCount: controller.items.length,
                    itemBuilder: (_, i) => InvoiceCard(
                      item: controller.items[i],
                      childName: controller.childName(
                        controller.items[i].childId,
                      ),
                      onEdit: () => controller.openEdit(controller.items[i]),
                      onDelete: () => controller.delete(controller.items[i]),
                      onMarkPaid: controller.items[i].status != 'paid'
                          ? () => controller.markAsPaid(controller.items[i])
                          : null,
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

import '../../../../index/index_main.dart';

class SupportTicketsView extends StatefulWidget {
  const SupportTicketsView({super.key});

  @override
  State<SupportTicketsView> createState() => _SupportTicketsViewState();
}

class _SupportTicketsViewState extends State<SupportTicketsView> {
  late final SupportTicketController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => SupportTicketController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'ticket_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'ticket_add_fab'.tr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
        body: Column(
          children: [
            TicketFilterBar(controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const TicketShimmer();
                if (controller.items.isEmpty) {
                  return TicketEmpty(onAdd: controller.openAdd);
                }
                return RefreshIndicator(
                  onRefresh: controller.loadData,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
                    itemCount: controller.items.length,
                    itemBuilder: (_, i) => TicketCard(
                      item: controller.items[i],
                      onReply: () => controller.openReply(controller.items[i]),
                      onEdit: () => controller.openReply(controller.items[i]),
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

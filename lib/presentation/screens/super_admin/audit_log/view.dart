import '../../../../index/index_main.dart';

class AuditLogView extends StatefulWidget {
  const AuditLogView({super.key});

  @override
  State<AuditLogView> createState() => _AuditLogViewState();
}

class _AuditLogViewState extends State<AuditLogView> {
  late final AuditLogController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => AuditLogController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'audit_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        body: Column(
          children: [
            AuditFilterBar(controller: controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) return const AuditShimmer();
                if (controller.items.isEmpty) {
                  return const AuditEmpty();
                }
                return RefreshIndicator(
                  onRefresh: controller.loadData,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
                    itemCount: controller.items.length,
                    itemBuilder: (_, i) => AuditCard(item: controller.items[i]),
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

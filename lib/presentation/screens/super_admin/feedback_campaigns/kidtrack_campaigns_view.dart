import '../../../../index/index_main.dart';
import 'kidtrack_campaigns_controller.dart';
import 'widgets/kidtrack_campaign_card.dart';

class KidtrackCampaignsView extends StatefulWidget {
  const KidtrackCampaignsView({super.key});

  @override
  State<KidtrackCampaignsView> createState() => _KidtrackCampaignsViewState();
}

class _KidtrackCampaignsViewState extends State<KidtrackCampaignsView> {
  late final KidtrackCampaignsController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => KidtrackCampaignsController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'sa_feedback_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: const Color(0xFFF59E0B),
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'sa_feedback_add'.tr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.feedback_outlined,
                      size: 64.sp, color: const Color(0xFFCBD5E1)),
                  SizedBox(height: 16.h),
                  Text(
                    'sa_feedback_empty'.tr,
                    style: context.typography.mdRegular
                        .copyWith(color: const Color(0xFF94A3B8)),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'sa_feedback_empty_sub'.tr,
                    style: context.typography.xsRegular
                        .copyWith(color: const Color(0xFFCBD5E1)),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
            itemCount: controller.items.length,
            itemBuilder: (_, i) => KidtrackCampaignCard(
              item: controller.items[i],
              onEdit: () => controller.openEdit(controller.items[i]),
              onToggle: () => controller.toggleEnabled(controller.items[i]),
              onDelete: () => controller.delete(controller.items[i]),
            ),
          );
        }),
      ),
    );
  }
}

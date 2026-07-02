import '../../../../index/index_main.dart';
import 'application_details_view.dart';
import 'widgets/application_card.dart';
import 'widgets/approve_appointment_sheet.dart';
import 'widgets/reject_reason_sheet.dart';

class ManagerApplicationsView extends StatefulWidget {
  const ManagerApplicationsView({super.key});

  @override
  State<ManagerApplicationsView> createState() =>
      _ManagerApplicationsViewState();
}

class _ManagerApplicationsViewState extends State<ManagerApplicationsView> {
  late final ManagerApplicationsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ManagerApplicationsController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _header(context),
            _filters(context),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = controller.filtered;
                if (items.isEmpty) {
                  return Center(
                    child: AppText(
                      text: 'apply_manage_empty'.tr,
                      textStyle: context.typography.smRegular
                          .copyWith(color: AppColors.textSecondaryParagraph),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: controller.load,
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 30.h),
                    itemCount: items.length,
                    itemBuilder: (_, i) => ApplicationCard(
                      application: items[i],
                      onTap: () => _openDetails(items[i]),
                      onApprove: () => _openApprove(items[i]),
                      onReject: () => _openReject(items[i]),
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

  void _openDetails(OnlineApplicationModel app) {
    Get.to(() => ApplicationDetailsView(
          controller: controller,
          application: app,
        ));
  }

  void _openApprove(OnlineApplicationModel app) {
    Get.bottomSheet(
      ApproveAppointmentSheet(
        onConfirm: (appointment) {
          Get.back();
          controller.approve(app, appointment: appointment);
        },
      ),
      isScrollControlled: true,
    );
  }

  void _openReject(OnlineApplicationModel app) {
    Get.bottomSheet(
      RejectReasonSheet(
        onConfirm: (reason) {
          Get.back();
          controller.reject(app, reason);
        },
      ),
      isScrollControlled: true,
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(8.w, 8.h, 16.w, 12.h),
      child: Row(
        children: [
          IconButton(
            onPressed: Get.back,
            icon: const Icon(Icons.arrow_back_rounded),
            color: AppColors.textDefault,
          ),
          Expanded(
            child: AppText(
              text: 'apply_manage_title'.tr,
              textStyle: context.typography.mdBold
                  .copyWith(color: AppColors.textDefault),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filters(BuildContext context) {
    final tabs = {
      ApplicationFilter.pending: 'apply_status_pending',
      ApplicationFilter.approved: 'apply_status_approved',
      ApplicationFilter.rejected: 'apply_status_rejected',
    };
    return Obx(() => Container(
          color: AppColors.white,
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          child: Row(
            children: tabs.entries.map((e) {
              final isSel = controller.filter.value == e.key;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.setFilter(e.key),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    padding: EdgeInsets.symmetric(vertical: 9.h),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSel
                          ? AppColors.primary
                          : AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: AppText(
                      text: e.value.tr,
                      textStyle: context.typography.smSemiBold.copyWith(
                        color: isSel ? AppColors.white : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ));
  }
}

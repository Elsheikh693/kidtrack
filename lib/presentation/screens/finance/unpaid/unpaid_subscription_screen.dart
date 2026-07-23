import '../../../../index/index_main.dart';
import 'widgets/unpaid_child_tile.dart';
import 'widgets/send_reminder_sheet.dart';

/// Full list of children who still owe this month's subscription, for the
/// current viewer's scope. Reads the SAME shared controller as the dashboard
/// card (already loaded) and lets staff nudge each child's guardians. Purely a
/// prompt — sending a reminder never records a payment.
class UnpaidSubscriptionScreen extends StatelessWidget {
  const UnpaidSubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UnpaidSubscriptionController>();
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF1E293B)),
          title: Text(
            'unpaid_screen_title'.tr,
            style: context.typography.smSemiBold
                .copyWith(color: const Color(0xFF1E293B), fontSize: 15),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: controller.load,
          color: AppColors.primary,
          child: Obx(() {
            final items = controller.unpaidChildren;
            if (items.isEmpty) {
              return _AllPaidState(loading: controller.isLoading.value);
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 40.h),
              itemCount: items.length,
              separatorBuilder: (_, _) => SizedBox(height: 10.h),
              itemBuilder: (_, i) {
                final child = items[i];
                return UnpaidChildTile(
                  child: child,
                  guardians: controller.parentNamesByChild[child.key] ?? '',
                  hasRecipients: controller.recipientsFor(child).isNotEmpty,
                  onSend: () => _openSheet(controller, child),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  void _openSheet(UnpaidSubscriptionController controller, ChildModel child) {
    Get.bottomSheet(
      SendReminderSheet(
        childName: child.fullName,
        onSend: (message) => controller.sendReminder(child, message),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

class _AllPaidState extends StatelessWidget {
  const _AllPaidState({required this.loading});

  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(
        parent: BouncingScrollPhysics(),
      ),
      children: [
        SizedBox(height: 140.h),
        Icon(
          loading ? Icons.hourglass_empty_rounded : Icons.verified_rounded,
          size: 54.sp,
          color: loading
              ? AppColors.textSecondaryParagraph
              : AppColors.successForeground,
        ),
        SizedBox(height: 14.h),
        Text(
          loading ? 'unpaid_loading'.tr : 'unpaid_all_paid'.tr,
          textAlign: TextAlign.center,
          style: context.typography.smSemiBold.copyWith(
            color: AppColors.textDefault,
          ),
        ),
      ],
    );
  }
}

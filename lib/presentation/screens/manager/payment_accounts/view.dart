import '../../../../index/index_main.dart';
import 'widgets/payment_account_tile.dart';

/// Owner/manager screen listing the nursery's own collection accounts, with an
/// add FAB and per-row edit/delete. Guardians pay tuition to these accounts.
class NurseryPaymentAccountsView extends StatefulWidget {
  const NurseryPaymentAccountsView({super.key});

  @override
  State<NurseryPaymentAccountsView> createState() =>
      _NurseryPaymentAccountsViewState();
}

class _NurseryPaymentAccountsViewState
    extends State<NurseryPaymentAccountsView> {
  late final NurseryPaymentAccountsController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => NurseryPaymentAccountsController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: HomeAppBar(
          title: 'nursery_pay_accounts_title'.tr,
          showNotificationDot: false,
          showFilterIcon: false,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: controller.openAdd,
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: Text(
            'nursery_pay_accounts_add'.tr,
            style: context.typography.smSemiBold.copyWith(color: Colors.white),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
                child: CircularProgressIndicator(color: AppColors.primary));
          }
          return RefreshIndicator(
            onRefresh: controller.loadData,
            child: ListView(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
              children: [
                _Intro(),
                SizedBox(height: 16.h),
                if (controller.accounts.isEmpty)
                  _Empty()
                else
                  ...controller.accounts.map(
                    (a) => PaymentAccountTile(
                      item: a,
                      onEdit: () => controller.openEdit(a),
                      onDelete: () => controller.confirmDelete(a),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 20.sp, color: AppColors.primary),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'nursery_pay_accounts_subtitle'.tr,
              style: context.typography.xsRegular
                  .copyWith(color: AppColors.textPrimaryParagraph),
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 60.h),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 56.sp, color: AppColors.grayLight),
          SizedBox(height: 14.h),
          Text(
            'nursery_pay_accounts_empty'.tr,
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}

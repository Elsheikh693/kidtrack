import '../../../../index/index_main.dart';
import 'widgets/payment_account_field.dart';

/// SuperAdmin screen to edit the platform's subscription-collection accounts.
class PlatformPaymentAccountsView extends StatefulWidget {
  const PlatformPaymentAccountsView({super.key});

  @override
  State<PlatformPaymentAccountsView> createState() =>
      _PlatformPaymentAccountsViewState();
}

class _PlatformPaymentAccountsViewState
    extends State<PlatformPaymentAccountsView> {
  late final PlatformPaymentAccountsController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => PlatformPaymentAccountsController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: true,
          leading: GestureDetector(
            onTap: Get.back,
            child: Icon(Icons.arrow_back_ios_rounded,
                color: AppColors.textDefault, size: 20.sp),
          ),
          title: Text(
            'pay_accounts_editor_title'.tr,
            style: context.typography.mdBold
                .copyWith(color: AppColors.textDefault),
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          return ListView(
            padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 32.h),
            children: [
              PaymentAccountField(
                label: 'pay_instapay_number'.tr,
                hint: 'pay_accounts_hint_number'.tr,
                controller: controller.instapayCtrl,
                keyboardType: TextInputType.phone,
              ),
              PaymentAccountField(
                label: 'pay_wallet_number'.tr,
                hint: 'pay_accounts_hint_number'.tr,
                controller: controller.walletCtrl,
                keyboardType: TextInputType.phone,
              ),
              PaymentAccountField(
                label: 'pay_instapay_link'.tr,
                hint: 'pay_accounts_hint_link'.tr,
                controller: controller.linkCtrl,
                keyboardType: TextInputType.url,
              ),
              SizedBox(height: 24.h),
              Obx(
                () => controller.isSaving.value
                    ? Container(
                        height: 52.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: const Center(
                          child: SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      )
                    : PrimaryTextButton(
                        appButtonSize: AppButtonSize.xxLarge,
                        onTap: controller.save,
                        label: AppText(
                          text: 'pay_accounts_save'.tr,
                          textStyle: context.typography.mdBold
                              .copyWith(color: AppColors.white),
                        ),
                      ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

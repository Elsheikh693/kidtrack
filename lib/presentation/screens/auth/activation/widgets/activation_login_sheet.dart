import '../../../../../index/index_main.dart';
import 'activation_code_card.dart';

/// The single, app-wide login entry: a passwordless bottom sheet where the
/// holder enters their activation code (or scans the printed QR) and is signed
/// straight in. Opened from every "login" affordance (nursery profile,
/// settings, ...). There is no username/password screen anymore.
Future<void> openActivationLoginSheet() {
  return Get.bottomSheet(
    const _ActivationLoginSheet(),
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
  );
}

class _ActivationLoginSheet extends StatefulWidget {
  const _ActivationLoginSheet();

  @override
  State<_ActivationLoginSheet> createState() => _ActivationLoginSheetState();
}

class _ActivationLoginSheetState extends State<_ActivationLoginSheet> {
  late final ActivationCodeController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ActivationCodeController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.vpn_key_rounded,
                  color: AppColors.primary,
                  size: 28.sp,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'activation_screen_title'.tr,
                style: context.typography.lgBold.copyWith(
                  color: AppColors.textDisplay,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                'activation_screen_sub'.tr,
                style: context.typography.smRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 26.h),
              ActivationCodeCard(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

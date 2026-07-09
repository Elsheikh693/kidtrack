import '../../../../../index/index_main.dart';
import 'activation_code_formatter.dart';

/// Input block for the activation screen: the auto-formatting code field, the
/// primary Continue button, and a prominent "scan QR" card as the faster path.
class ActivationCodeCard extends StatelessWidget {
  const ActivationCodeCard({super.key, required this.controller});

  final ActivationCodeController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'activation_code_label'.tr,
          style: context.typography.smSemiBold.copyWith(
            color: AppColors.textDisplay,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 8.h),
        AppTextField(
          controller: controller.codeController,
          focusNode: controller.codeFocus,
          hintText: 'activation_code_hint'.tr,
          hintColor: const Color(0xFFCBD5E1),
          textInputAction: TextInputAction.done,
          onChanged: controller.onCodeChanged,
          formaters: [ActivationCodeFormatter()],
          prefixIcon: Icon(
            Icons.vpn_key_outlined,
            size: 20.sp,
            color: AppColors.textSecondaryParagraph,
          ),
        ),
        SizedBox(height: 24.h),
        _SubmitButton(controller: controller),
        SizedBox(height: 20.h),
        const _OrDivider(),
        SizedBox(height: 20.h),
        _ScanCard(onTap: controller.scanCode),
      ],
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.controller});

  final ActivationCodeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final active = controller.canSubmit && !controller.isLoading.value;
      return AnimatedScale(
        scale: active ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
        child: GestureDetector(
          onTap: active
              ? () {
                  FocusScope.of(context).unfocus();
                  controller.submit();
                }
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 56.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              gradient: active
                  ? LinearGradient(
                      colors: [AppColors.primary60, AppColors.primary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: active ? null : const Color(0xFFEDEBF2),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.38),
                        blurRadius: 22.r,
                        offset: Offset(0, 10.h),
                      ),
                    ]
                  : [],
            ),
            child: Center(
              child: controller.isLoading.value
                  ? SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white,
                        ),
                      ),
                    )
                  : Text(
                      'activation_submit'.tr,
                      style: context.typography.mdBold.copyWith(
                        color: active
                            ? AppColors.white
                            : const Color(0xFFA9A2BC),
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
      );
    });
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final line = Expanded(
      child: Divider(color: const Color(0xFFE5E7EB), thickness: 1.h),
    );
    return Row(
      children: [
        line,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          child: Text(
            'activation_or'.tr,
            style: context.typography.xsRegular.copyWith(
              color: AppColors.textSecondaryParagraph,
            ),
          ),
        ),
        line,
      ],
    );
  }
}

class _ScanCard extends StatelessWidget {
  const _ScanCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Container(
              width: 46.w,
              height: 46.w,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.qr_code_scanner_rounded,
                size: 27.sp,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'activation_scan_cta'.tr,
                    style: context.typography.smSemiBold.copyWith(
                      color: AppColors.textDisplay,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'activation_scan_fast'.tr,
                    style: context.typography.xsRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 22.sp,
              color: AppColors.primary.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}

import '../../../index/index_main.dart';

/// Opens the role-agnostic account-activation sheet for [code].
///
/// Shows the activation code (as QR + text), a Send-via-WhatsApp action that
/// delivers the code to [phone], and a Regenerate action that rotates the code.
/// Reused by every creator flow (reception→parent, owner→staff, ...).
Future<void> openActivationSheet({
  required ActivationCodeModel code,
  required String recipientName,
  required String? phone,
  required String nurseryName,
  String? nurseryLogoUrl,
}) async {
  await Get.bottomSheet(
    _ActivationSheet(
      initialCode: code,
      recipientName: recipientName,
      phone: phone,
      nurseryName: nurseryName,
      nurseryLogoUrl: nurseryLogoUrl,
    ),
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
  );
}

class _ActivationSheet extends StatefulWidget {
  final ActivationCodeModel initialCode;
  final String recipientName;
  final String? phone;
  final String nurseryName;
  final String? nurseryLogoUrl;

  const _ActivationSheet({
    required this.initialCode,
    required this.recipientName,
    required this.phone,
    required this.nurseryName,
    required this.nurseryLogoUrl,
  });

  @override
  State<_ActivationSheet> createState() => _ActivationSheetState();
}

class _ActivationSheetState extends State<_ActivationSheet> {
  late ActivationCodeModel _code = widget.initialCode;

  ActivationParentService get _service => Get.find<ActivationParentService>();

  void _sendWhatsApp() {
    final phone = widget.phone ?? '';
    if (phone.trim().isEmpty) {
      Loader.showError('activation_no_phone'.tr);
      return;
    }
    Get.back();
    launchWhatsApp(
      phone,
      message: buildActivationMessage(
        role: _code.role,
        name: widget.recipientName,
        code: _code.code,
        nurseryName: widget.nurseryName,
      ),
    );
  }

  Future<void> _regenerate() async {
    final fresh = await _service.regenerate(current: _code);
    if (fresh != null) {
      setState(() => _code = fresh);
      Loader.showSuccess('activation_regenerated'.tr);
    } else {
      Loader.showError('activation_regenerate_error'.tr);
    }
  }

  Future<void> _downloadPdf() async {
    try {
      await shareActivationCardPdf(
        code: _code.code,
        holderName: widget.recipientName,
        nurseryName: widget.nurseryName,
        nurseryLogoUrl: widget.nurseryLogoUrl,
      );
    } catch (_) {
      Loader.showError('activation_pdf_error'.tr);
    }
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: _code.code));
    Loader.showSuccess('activation_code_copied'.tr);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 28.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 20.h),
            _header(context),
            SizedBox(height: 20.h),
            _qrCard(context),
            SizedBox(height: 22.h),
            PrimaryTextButton(
              appButtonSize: AppButtonSize.xlarge,
              onTap: _sendWhatsApp,
              customBackgroundColor: const Color(0xFF25D366),
              leading: (color) =>
                  Icon(Icons.chat_rounded, color: color, size: 20.sp),
              label: AppText(
                text: 'activation_send_whatsapp'.tr,
                textStyle: context.typography.mdBold
                    .copyWith(color: AppColors.white),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: _SecondaryAction(
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'activation_pdf_short'.tr,
                    onTap: _downloadPdf,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _SecondaryAction(
                    icon: Icons.autorenew_rounded,
                    label: 'activation_regenerate_short'.tr,
                    onTap: _regenerate,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final name = widget.recipientName.trim();
    final phone = widget.phone ?? '';
    return Row(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Text(
            name.isNotEmpty ? name[0] : '؟',
            style: context.typography.lgBold
                .copyWith(color: AppColors.primary, fontSize: 20),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name.isEmpty ? 'activation_title'.tr : name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.mdBold
                    .copyWith(color: AppColors.textDefault),
              ),
              if (phone.trim().isNotEmpty) ...[
                SizedBox(height: 2.h),
                Text(
                  phone,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.right,
                  style: context.typography.smRegular
                      .copyWith(color: AppColors.textSecondaryParagraph),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _qrCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 22.h, horizontal: 20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.white,
            AppColors.primaryLight.withValues(alpha: 0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Column(
        children: [
          ActivationQr(code: _code.code, size: 188, showCode: false),
          SizedBox(height: 16.h),
          GestureDetector(
            onTap: _copyCode,
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _code.code,
                    textDirection: TextDirection.ltr,
                    style: context.typography.displaySmBold.copyWith(
                      color: AppColors.primary,
                      letterSpacing: 2,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Icon(Icons.copy_rounded,
                      size: 18.sp, color: AppColors.primary),
                ],
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'activation_tap_to_copy'.tr,
            style: context.typography.xsRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}

class _SecondaryAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _SecondaryAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.primaryLight),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 19.sp, color: AppColors.primary),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.primary, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

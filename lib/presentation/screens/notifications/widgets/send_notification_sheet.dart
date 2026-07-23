import '../../../../index/index_main.dart';

class SendNotificationSheet extends StatefulWidget {
  final NotificationsController controller;

  const SendNotificationSheet({super.key, required this.controller});

  @override
  State<SendNotificationSheet> createState() => _SendNotificationSheetState();
}

class _SendNotificationSheetState extends State<SendNotificationSheet>
    with KeyboardSheetMixin {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _bodyCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);

    await widget.controller.sendNotification(
      title: _titleCtrl.text,
      body: _bodyCtrl.text,
      type: 'general',
      toAll: true,
    );

    if (mounted) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: wrapWithKeyboard(
        context: context,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _SheetHandle(),
                  SizedBox(height: 20.h),
                  const _SheetHeader(),
                  SizedBox(height: 24.h),
                  _FieldLabel(text: 'notif_field_title'.tr),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: _titleCtrl,
                    hintText: 'notif_field_title_hint'.tr,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    validator: (v) => Validators.notEmpty(
                      v,
                      errorMessage: 'notif_error_title_required'.tr,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _FieldLabel(text: 'notif_field_body'.tr),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: _bodyCtrl,
                    hintText: 'notif_field_body_hint'.tr,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    maxLines: 3,
                    validator: (v) => Validators.notEmpty(
                      v,
                      errorMessage: 'notif_error_body_required'.tr,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  const _AudienceBanner(),
                  SizedBox(height: 28.h),
                  _SubmitButton(
                    isSubmitting: _isSubmitting,
                    onTap: _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Drag Handle ───────────────────────────────────────────────────────────────

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40.w,
        height: 4.h,
        decoration: BoxDecoration(
          color: AppColors.grayLight,
          borderRadius: BorderRadius.circular(4.r),
        ),
      ),
    );
  }
}

// ── Header (icon + title + subtitle) ──────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 44.w,
          height: 44.w,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Center(
            child: Icon(
              Icons.campaign_rounded,
              color: AppColors.primary,
              size: 22.sp,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: 'notif_send_title'.tr,
                textStyle: context.typography.lgBold.copyWith(
                  color: AppColors.textDefault,
                ),
              ),
              SizedBox(height: 2.h),
              AppText(
                text: 'notif_send_subtitle'.tr,
                textStyle: context.typography.xsRegular.copyWith(
                  color: AppColors.textSecondaryParagraph,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Audience Banner (broadcast is the only target) ────────────────────────────

class _AudienceBanner extends StatelessWidget {
  const _AudienceBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.people_rounded, size: 20.sp, color: AppColors.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: 'notif_target_all'.tr,
                  textStyle: context.typography.smMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                AppText(
                  text: 'notif_target_all_sub'.tr,
                  textStyle: context.typography.xsRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Submit Button ─────────────────────────────────────────────────────────────

class _SubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final VoidCallback onTap;

  const _SubmitButton({required this.isSubmitting, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: isSubmitting
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
              onTap: onTap,
              label: AppText(
                text: 'notif_send_btn'.tr,
                textStyle: context.typography.mdBold.copyWith(
                  color: AppColors.white,
                ),
              ),
            ),
    );
  }
}

// ── Field Label ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: AppText(
        text: text,
        textStyle: context.typography.smMedium.copyWith(
          color: AppColors.textDefault,
        ),
      ),
    );
  }
}

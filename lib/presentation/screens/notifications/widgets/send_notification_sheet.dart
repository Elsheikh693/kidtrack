import '../../../../index/index_main.dart';

class SendNotificationSheet extends StatefulWidget {
  final NotificationsController controller;

  const SendNotificationSheet({super.key, required this.controller});

  @override
  State<SendNotificationSheet> createState() => _SendNotificationSheetState();
}

class _SendNotificationSheetState extends State<SendNotificationSheet> with KeyboardSheetMixin {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late final TextEditingController _userIdCtrl;

  bool _toAll = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController();
    _bodyCtrl = TextEditingController();
    _userIdCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    _userIdCtrl.dispose();
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
      toAll: _toAll,
      targetUserId: _toAll ? null : _userIdCtrl.text,
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
                // ── Drag Handle ─────────────────────────────────
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.grayLight,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),

                SizedBox(height: 20.h),

                // ── Title ───────────────────────────────────────
                AppText(
                  text: 'notif_send_title'.tr,
                  textStyle: context.typography.lgBold.copyWith(
                    color: AppColors.textDefault,
                  ),
                ),

                SizedBox(height: 24.h),

                // ── Notification Title ──────────────────────────
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

                // ── Body ────────────────────────────────────────
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

                // ── Target Toggle ───────────────────────────────
                _TargetToggle(
                  toAll: _toAll,
                  onChanged: (v) => setState(() => _toAll = v),
                ),

                // ── User ID field (conditional) ─────────────────
                if (!_toAll) ...[
                  SizedBox(height: 16.h),
                  _FieldLabel(text: 'notif_user_id'.tr),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: _userIdCtrl,
                    hintText: 'notif_user_id_hint'.tr,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    validator: _toAll
                        ? null
                        : (v) => Validators.notEmpty(
                            v,
                            errorMessage: 'notif_error_user_id_required'.tr,
                          ),
                  ),
                ],

                SizedBox(height: 28.h),

                // ── Send Button ─────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: _isSubmitting
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
                          onTap: _submit,
                          label: AppText(
                            text: 'notif_send_btn'.tr,
                            textStyle: context.typography.mdBold.copyWith(
                              color: AppColors.white,
                            ),
                          ),
                        ),
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

// ── Target Toggle ─────────────────────────────────────────────────────────────

class _TargetToggle extends StatelessWidget {
  final bool toAll;
  final ValueChanged<bool> onChanged;

  const _TargetToggle({required this.toAll, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundNeutral100,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          _TargetOption(
            label: 'notif_target_all'.tr,
            subtitle: 'notif_target_all_sub'.tr,
            icon: Icons.people_rounded,
            isSelected: toAll,
            isTop: true,
            onTap: () => onChanged(true),
          ),
          // const Divider(height: 1, color: AppColors.grayLight),
          // _TargetOption(
          //   label: 'notif_target_specific'.tr,
          //   subtitle: 'notif_target_specific_sub'.tr,
          //   icon: Icons.person_rounded,
          //   isSelected: !toAll,
          //   isTop: false,
          //   onTap: () => onChanged(false),
          // ),
        ],
      ),
    );
  }
}

class _TargetOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final bool isTop;
  final VoidCallback onTap;

  const _TargetOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.isTop,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.06)
              : Colors.transparent,
          borderRadius: BorderRadius.vertical(
            top: isTop ? Radius.circular(12.r) : Radius.zero,
            bottom: isTop ? Radius.zero : Radius.circular(12.r),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryLight : AppColors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: 18.sp,
                  color: isSelected ? AppColors.primary : AppColors.grayMedium,
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: label,
                    textStyle: context.typography.smMedium.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textDefault,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppText(
                    text: subtitle,
                    textStyle: context.typography.xsRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? AppColors.primary : AppColors.grayMedium,
              size: 20.sp,
            ),
          ],
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

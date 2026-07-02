import '../../../../../index/index_main.dart';
import 'apply_form_parts.dart';

class ApplyStepNotes extends StatefulWidget {
  final OnlineApplicationController controller;
  const ApplyStepNotes({super.key, required this.controller});

  @override
  State<ApplyStepNotes> createState() => _ApplyStepNotesState();
}

class _ApplyStepNotesState extends State<ApplyStepNotes>
    with KeyboardSheetMixin {
  late final FocusNode _notesFocus;

  @override
  void initState() {
    super.initState();
    _notesFocus = kbNode();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return wrapWithKeyboard(
      context: context,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          const ApplyStepHeader(
            icon: Icons.notes_rounded,
            titleKey: 'apply_step_notes_title',
            subtitleKey: 'apply_step_notes_sub',
          ),
          Container(
          padding: EdgeInsets.all(12.w),
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.verified_user_outlined,
                  size: 18.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Expanded(
                child: AppText(
                  text: 'apply_accounts_hint'.tr,
                  textStyle: context.typography.xsRegular
                      .copyWith(color: AppColors.primary, height: 1.6),
                  maxLines: 4,
                ),
              ),
            ],
          ),
        ),
        _accountCard(
          context,
          titleKey: 'apply_account_father',
          icon: Icons.man_rounded,
          phone: controller.fatherPhone,
        ),
        SizedBox(height: 12.h),
        _accountCard(
          context,
          titleKey: 'apply_account_mother',
          icon: Icons.woman_rounded,
          phone: controller.motherPhone,
        ),
          SizedBox(height: 20.h),
          ApplyField(
            controller: controller.notes,
            labelKey: 'apply_field_notes',
            maxLines: 4,
            focusNode: _notesFocus,
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _accountCard(
    BuildContext context, {
    required String titleKey,
    required IconData icon,
    required TextEditingController phone,
  }) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: phone,
      builder: (_, value, _) {
        final p = value.text.trim();
        return Container(
          padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.grayLight),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 34.w,
                    height: 34.w,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, size: 18.sp, color: AppColors.primary),
                  ),
                  SizedBox(width: 10.w),
                  AppText(
                    text: titleKey.tr,
                    textStyle: context.typography.smSemiBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              _credRow(context, Icons.person_outline_rounded,
                  'apply_account_username', p),
              SizedBox(height: 8.h),
              _credRow(context, Icons.lock_outline_rounded,
                  'apply_account_password', p),
            ],
          ),
        );
      },
    );
  }

  Widget _credRow(
      BuildContext context, IconData icon, String labelKey, String value) {
    return Row(
      children: [
        Icon(icon, size: 15.sp, color: AppColors.grayMedium),
        SizedBox(width: 6.w),
        AppText(
          text: '${labelKey.tr}: ',
          textStyle: context.typography.xsMedium
              .copyWith(color: AppColors.textSecondaryParagraph),
        ),
        Expanded(
          child: AppText(
            text: value.isEmpty ? '—' : value,
            textStyle: context.typography.xsBold
                .copyWith(color: AppColors.primary),
            maxLines: 1,
          ),
        ),
      ],
    );
  }
}

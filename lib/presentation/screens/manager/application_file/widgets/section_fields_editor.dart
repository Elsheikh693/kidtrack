import '../../../../../index/index_main.dart';

/// Resolves a field's display name: the manager's custom [label] wins, otherwise
/// the built-in localization key.
String resolveFieldLabel(ApplyFieldConfig f) => f.label.isNotEmpty
    ? f.label
    : (f.labelKey.isNotEmpty ? f.labelKey.tr : '');

/// Inline editor for a data section's fields (child / father / mother). Lists
/// the configured fields with quick enable toggles, and an "add field" button
/// that opens the [showFieldEditorSheet]. Built-in fields can be relabeled but
/// not deleted; the core ones (name/phone/photo) are fully locked.
class SectionFieldsEditor extends StatelessWidget {
  const SectionFieldsEditor({
    super.key,
    required this.controller,
    required this.type,
  });

  final ManagerApplicationFileController controller;
  final ApplyFormSectionType type;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() {
          final fields = controller.fieldsOf(type);
          return Column(
            children: [
              for (final f in fields) ...[
                _FieldRow(controller: controller, type: type, field: f),
                SizedBox(height: 8.h),
              ],
            ],
          );
        }),
        GestureDetector(
          onTap: () => showFieldEditorSheet(context, controller, type),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, size: 18.sp, color: AppColors.primary),
                SizedBox(width: 6.w),
                AppText(
                  text: 'manager_apply_add_field'.tr,
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldRow extends StatelessWidget {
  const _FieldRow({
    required this.controller,
    required this.type,
    required this.field,
  });

  final ManagerApplicationFileController controller;
  final ApplyFormSectionType type;
  final ApplyFieldConfig field;

  @override
  Widget build(BuildContext context) {
    final enabled = field.enabled;
    return InkWell(
      borderRadius: BorderRadius.circular(12.r),
      onTap: () =>
          showFieldEditorSheet(context, controller, type, existing: field),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.grayLight),
        ),
        child: Row(
          children: [
            Icon(_iconFor(field.type),
                size: 18.sp,
                color: enabled ? AppColors.primary : AppColors.grayMedium),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: AppText(
                          text: resolveFieldLabel(field),
                          textStyle: context.typography.smMedium.copyWith(
                            color: enabled
                                ? AppColors.textDefault
                                : AppColors.grayMedium,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      if (field.required) ...[
                        SizedBox(width: 4.w),
                        AppText(
                          text: '*',
                          textStyle: context.typography.smSemiBold
                              .copyWith(color: AppColors.errorForeground),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      AppText(
                        text: 'field_type_${field.type.id}'.tr,
                        textStyle: context.typography.xsRegular
                            .copyWith(color: AppColors.grayMedium),
                      ),
                      if (field.isSystem) ...[
                        SizedBox(width: 6.w),
                        Icon(Icons.lock_outline_rounded,
                            size: 12.sp, color: AppColors.grayMedium),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (!field.isSystem)
              GestureDetector(
                onTap: () => controller.removeField(type, field.id),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 6.w),
                  child: Icon(Icons.delete_outline_rounded,
                      size: 18.sp, color: AppColors.errorForeground),
                ),
              ),
            Switch.adaptive(
              value: enabled,
              activeThumbColor: AppColors.primary,
              onChanged: field.isLocked
                  ? null
                  : (v) => controller.toggleFieldEnabled(type, field.id, v),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(ApplyFieldType t) {
    switch (t) {
      case ApplyFieldType.text:
        return Icons.text_fields_rounded;
      case ApplyFieldType.number:
        return Icons.pin_rounded;
      case ApplyFieldType.phone:
        return Icons.phone_rounded;
      case ApplyFieldType.date:
        return Icons.calendar_today_rounded;
      case ApplyFieldType.dropdown:
        return Icons.arrow_drop_down_circle_outlined;
      case ApplyFieldType.radio:
        return Icons.radio_button_checked_rounded;
      case ApplyFieldType.checkbox:
        return Icons.check_box_outlined;
      case ApplyFieldType.toggle:
        return Icons.toggle_on_rounded;
      case ApplyFieldType.photo:
        return Icons.photo_camera_rounded;
    }
  }
}

/// Bottom sheet to create a new field or edit an existing one. For built-in
/// (system) fields only the label is editable; custom fields expose type,
/// required, and the options list (for choice types).
void showFieldEditorSheet(
  BuildContext context,
  ManagerApplicationFileController controller,
  ApplyFormSectionType type, {
  ApplyFieldConfig? existing,
}) {
  final isSystem = existing?.isSystem ?? false;
  final labelCtrl = TextEditingController(
    text: existing == null ? '' : resolveFieldLabel(existing),
  );
  final optionCtrl = TextEditingController();

  var fieldType = existing?.type ?? ApplyFieldType.text;
  var required = existing?.required ?? false;
  final options = List<String>.from(existing?.options ?? const <String>[]);

  // Types a manager may pick for a custom field (photo is system-only).
  const selectable = [
    ApplyFieldType.text,
    ApplyFieldType.number,
    ApplyFieldType.phone,
    ApplyFieldType.date,
    ApplyFieldType.dropdown,
    ApplyFieldType.radio,
    ApplyFieldType.checkbox,
    ApplyFieldType.toggle,
  ];

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: StatefulBuilder(
          builder: (ctx, setSheet) {
            void addOption() {
              final v = optionCtrl.text.trim();
              if (v.isEmpty || options.contains(v)) return;
              setSheet(() => options.add(v));
              optionCtrl.clear();
            }

            void save() {
              final label = labelCtrl.text.trim();
              if (label.isEmpty) {
                Loader.showError('manager_apply_field_name_required'.tr);
                return;
              }
              if (!isSystem &&
                  fieldType.hasOptions &&
                  options.isEmpty) {
                Loader.showError('manager_apply_field_options_required'.tr);
                return;
              }
              if (existing == null) {
                controller.addField(
                  type,
                  ApplyFieldConfig.create(
                    label: label,
                    type: fieldType,
                    required: required,
                    options: fieldType.hasOptions ? options : const [],
                  ),
                );
              } else {
                // System fields: relabel only (and required when not locked).
                controller.updateField(
                  type,
                  existing.copyWith(
                    label: label,
                    type: isSystem ? null : fieldType,
                    required: existing.isLocked ? null : required,
                    options: isSystem
                        ? null
                        : (fieldType.hasOptions ? options : const []),
                  ),
                );
              }
              Get.back();
            }

            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: existing == null
                          ? 'manager_apply_add_field'.tr
                          : 'manager_apply_edit_field'.tr,
                      textStyle: context.typography.smSemiBold
                          .copyWith(color: AppColors.textPrimaryParagraph),
                    ),
                    if (isSystem) ...[
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Icon(Icons.lock_outline_rounded,
                              size: 13.sp, color: AppColors.grayMedium),
                          SizedBox(width: 5.w),
                          AppText(
                            text: 'manager_apply_field_locked'.tr,
                            textStyle: context.typography.xsRegular
                                .copyWith(color: AppColors.grayMedium),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 14.h),
                    AppText(
                      text: 'manager_apply_field_label'.tr,
                      textStyle: context.typography.smSemiBold
                          .copyWith(color: AppColors.textPrimaryParagraph),
                    ),
                    SizedBox(height: 8.h),
                    AppTextField(
                      controller: labelCtrl,
                      hintText: 'manager_apply_field_label_hint'.tr,
                    ),
                    if (!isSystem) ...[
                      SizedBox(height: 16.h),
                      AppText(
                        text: 'manager_apply_field_type'.tr,
                        textStyle: context.typography.smSemiBold
                            .copyWith(color: AppColors.textPrimaryParagraph),
                      ),
                      SizedBox(height: 8.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: selectable.map((t) {
                          final sel = t == fieldType;
                          return GestureDetector(
                            onTap: () => setSheet(() => fieldType = t),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: sel
                                    ? AppColors.primary
                                    : AppColors.background,
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: sel
                                      ? AppColors.primary
                                      : AppColors.grayLight,
                                ),
                              ),
                              child: AppText(
                                text: 'field_type_${t.id}'.tr,
                                textStyle: context.typography.xsMedium.copyWith(
                                  color:
                                      sel ? AppColors.white : AppColors.textDefault,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                    if (!isSystem && fieldType.hasOptions) ...[
                      SizedBox(height: 16.h),
                      AppText(
                        text: 'manager_apply_field_options'.tr,
                        textStyle: context.typography.smSemiBold
                            .copyWith(color: AppColors.textPrimaryParagraph),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: AppTextField(
                              controller: optionCtrl,
                              hintText: 'manager_apply_field_option_hint'.tr,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          GestureDetector(
                            onTap: addOption,
                            child: Container(
                              width: 48.w,
                              height: 48.h,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child:
                                  Icon(Icons.add_rounded, color: AppColors.white),
                            ),
                          ),
                        ],
                      ),
                      if (options.isNotEmpty) ...[
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: options
                              .map((o) => Chip(
                                    label: Text(o),
                                    onDeleted: () =>
                                        setSheet(() => options.remove(o)),
                                    backgroundColor: AppColors.background,
                                  ))
                              .toList(),
                        ),
                      ],
                    ],
                    if (!(existing?.isLocked ?? false) &&
                        fieldType != ApplyFieldType.toggle) ...[
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          Expanded(
                            child: AppText(
                              text: 'manager_apply_field_required'.tr,
                              textStyle: context.typography.smMedium.copyWith(
                                  color: AppColors.textPrimaryParagraph),
                            ),
                          ),
                          Switch.adaptive(
                            value: required,
                            activeThumbColor: AppColors.primary,
                            onChanged: (v) => setSheet(() => required = v),
                          ),
                        ],
                      ),
                    ],
                    SizedBox(height: 16.h),
                    SizedBox(
                      width: double.infinity,
                      child: PrimaryTextButton(
                        appButtonSize: AppButtonSize.large,
                        onTap: save,
                        label: AppText(
                          text: 'manager_apply_field_save'.tr,
                          textStyle: context.typography.smSemiBold
                              .copyWith(color: AppColors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ),
  );
}

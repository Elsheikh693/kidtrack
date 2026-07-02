import '../../../../../index/index_main.dart';

/// Resolves a field's display label: a pre-resolved [label] (the manager's
/// custom name) wins, otherwise the localization [labelKey] is translated.
String resolveApplyLabel(String? label, String? labelKey) =>
    (label != null && label.isNotEmpty) ? label : (labelKey ?? '').tr;

/// Small heading shown at the top of each wizard step.
class ApplyStepHeader extends StatelessWidget {
  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  const ApplyStepHeader({
    super.key,
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: titleKey.tr,
                    textStyle: context.typography.mdBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                  AppText(
                    text: subtitleKey.tr,
                    textStyle: context.typography.xsRegular
                        .copyWith(color: AppColors.textSecondaryParagraph),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
      ],
    );
  }
}

/// A labelled text field with consistent spacing for the wizard. Pass either a
/// localization [labelKey] or a pre-resolved [label] (manager's custom name).
class ApplyField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelKey;
  final String? label;
  final TextInputType? keyboardType;
  final int maxLines;
  final FocusNode? focusNode;
  const ApplyField({
    super.key,
    required this.controller,
    this.labelKey,
    this.label,
    this.keyboardType,
    this.maxLines = 1,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: AppTextField(
        controller: controller,
        labelText: resolveApplyLabel(label, labelKey),
        keyboardType: keyboardType,
        maxLines: maxLines,
        focusNode: focusNode,
      ),
    );
  }
}

/// A horizontal set of single-select choice chips. [options] maps each stored
/// value to its display text; set [translateValues] when those are localization
/// keys (e.g. gender). Pass [labelKey] or a pre-resolved [label].
class ApplyChoiceChips extends StatelessWidget {
  final String? labelKey;
  final String? label;
  final Map<String, String> options; // value -> label (key or raw)
  final String? selected;
  final ValueChanged<String> onSelect;
  final bool translateValues;
  const ApplyChoiceChips({
    super.key,
    this.labelKey,
    this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
    this.translateValues = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: resolveApplyLabel(label, labelKey),
            textStyle: context.typography.xsMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: options.entries.map((e) {
              final isSel = selected == e.key;
              return GestureDetector(
                onTap: () => onSelect(e.key),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
                  decoration: BoxDecoration(
                    color: isSel
                        ? AppColors.primary
                        : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AppText(
                    text: translateValues ? e.value.tr : e.value,
                    textStyle: context.typography.smMedium.copyWith(
                      color: isSel ? AppColors.white : AppColors.primary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// A multi-select chip group (the checkbox field type). [selected] holds the
/// chosen raw values; tapping a chip toggles it.
class ApplyMultiChips extends StatelessWidget {
  final String label;
  final List<String> options;
  final List<String> selected;
  final ValueChanged<String> onToggle;
  const ApplyMultiChips({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            text: label,
            textStyle: context.typography.xsMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: options.map((o) {
              final isSel = selected.contains(o);
              return GestureDetector(
                onTap: () => onToggle(o),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 9.h),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.primary : AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSel
                            ? Icons.check_box_rounded
                            : Icons.check_box_outline_blank_rounded,
                        size: 16.sp,
                        color: isSel ? AppColors.white : AppColors.primary,
                      ),
                      SizedBox(width: 6.w),
                      AppText(
                        text: o,
                        textStyle: context.typography.smMedium.copyWith(
                          color: isSel ? AppColors.white : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// A yes/no row (the toggle field type).
class ApplyToggleField extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const ApplyToggleField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          Expanded(
            child: AppText(
              text: label,
              textStyle: context.typography.smMedium
                  .copyWith(color: AppColors.textDefault),
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: AppColors.primary,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

/// A labelled single-select dropdown for the wizard.
class ApplyDropdown extends StatelessWidget {
  final String? labelKey;
  final String? label;
  final List<String> options;
  final String? value;
  final ValueChanged<String> onChanged;
  const ApplyDropdown({
    super.key,
    this.labelKey,
    this.label,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: AppDropdown<String>(
        labelText: resolveApplyLabel(label, labelKey),
        value: (value ?? '').isEmpty ? null : value,
        isExpanded: true,
        items: options
            .map((o) => DropdownMenuItem<String>(value: o, child: Text(o)))
            .toList(),
        onChanged: (v) {
          if (v != null) onChanged(v);
        },
      ),
    );
  }
}

/// A read-only field that opens a date picker for the child's birth date.
class ApplyDateField extends StatelessWidget {
  final String? labelKey;
  final String? label;
  final DateTime? value;
  final ValueChanged<DateTime> onPicked;
  const ApplyDateField({
    super.key,
    this.labelKey,
    this.label,
    required this.value,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    final text = value == null
        ? ''
        : '${value!.year}/${value!.month.toString().padLeft(2, '0')}/${value!.day.toString().padLeft(2, '0')}';
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: AppTextField(
        controller: TextEditingController(text: text),
        labelText: resolveApplyLabel(label, labelKey),
        readOnly: true,
        suffixIcon: Icon(Icons.calendar_today_rounded,
            size: 18.sp, color: AppColors.primary60),
        ontap: () async {
          final now = DateTime.now();
          final picked = await showAppDatePicker(
            context,
            initialDate: value ?? DateTime(now.year - 3),
            minimumDate: DateTime(now.year - 15),
            maximumDate: now,
          );
          if (picked != null) onPicked(picked);
        },
      ),
    );
  }
}

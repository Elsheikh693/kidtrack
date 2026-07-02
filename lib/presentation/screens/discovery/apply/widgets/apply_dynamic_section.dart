import '../../../../../index/index_main.dart';
import 'apply_form_parts.dart';

/// Renders a data section (child / father / mother) entirely from the manager's
/// configured field list. Built-in fields bind to the controller's typed state
/// (so account/child provisioning keeps working); custom fields read/write the
/// controller's generic custom-response store. The order, labels, types, and
/// required flags all come from the nursery's form config.
class ApplyDynamicSection extends StatefulWidget {
  final OnlineApplicationController controller;
  final ApplyFormSectionType type;
  final IconData icon;
  final String titleKey;
  final String subtitleKey;
  const ApplyDynamicSection({
    super.key,
    required this.controller,
    required this.type,
    required this.icon,
    required this.titleKey,
    required this.subtitleKey,
  });

  @override
  State<ApplyDynamicSection> createState() => _ApplyDynamicSectionState();
}

class _ApplyDynamicSectionState extends State<ApplyDynamicSection>
    with KeyboardSheetMixin {
  OnlineApplicationController get c => widget.controller;

  @override
  Widget build(BuildContext context) {
    return wrapWithKeyboard(
      context: context,
      child: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        children: [
          ApplyStepHeader(
            icon: widget.icon,
            titleKey: widget.titleKey,
            subtitleKey: widget.subtitleKey,
          ),
          for (final f in c.fieldsFor(widget.type)) _field(context, f),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  String _label(ApplyFieldConfig f) =>
      f.label.isNotEmpty ? f.label : (f.labelKey.isNotEmpty ? f.labelKey.tr : '');

  Widget _field(BuildContext context, ApplyFieldConfig f) {
    // Built-in fields bind to dedicated controller state.
    switch (f.systemRole) {
      case ApplyFieldRoles.childPhoto:
        return _photoPicker(context, _label(f));
      case ApplyFieldRoles.childName:
        return ApplyField(controller: c.childName, label: _label(f));
      case ApplyFieldRoles.childGender:
        return Obx(() => ApplyChoiceChips(
              label: _label(f),
              options: const {
                'male': 'apply_gender_male',
                'female': 'apply_gender_female',
              },
              selected: c.childGender.value,
              onSelect: c.setGender,
            ));
      case ApplyFieldRoles.childDob:
        return Obx(() => ApplyDateField(
              label: _label(f),
              value: c.childDob.value,
              onPicked: c.setDob,
            ));
      case ApplyFieldRoles.childNationality:
        return Obx(() => ApplyDropdown(
              label: _label(f),
              options: kNationalityOptions,
              value: c.childNationality.value,
              onChanged: c.setNationality,
            ));
      case ApplyFieldRoles.childBlood:
        return Obx(() => ApplyChoiceChips(
              label: _label(f),
              options: {for (final b in kBloodTypeOptions) b: b},
              selected: c.childBloodType.value,
              onSelect: c.setBloodType,
              translateValues: false,
            ));
      case ApplyFieldRoles.childAddress:
        return ApplyField(
            controller: c.childAddress, label: _label(f), maxLines: 2);
      case ApplyFieldRoles.fatherName:
        return ApplyField(controller: c.fatherName, label: _label(f));
      case ApplyFieldRoles.fatherPhone:
        return ApplyField(
            controller: c.fatherPhone,
            label: _label(f),
            keyboardType: TextInputType.phone);
      case ApplyFieldRoles.fatherJob:
        return ApplyField(controller: c.fatherJob, label: _label(f));
      case ApplyFieldRoles.fatherNationalId:
        return ApplyField(
            controller: c.fatherNationalId,
            label: _label(f),
            keyboardType: TextInputType.number);
      case ApplyFieldRoles.motherName:
        return ApplyField(controller: c.motherName, label: _label(f));
      case ApplyFieldRoles.motherPhone:
        return ApplyField(
            controller: c.motherPhone,
            label: _label(f),
            keyboardType: TextInputType.phone);
      case ApplyFieldRoles.motherJob:
        return ApplyField(controller: c.motherJob, label: _label(f));
      case ApplyFieldRoles.motherNationalId:
        return ApplyField(
            controller: c.motherNationalId,
            label: _label(f),
            keyboardType: TextInputType.number);
    }
    // Custom manager-added field.
    return _customField(context, f);
  }

  Widget _customField(BuildContext context, ApplyFieldConfig f) {
    final label = _label(f);
    switch (f.type) {
      case ApplyFieldType.number:
        return ApplyField(
            controller: c.customController(f.id),
            label: label,
            keyboardType: TextInputType.number);
      case ApplyFieldType.phone:
        return ApplyField(
            controller: c.customController(f.id),
            label: label,
            keyboardType: TextInputType.phone);
      case ApplyFieldType.date:
        return Obx(() {
          final millis = c.customValue(f.id);
          return ApplyDateField(
            label: label,
            value: millis is int
                ? DateTime.fromMillisecondsSinceEpoch(millis)
                : null,
            onPicked: (d) =>
                c.setCustomValue(f.id, d.millisecondsSinceEpoch),
          );
        });
      case ApplyFieldType.dropdown:
        return Obx(() => ApplyDropdown(
              label: label,
              options: f.options,
              value: c.customValue(f.id)?.toString(),
              onChanged: (v) => c.setCustomValue(f.id, v),
            ));
      case ApplyFieldType.radio:
        return Obx(() => ApplyChoiceChips(
              label: label,
              options: {for (final o in f.options) o: o},
              selected: c.customValue(f.id)?.toString(),
              onSelect: (v) => c.setCustomValue(f.id, v),
              translateValues: false,
            ));
      case ApplyFieldType.checkbox:
        return Obx(() => ApplyMultiChips(
              label: label,
              options: f.options,
              selected: (c.customValue(f.id) as List?)?.cast<String>() ??
                  const [],
              onToggle: (o) => c.toggleCustomOption(f.id, o),
            ));
      case ApplyFieldType.toggle:
        return Obx(() => ApplyToggleField(
              label: label,
              value: c.customValue(f.id) == true,
              onChanged: (v) => c.setCustomValue(f.id, v),
            ));
      case ApplyFieldType.text:
      case ApplyFieldType.photo:
        return ApplyField(controller: c.customController(f.id), label: label);
    }
  }

  Widget _photoPicker(BuildContext context, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 18.h),
      child: Center(
        child: Column(
          children: [
            Obx(() {
              final url = c.childPhoto.value;
              final uploading = c.isUploadingPhoto.value;
              return GestureDetector(
                onTap: c.pickChildPhoto,
                child: Stack(
                  children: [
                    Container(
                      width: 110.w,
                      height: 110.w,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.primary, width: 1.5),
                        image: (url != null && url.isNotEmpty)
                            ? DecorationImage(
                                image: appCachedImageProvider(url),
                                fit: BoxFit.cover)
                            : null,
                      ),
                      child: uploading
                          ? const Center(child: CircularProgressIndicator())
                          : (url == null || url.isEmpty)
                              ? Icon(Icons.add_a_photo_rounded,
                                  color: AppColors.primary, size: 32.sp)
                              : null,
                    ),
                    if (url != null && url.isNotEmpty && !uploading)
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.white, width: 2),
                          ),
                          child: Icon(Icons.edit_rounded,
                              color: AppColors.white, size: 14.sp),
                        ),
                      ),
                  ],
                ),
              );
            }),
            SizedBox(height: 8.h),
            AppText(
              text: label,
              textStyle: context.typography.smSemiBold
                  .copyWith(color: AppColors.textDefault),
            ),
            SizedBox(height: 2.h),
            AppText(
              text: 'apply_child_photo_hint'.tr,
              textStyle: context.typography.xsRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

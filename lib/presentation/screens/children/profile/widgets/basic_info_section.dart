import '../../../../../index/index_main.dart';
import 'child_shift_sheet.dart';

class BasicInfoSection extends StatelessWidget {
  final ChildProfileController controller;
  const BasicInfoSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final child = controller.child.value;
    if (child == null) return const SizedBox.shrink();
    return ProfileSectionCard(
      title: 'child_profile_basic_info'.tr,
      actionLabel: 'child_details_edit_action'.tr,
      onAction: () => showChildDetailsSheet(
        child: child,
        onSaved: controller.loadProfile,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            ProfileInfoRow(
              label: 'child_profile_dob'.tr,
              value: _formatDate(child.dateOfBirth),
            ),
            ProfileInfoRow(
              label: 'child_profile_gender'.tr,
              value: _gender(child.gender),
            ),
            ProfileInfoRow(
              label: 'child_profile_blood_type'.tr,
              value: child.bloodType ?? '--',
            ),
            ProfileInfoRow(
              label: 'child_profile_nationality'.tr,
              value: child.nationality ?? '--',
            ),
            ProfileInfoRow(
              label: 'child_profile_address'.tr,
              value: (child.homeAddress?.trim().isNotEmpty ?? false)
                  ? child.homeAddress!.trim()
                  : '--',
            ),
            _shiftRow(context, child),
          ],
        ),
      ),
    );
  }

  Widget _shiftRow(BuildContext context, ChildModel child) {
    final value = _shiftLabel(child.shift);
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              'child_profile_shift'.tr,
              style: context.typography.xsRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: context.typography.xsRegular
                  .copyWith(color: AppColors.textDefault),
            ),
          ),
          if (controller.canEditShift)
            Icon(Icons.edit_outlined,
                size: 16, color: AppColors.textSecondaryParagraph),
        ],
      ),
    );
    if (!controller.canEditShift) return row;
    return InkWell(
      onTap: () => showChildShiftSheet(
        controller: controller,
        currentShift: child.shift,
      ),
      child: row,
    );
  }

  String _shiftLabel(String? shift) {
    final name = controller.shiftName(shift);
    return name.isNotEmpty ? name : '--';
  }

  String _formatDate(int? ts) {
    if (ts == null) return '--';
    final d = DateTime.fromMillisecondsSinceEpoch(ts);
    return '${d.day}/${d.month}/${d.year}';
  }

  String _gender(String? g) {
    if (g == 'male') return 'child_profile_gender_male'.tr;
    if (g == 'female') return 'child_profile_gender_female'.tr;
    return '--';
  }
}

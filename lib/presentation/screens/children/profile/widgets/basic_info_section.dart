import '../../../../../index/index_main.dart';

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
          ],
        ),
      ),
    );
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

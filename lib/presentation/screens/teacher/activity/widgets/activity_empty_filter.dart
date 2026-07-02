import '../../../../../index/index_main.dart';

class ActivityEmptyFilter extends StatelessWidget {
  const ActivityEmptyFilter({
    super.key,
    required this.ctrl,
    required this.searchCtrl,
  });

  final TeacherActivityController ctrl;
  final TextEditingController searchCtrl;

  @override
  Widget build(BuildContext context) {
    final isSearching = searchCtrl.text.isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.backgroundNeutralDefault,
            shape: BoxShape.circle,
          ),
          child: Icon(
            isSearching ? Icons.search_off_rounded : Icons.filter_list_off_rounded,
            size: 44,
            color: AppColors.grayMedium,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          isSearching
              ? 'teacher_activity_no_search'.tr
              : 'teacher_activity_no_filter'.tr,
          style: context.typography.mdBold
              .copyWith(color: AppColors.textSecondaryParagraph),
        ),
        const SizedBox(height: 4),
        Text(
          isSearching
              ? 'teacher_activity_no_search_sub'.tr
              : 'teacher_activity_no_filter_sub'.tr,
          style: context.typography.xsMedium.copyWith(color: AppColors.grayMedium),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            searchCtrl.clear();
            ctrl.evalFilter.value = EvalFilter.all;
          },
          child: Text(
            'teacher_activity_clear_filter'.tr,
            style: context.typography.smMedium
                .copyWith(color: AppColors.activityGreen),
          ),
        ),
      ],
    );
  }
}

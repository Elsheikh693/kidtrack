import '../../../../../index/index_main.dart';

/// Search field that filters the Staff directory (debounced in controller).
class StaffSearchBar extends StatelessWidget {
  const StaffSearchBar({super.key, required this.controller});

  final ManagerStaffController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: controller.onSearch,
      style: context.typography.smRegular.copyWith(color: AppColors.textDefault),
      decoration: InputDecoration(
        hintText: 'manager_staff_search_hint'.tr,
        hintStyle: context.typography.smRegular
            .copyWith(color: AppColors.fieldTextPlaceholder),
        prefixIcon: Icon(Icons.search_rounded,
            color: AppColors.grayMedium, size: 20),
        filled: true,
        fillColor: AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.grayLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.grayLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: AppColors.activityBlue, width: 1.4),
        ),
      ),
    );
  }
}

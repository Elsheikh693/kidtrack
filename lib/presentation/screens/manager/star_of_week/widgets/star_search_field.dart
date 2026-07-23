import '../../../../../index/index_main.dart';
import '../star_of_week_controller.dart';

/// Search box for filtering the branch's children by name.
class StarSearchField extends StatelessWidget {
  const StarSearchField({super.key, required this.controller});

  final StarOfWeekController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 6.h),
      child: TextField(
        controller: controller.searchController,
        onChanged: controller.onSearchChanged,
        style: context.typography.smRegular
            .copyWith(color: AppColors.textDefault),
        decoration: InputDecoration(
          hintText: 'sotw_search_hint'.tr,
          hintStyle: context.typography.smRegular
              .copyWith(color: AppColors.textSecondaryParagraph),
          prefixIcon: const Icon(Icons.search_rounded,
              color: AppColors.textSecondaryParagraph),
          filled: true,
          fillColor: AppColors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

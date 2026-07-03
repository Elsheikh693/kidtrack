import '../../../../../index/index_main.dart';

/// Dropdown that lets the manager tag the nursery with a city from the global
/// SuperAdmin-managed list. Powers the Discovery city filter.
class ProfileCitySelector extends StatelessWidget {
  final ManagerNurseryProfileController controller;
  const ProfileCitySelector({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cities = controller.cities;
      if (cities.isEmpty) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundNeutral100,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
            ),
          ),
          child: AppText(
            text: 'manager_profile_city_empty'.tr,
            textStyle: context.typography.smMedium
                .copyWith(color: AppColors.grayMedium),
          ),
        );
      }

      final selectedId =
          cities.any((c) => c.key == controller.cityId.value)
              ? controller.cityId.value
              : null;

      return Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundNeutral100,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedId,
            isExpanded: true,
            icon: Icon(Icons.expand_more_rounded,
                size: 20.sp, color: AppColors.grayMedium),
            hint: AppText(
              text: 'manager_profile_city_hint'.tr,
              textStyle: context.typography.smMedium
                  .copyWith(color: AppColors.grayMedium),
            ),
            borderRadius: BorderRadius.circular(12.r),
            items: cities
                .map((c) => DropdownMenuItem<String>(
                      value: c.key,
                      child: Row(
                        children: [
                          Icon(Icons.location_city_rounded,
                              size: 18.sp, color: AppColors.primary),
                          SizedBox(width: 8.w),
                          AppText(
                            text: c.name,
                            textStyle: context.typography.smMedium
                                .copyWith(color: AppColors.textPrimaryParagraph),
                          ),
                        ],
                      ),
                    ))
                .toList(),
            onChanged: (id) {
              final city = cities.firstWhereOrNull((c) => c.key == id);
              controller.setCity(city);
            },
          ),
        ),
      );
    });
  }
}

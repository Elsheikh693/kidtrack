import 'package:flutter/cupertino.dart';
import '../../../../../index/index_main.dart';

/// Human label for an age expressed in months, e.g. "2 سنة و3 شهور" / "8 شهر".
String ageMonthsLabel(int? months) {
  if (months == null) return 'manager_profile_age_unset'.tr;
  final y = months ~/ 12;
  final m = months % 12;
  if (y > 0 && m > 0) {
    return 'age_years_months'.trParams({'y': '$y', 'm': '$m'});
  }
  if (y > 0) return 'age_years'.trParams({'n': '$y'});
  return 'age_months'.trParams({'n': '$m'});
}

/// Accepted age-range editor. Stores months on the controller; the manager
/// picks years + months via a wheel sheet so they never type raw numbers.
class ProfileAgeEditor extends StatelessWidget {
  const ProfileAgeEditor({super.key, required this.controller});
  final ManagerNurseryProfileController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _AgeBox(
              label: 'manager_profile_age_from'.tr,
              value: ageMonthsLabel(controller.minAgeMonths.value),
              onTap: () => _pick(
                context,
                controller.minAgeMonths.value ?? 6,
                (y, m) => controller.setMinAge(y, m),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _AgeBox(
              label: 'manager_profile_age_to'.tr,
              value: ageMonthsLabel(controller.maxAgeMonths.value),
              onTap: () => _pick(
                context,
                controller.maxAgeMonths.value ?? 60,
                (y, m) => controller.setMaxAge(y, m),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pick(
    BuildContext context,
    int initialMonths,
    void Function(int years, int months) onPicked,
  ) {
    showAgePickerSheet(
      context,
      initialMonths: initialMonths,
      onPicked: (total) => onPicked(total ~/ 12, total % 12),
    );
  }
}

class _AgeBox extends StatelessWidget {
  const _AgeBox({required this.label, required this.value, required this.onTap});
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.typography.xsRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
          SizedBox(height: 6.h),
          Container(
            height: 52.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            decoration: BoxDecoration(
              color: AppColors.backgroundNeutral100,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.child_care_rounded,
                    size: 18.sp, color: AppColors.primary),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    value,
                    style: context.typography.smMedium
                        .copyWith(color: AppColors.textPrimaryParagraph),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.expand_more_rounded,
                    size: 18.sp, color: AppColors.grayMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal wheel picker for years (0–10) + months (0–11).
void showAgePickerSheet(
  BuildContext context, {
  required int initialMonths,
  required ValueChanged<int> onPicked,
}) {
  int years = (initialMonths ~/ 12).clamp(0, 10);
  int months = initialMonths % 12;
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'manager_profile_age_pick_title'.tr,
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.textPrimaryParagraph),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 160.h,
                child: Row(
                  children: [
                    Expanded(
                      child: _Wheel(
                        unit: 'age_unit_years'.tr,
                        count: 11,
                        initial: years,
                        onChanged: (v) => years = v,
                      ),
                    ),
                    Expanded(
                      child: _Wheel(
                        unit: 'age_unit_months'.tr,
                        count: 12,
                        initial: months,
                        onChanged: (v) => months = v,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: PrimaryTextButton(
                  appButtonSize: AppButtonSize.large,
                  onTap: () {
                    onPicked(years * 12 + months);
                    Get.back();
                  },
                  label: AppText(
                    text: 'common_done'.tr,
                    textStyle: context.typography.smSemiBold
                        .copyWith(color: AppColors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _Wheel extends StatelessWidget {
  const _Wheel({
    required this.unit,
    required this.count,
    required this.initial,
    required this.onChanged,
  });
  final String unit;
  final int count;
  final int initial;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return CupertinoPicker(
      scrollController: FixedExtentScrollController(initialItem: initial),
      itemExtent: 38,
      onSelectedItemChanged: onChanged,
      children: List.generate(
        count,
        (i) => Center(
          child: Text(
            '$i $unit',
            style: context.typography.smMedium
                .copyWith(color: AppColors.textPrimaryParagraph),
          ),
        ),
      ),
    );
  }
}

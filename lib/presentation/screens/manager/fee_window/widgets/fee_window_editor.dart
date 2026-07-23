import 'package:flutter/cupertino.dart';
import '../../../../../index/index_main.dart';

/// Human label for a chosen day-of-month, e.g. "يوم 5"; unset shows a hint.
String _feeDayLabel(int? day) => day == null
    ? 'manager_profile_fee_day_unset'.tr
    : 'manager_profile_fee_day_value'.trParams({'d': '$day'});

/// Editor for the monthly fee-collection window (day-of-month from/to), bound
/// to [FeeCollectionWindowService]. Each pick persists immediately; a "turn
/// off" action clears both bounds.
class FeeWindowEditor extends StatelessWidget {
  const FeeWindowEditor({super.key, required this.service});
  final FeeCollectionWindowService service;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _DayBox(
                  label: 'manager_profile_fee_from'.tr,
                  value: _feeDayLabel(service.fromDay.value),
                  onTap: () => _pick(
                    context,
                    service.fromDay.value ?? 1,
                    service.setFromDay,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _DayBox(
                  label: 'manager_profile_fee_to'.tr,
                  value: _feeDayLabel(service.toDay.value),
                  onTap: () => _pick(
                    context,
                    service.toDay.value ?? 5,
                    service.setToDay,
                  ),
                ),
              ),
            ],
          ),
          if (service.fromDay.value != null ||
              service.toDay.value != null) ...[
            SizedBox(height: 12.h),
            GestureDetector(
              onTap: () async {
                final ok = await service.clearWindow();
                if (!ok) Loader.showError('common_error'.tr);
              },
              child: Row(
                children: [
                  Icon(Icons.notifications_off_rounded,
                      size: 16.sp, color: AppColors.errorForeground),
                  SizedBox(width: 6.w),
                  Text(
                    'manager_profile_fee_disable'.tr,
                    style: context.typography.xsMedium
                        .copyWith(color: AppColors.errorForeground),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pick(
    BuildContext context,
    int initial,
    Future<bool> Function(int) onPicked,
  ) async {
    _showDayPickerSheet(
      context,
      initial: initial,
      onPicked: (day) async {
        final ok = await onPicked(day);
        if (!ok) Loader.showError('common_error'.tr);
      },
    );
  }
}

class _DayBox extends StatelessWidget {
  const _DayBox({required this.label, required this.value, required this.onTap});
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
                Icon(Icons.event_rounded, size: 18.sp, color: AppColors.primary),
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

/// Modal wheel picker for a day of the month (1–28).
void _showDayPickerSheet(
  BuildContext context, {
  required int initial,
  required ValueChanged<int> onPicked,
}) {
  int day = initial.clamp(1, 28);
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    builder: (ctx) => Directionality(
      textDirection: appTextDirection,
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'manager_profile_fee_pick_title'.tr,
                style: context.typography.smSemiBold
                    .copyWith(color: AppColors.textPrimaryParagraph),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 160.h,
                child: CupertinoPicker(
                  scrollController:
                      FixedExtentScrollController(initialItem: day - 1),
                  itemExtent: 38,
                  onSelectedItemChanged: (v) => day = v + 1,
                  children: List.generate(
                    28,
                    (i) => Center(
                      child: Text(
                        'manager_profile_fee_day_value'
                            .trParams({'d': '${i + 1}'}),
                        style: context.typography.smMedium
                            .copyWith(color: AppColors.textPrimaryParagraph),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: PrimaryTextButton(
                  appButtonSize: AppButtonSize.large,
                  onTap: () {
                    onPicked(day);
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

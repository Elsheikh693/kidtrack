import '../../../../../index/index_main.dart';
import 'discovery_filter_sheet.dart';
import 'discovery_sort_sheet.dart';

/// Compact filter + sort bar shown above the results. Opens the rich filter
/// sheet (age / price / distance) and the sort sheet, and surfaces a count
/// badge when filters are active.
class DiscoveryFilterBar extends StatelessWidget {
  final DiscoveryController controller;

  const DiscoveryFilterBar({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          Expanded(
            child: Obx(
              () => _BarButton(
                icon: Icons.tune_rounded,
                label: 'discovery_filter_title'.tr,
                highlighted: controller.activeFilterCount > 0,
                onTap: () => showDiscoveryFilterSheet(controller),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Obx(
              () => _BarButton(
                label: controller.sort.value == null
                    ? 'discovery_sort_title'.tr
                    : _sortLabel(controller.sort.value!),
                highlighted: controller.sort.value != null,
                onTap: () => showDiscoverySortSheet(controller),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _sortLabel(DiscoverySort s) {
    switch (s) {
      case DiscoverySort.nearest:
        return 'discovery_sort_nearest'.tr;
      case DiscoverySort.lowestPrice:
        return 'discovery_sort_lowest_price'.tr;
      case DiscoverySort.highestRated:
        return 'discovery_sort_highest_rated'.tr;
      case DiscoverySort.mostPopular:
        return 'discovery_sort_most_popular'.tr;
    }
  }
}

class _BarButton extends StatelessWidget {
  final IconData? icon;
  final String label;
  final bool highlighted;
  final VoidCallback onTap;

  const _BarButton({
    required this.label,
    required this.onTap,
    this.icon,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final active = highlighted;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary.withValues(alpha: 0.08)
              : AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.grayLight,
            width: active ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 20.sp,
                  color: active ? AppColors.primary : AppColors.textDefault),
              SizedBox(width: 8.w),
            ],
            Flexible(
              child: AppText(
                text: label,
                textStyle: context.typography.smSemiBold.copyWith(
                  color: active ? AppColors.primary : AppColors.textDefault,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

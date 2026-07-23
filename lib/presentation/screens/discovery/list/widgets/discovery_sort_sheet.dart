import '../../../../../index/index_main.dart';

/// Sort options sheet for Discovery. `null` = default (name A→Z).
void showDiscoverySortSheet(DiscoveryController controller) {
  Get.bottomSheet(
    _SortSheet(controller: controller),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  );
}

class _SortSheet extends StatelessWidget {
  final DiscoveryController controller;
  const _SortSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.grayLight,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            AppText(
              text: 'discovery_sort_title'.tr,
              textStyle: context.typography.mdBold
                  .copyWith(color: AppColors.textDefault),
            ),
            SizedBox(height: 16.h),
            Obx(() {
              final s = controller.sort.value;
              return Column(
                children: [
                  _SortTile(
                    icon: Icons.sort_by_alpha_rounded,
                    label: 'discovery_sort_default'.tr,
                    selected: s == null,
                    onTap: () => _pick(null),
                  ),
                  _SortTile(
                    icon: Icons.near_me_rounded,
                    label: 'discovery_sort_nearest'.tr,
                    selected: s == DiscoverySort.nearest,
                    enabled: controller.hasUserLocation,
                    subtitle: controller.hasUserLocation
                        ? null
                        : 'discovery_sort_nearest_hint'.tr,
                    onTap: () => _pick(DiscoverySort.nearest),
                  ),
                  _SortTile(
                    icon: Icons.trending_down_rounded,
                    label: 'discovery_sort_lowest_price'.tr,
                    selected: s == DiscoverySort.lowestPrice,
                    onTap: () => _pick(DiscoverySort.lowestPrice),
                  ),
                  _SortTile(
                    icon: Icons.star_rounded,
                    label: 'discovery_sort_highest_rated'.tr,
                    selected: s == DiscoverySort.highestRated,
                    onTap: () => _pick(DiscoverySort.highestRated),
                  ),
                  _SortTile(
                    icon: Icons.local_fire_department_rounded,
                    label: 'discovery_sort_most_popular'.tr,
                    selected: s == DiscoverySort.mostPopular,
                    onTap: () => _pick(DiscoverySort.mostPopular),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  void _pick(DiscoverySort? value) {
    controller.setSort(value);
    Get.back();
  }
}

class _SortTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _SortTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.subtitle,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.08)
                : AppColors.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.grayLight,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon,
                  size: 20.sp,
                  color: selected
                      ? AppColors.primary
                      : AppColors.textSecondaryParagraph),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      text: label,
                      textStyle: (selected
                              ? context.typography.smSemiBold
                              : context.typography.smRegular)
                          .copyWith(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textDefault,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      AppText(
                        text: subtitle!,
                        textStyle: context.typography.xsRegular.copyWith(
                            color: AppColors.textSecondaryParagraph),
                      ),
                    ],
                  ],
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded,
                    size: 20.sp, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }
}

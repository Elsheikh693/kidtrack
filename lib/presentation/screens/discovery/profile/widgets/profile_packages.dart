import '../../../../../index/index_main.dart';

/// Compact subscription price list shown inside a branch card (and reused for
/// the fallback "other prices" block). Each row: package name + billing
/// duration on one side, price on the other — with a strike-through original
/// price and an offer badge when a promotion is active.
class BranchPackageList extends StatelessWidget {
  final List<PackageModel> packages;
  const BranchPackageList({super.key, required this.packages});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundNeutral100,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.borderNeutralPrimary.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < packages.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                indent: 12.w,
                endIndent: 12.w,
                color: AppColors.borderNeutralPrimary.withValues(alpha: 0.3),
              ),
            _PackageRow(package: packages[i]),
          ],
        ],
      ),
    );
  }
}

class _PackageRow extends StatelessWidget {
  final PackageModel package;
  const _PackageRow({required this.package});

  @override
  Widget build(BuildContext context) {
    final discounted = package.hasActiveDiscount;
    final currency = 'currency'.tr;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.local_offer_rounded,
              size: 15.sp,
              color: discounted ? AppColors.activityGreen : AppColors.primary60),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  text: package.name,
                  textStyle: context.typography.smMedium
                      .copyWith(color: AppColors.textDefault),
                  maxLines: 1,
                ),
                SizedBox(height: 3.h),
                Row(
                  children: [
                    AppText(
                      text: _durationLabel(package.duration),
                      textStyle: context.typography.xsRegular.copyWith(
                          color: AppColors.textSecondaryParagraph),
                    ),
                    if (discounted) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: AppColors.activityGreen.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: AppText(
                          text: 'discovery_offer_badge'.tr,
                          textStyle: context.typography.xsBold
                              .copyWith(color: AppColors.activityGreen),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (discounted)
                AppText(
                  text: '${package.price.round()} $currency',
                  textStyle: context.typography.xsRegular.copyWith(
                    color: AppColors.textSecondaryParagraph,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              AppText(
                text:
                    '${(discounted ? package.finalPrice : package.price).round()} $currency',
                textStyle: context.typography.smSemiBold.copyWith(
                  color:
                      discounted ? AppColors.activityGreen : AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _durationLabel(String duration) {
    switch (duration) {
      case 'term':
        return 'package_duration_term'.tr;
      case 'yearly':
        return 'package_duration_yearly'.tr;
      case 'oneTime':
        return 'package_duration_oneTime'.tr;
      default:
        return 'package_duration_monthly'.tr;
    }
  }
}

import '../../../../../index/index_main.dart';

/// Tinted KPI tile for analytics reports: a small label on top, a big value
/// below, optional unit suffix — mirrors the executive dashboard tiles but
/// takes a pre-formatted string so callers control money vs. count vs. percent.
class AnalyticsStatTile extends StatelessWidget {
  final String labelKey;
  final String value;
  final String? unitKey;
  final Color color;

  const AnalyticsStatTile({
    super.key,
    required this.labelKey,
    required this.value,
    required this.color,
    this.unitKey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 13.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            labelKey.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.typography.xsMedium.copyWith(
              color: AppColors.textSecondaryParagraph,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: context.typography.lgBold.copyWith(
                    color: color.darken(0.08),
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                if (unitKey != null) ...[
                  SizedBox(width: 4.w),
                  Text(
                    unitKey!.tr,
                    style: context.typography.xsMedium.copyWith(
                      color: color.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

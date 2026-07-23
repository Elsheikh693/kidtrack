import '../../../../../index/index_main.dart';

/// A labelled row with a proportional fill bar and a trailing value — the shared
/// building block for the per-branch / per-room breakdowns across the analytics
/// reports (collection rate, P&L, overdue share, occupancy fill). Values arrive
/// already resolved and formatted, so this stays a pure display primitive.
class AnalyticsBarRow extends StatelessWidget {
  final String label;
  final String trailing;
  final double fill;
  final Color color;
  final String? subtitle;

  const AnalyticsBarRow({
    super.key,
    required this.label,
    required this.trailing,
    required this.fill,
    required this.color,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10.r,
            offset: Offset(0, 3.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                trailing,
                style: context.typography.smSemiBold.copyWith(
                  color: color.darken(0.08),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: 3.h),
            Text(
              subtitle!,
              style: context.typography.xsRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ],
          SizedBox(height: 9.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: fill.clamp(0, 1),
              minHeight: 7.h,
              backgroundColor: color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ],
      ),
    );
  }
}

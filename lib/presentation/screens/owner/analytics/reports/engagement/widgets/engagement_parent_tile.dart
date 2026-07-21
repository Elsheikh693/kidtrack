import '../../../../../../../index/index_main.dart';

/// One parent in the engagement leaderboard: rank, name, and their activity +
/// feed view counts. Pure display of a [ParentModel]'s telemetry.
class EngagementParentTile extends StatelessWidget {
  final int rank;
  final ParentModel parent;

  const EngagementParentTile({
    super.key,
    required this.rank,
    required this.parent,
  });

  static const _pink = Color(0xFFEC4899);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.w),
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
      child: Row(
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _pink.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(
              '$rank',
              style: context.typography.smSemiBold
                  .copyWith(color: _pink.darken(0.1), fontWeight: FontWeight.w900),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              parent.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.smSemiBold
                  .copyWith(color: AppColors.textDefault),
            ),
          ),
          _metric(context, Icons.play_circle_outline_rounded,
              parent.activityViews),
          SizedBox(width: 12.w),
          _metric(context, Icons.dynamic_feed_outlined, parent.feedViews),
        ],
      ),
    );
  }

  Widget _metric(BuildContext context, IconData icon, int value) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: AppColors.textSecondaryParagraph),
          SizedBox(width: 4.w),
          Text(
            '$value',
            style: context.typography.xsMedium
                .copyWith(color: AppColors.textDefault, fontWeight: FontWeight.w700),
          ),
        ],
      );
}

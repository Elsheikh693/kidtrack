import '../../../../../../../index/index_main.dart';
import '../../../../executive/models/branch_health.dart';

/// One branch in the Health Ranking: its rank, name, 0–100 score with band
/// colour, and the explainable 4-component breakdown as labelled mini-bars, so
/// the owner always sees WHY a branch scored what it did.
class HealthRankCard extends StatelessWidget {
  final int rank;
  final BranchHealthScore score;

  const HealthRankCard({super.key, required this.rank, required this.score});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: score.color.withValues(alpha: 0.18)),
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
              _rankChip(context),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  score.branchName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
              ),
              _scorePill(context),
            ],
          ),
          SizedBox(height: 14.h),
          for (final c in score.breakdown.components) ...[
            _component(context, c),
            SizedBox(height: 9.h),
          ],
        ],
      ),
    );
  }

  Widget _rankChip(BuildContext context) => Container(
        width: 30.w,
        height: 30.w,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: score.color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Text(
          '$rank',
          style: context.typography.smSemiBold
              .copyWith(color: score.color.darken(0.1), fontWeight: FontWeight.w900),
        ),
      );

  Widget _scorePill(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: score.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${score.scoreRounded}',
              style: context.typography.smSemiBold.copyWith(
                color: score.color.darken(0.08),
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(width: 5.w),
            Text(
              score.bandKey.tr,
              style: context.typography.xsMedium.copyWith(color: score.color),
            ),
          ],
        ),
      );

  Widget _component(BuildContext context, HealthComponent c) => Row(
        children: [
          SizedBox(
            width: 78.w,
            child: Text(
              c.labelKey.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.typography.xsRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: LinearProgressIndicator(
                value: c.fill,
                minHeight: 6.h,
                backgroundColor: score.color.withValues(alpha: 0.10),
                valueColor: AlwaysStoppedAnimation(score.color),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '${c.earned.round()}/${c.max.round()}',
            style: context.typography.xsMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      );
}

import '../../../../../../../index/index_main.dart';

/// One withdrawn child in the churn list: name, exit reason (label + optional
/// note) and the withdrawal date. Pure display of a [WithdrawalLogModel].
class ChurnChildTile extends StatelessWidget {
  final WithdrawalLogModel entry;

  const ChurnChildTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final d = entry.withdrawnDate;
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(13.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFFF97316).withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_off_rounded,
                color: const Color(0xFFF97316), size: 19.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.childName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
                if (entry.hasReason) ...[
                  SizedBox(height: 3.h),
                  Text(
                    entry.reasonNote.isEmpty
                        ? entry.reasonLabel
                        : '${entry.reasonLabel} — ${entry.reasonNote}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.typography.xsRegular
                        .copyWith(color: AppColors.textSecondaryParagraph),
                  ),
                ],
              ],
            ),
          ),
          if (d != null) ...[
            SizedBox(width: 8.w),
            Text(
              '${d.day}/${d.month}',
              style: context.typography.xsMedium
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ],
        ],
      ),
    );
  }
}

import '../../index/index_main.dart';

/// One row in the monthly-withdrawals list: the (now-deleted) child's name, the
/// reason they left, and the withdrawal date. The child is hard-deleted on
/// withdrawal, so there is no photo — [ChildAvatar] renders the initial fallback.
class WithdrawnChildTile extends StatelessWidget {
  const WithdrawnChildTile({super.key, required this.entry});

  final WithdrawalLogModel entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChildAvatar(
            name: entry.childName,
            size: 42,
            color: AppColors.activityRed,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.childName.isEmpty
                      ? 'manager_children_unknown_child'.tr
                      : entry.childName,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  entry.hasReason ? entry.reasonLabel : 'withdrawn_reason_none'.tr,
                  style: context.typography.smRegular
                      .copyWith(color: AppColors.activityRed),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (entry.reasonNote.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.reasonNote,
                    style: context.typography.xsRegular
                        .copyWith(color: AppColors.textSecondaryParagraph),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDate(entry.withdrawnDate),
            style: context.typography.xsMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '';
    final day = d.day.toString().padLeft(2, '0');
    final month = d.month.toString().padLeft(2, '0');
    return '$day/$month';
  }
}

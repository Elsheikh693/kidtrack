import '../../index/index_main.dart';
import 'withdrawn_child_tile.dart';

/// Bottom sheet listing the children withdrawn from the nursery this month, each
/// with the reason they left and the date. Opened by tapping the "withdrawn"
/// stat on the monthly-movement card (manager) or the reception children tab.
/// Read-only: the children are already hard-deleted; this is the surviving log.
class WithdrawnChildrenSheet extends StatelessWidget {
  const WithdrawnChildrenSheet({super.key, required this.entries});

  final List<WithdrawalLogModel> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFAFBFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.grayLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.activityRed.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.logout_rounded,
                      color: AppColors.activityRed, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'withdrawn_list_title'.tr,
                    style: context.typography.lgBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                ),
                Text(
                  '${entries.length}',
                  style: context.typography.lgBold
                      .copyWith(color: AppColors.activityRed),
                ),
              ],
            ),
          ),
          Flexible(
            child: entries.isEmpty
                ? _Empty()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                    itemCount: entries.length,
                    itemBuilder: (_, i) => WithdrawnChildTile(entry: entries[i]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.inbox_rounded,
              size: 44, color: AppColors.textSecondaryParagraph),
          const SizedBox(height: 12),
          Text(
            'withdrawn_list_empty'.tr,
            textAlign: TextAlign.center,
            style: context.typography.smMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ],
      ),
    );
  }
}

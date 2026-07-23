import '../../../../../index/index_main.dart';
import '../../widgets/manager_section_header.dart';

/// This month's enrollment movement: new subscriptions vs. withdrawals, plus a
/// net-change footer so the manager sees the direction of the branch at a glance.
class MonthlyMovementSection extends StatelessWidget {
  const MonthlyMovementSection({super.key, required this.controller});

  final ManagerChildrenController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ManagerSectionHeader(
            title: 'manager_children_movement_title'.tr,
            icon: Icons.trending_up_rounded,
            color: AppColors.activityPurple,
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _MovementStat(
                          label: 'manager_children_kpi_new'.tr,
                          value: controller.newThisMonth.value,
                          icon: Icons.arrow_upward_rounded,
                          color: AppColors.activityGreen,
                        ),
                      ),
                      Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: AppColors.grayLight,
                      ),
                      Expanded(
                        child: _MovementStat(
                          label: 'manager_children_movement_left'.tr,
                          value: controller.leftThisMonth.value,
                          icon: Icons.arrow_downward_rounded,
                          color: AppColors.activityRed,
                          onTap: controller.leftThisMonth.value == 0
                              ? null
                              : controller.openWithdrawnList,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _NetRow(net: controller.netThisMonth),
              ],
            ),
          ),
        ],
      );
    });
  }
}

/// One side of the movement card: a tinted arrow badge, the count, and its label.
class _MovementStat extends StatelessWidget {
  const _MovementStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  /// When non-null the stat is tappable (e.g. withdrawn → list with reasons);
  /// a small chevron next to the count signals the affordance.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: color, size: 17),
              ),
              const SizedBox(width: 8),
              Text(
                '$value',
                style: context.typography.xlBold
                    .copyWith(color: AppColors.textDefault),
              ),
              if (onTap != null) ...[
                const SizedBox(width: 2),
                Icon(Icons.chevron_right_rounded, color: color, size: 18),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: context.typography.xsMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Net-change footer: green for growth, red for a decline, neutral at zero.
class _NetRow extends StatelessWidget {
  const _NetRow({required this.net});

  final int net;

  @override
  Widget build(BuildContext context) {
    final color = net > 0
        ? AppColors.activityGreen
        : net < 0
            ? AppColors.activityRed
            : AppColors.textSecondaryParagraph;
    final sign = net > 0 ? '+' : '';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'manager_children_movement_net'.tr,
            style: context.typography.smMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
          Text(
            '$sign$net',
            style: context.typography.smSemiBold.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

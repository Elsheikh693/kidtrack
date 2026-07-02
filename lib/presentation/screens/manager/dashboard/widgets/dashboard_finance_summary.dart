import '../../../../../index/index_main.dart';
import '../../widgets/manager_section_header.dart';

/// At-a-glance money card: this month's collection as the headline figure, with
/// outstanding, overdue and the count of families in debt underneath.
class DashboardFinanceSummary extends StatelessWidget {
  const DashboardFinanceSummary({super.key, required this.controller});

  final ManagerDashboardController controller;

  @override
  Widget build(BuildContext context) {
    final currency = 'manager_finance_currency'.tr;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ManagerSectionHeader(
          title: 'manager_dashboard_finance_title'.tr,
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.activityAmberBrand,
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => controller.openTab(4),
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.activityGreen.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(Icons.trending_up_rounded,
                          color: AppColors.activityGreen, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'manager_dashboard_finance_collected'.tr,
                            style: context.typography.xsMedium.copyWith(
                              color: AppColors.textSecondaryParagraph,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${controller.collectedThisMonth.toStringAsFixed(0)} $currency',
                            style: context.typography.xxlBold
                                .copyWith(color: AppColors.textDefault),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.arrow_forward_ios_rounded,
                          size: 13, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _CollectionRateBar(rate: controller.collectionRate),
                const SizedBox(height: 16),
                Divider(height: 1, color: AppColors.grayLight),
                const SizedBox(height: 14),
                Row(
                  children: [
                    _MiniStat(
                      labelKey: 'manager_dashboard_finance_outstanding',
                      value:
                          '${controller.outstandingTotal.toStringAsFixed(0)} $currency',
                      color: AppColors.activityAmberBrand,
                    ),
                    _Separator(),
                    _MiniStat(
                      labelKey: 'manager_dashboard_finance_overdue',
                      value:
                          '${controller.overdueTotal.toStringAsFixed(0)} $currency',
                      color: AppColors.activityRed,
                    ),
                    _Separator(),
                    _MiniStat(
                      labelKey: 'manager_dashboard_finance_families',
                      value: '${controller.debtFamiliesCount}',
                      color: AppColors.activityPurple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.labelKey,
    required this.value,
    required this.color,
  });

  final String labelKey;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: context.typography.smSemiBold.copyWith(color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            labelKey.tr,
            style: context.typography.xsRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CollectionRateBar extends StatelessWidget {
  const _CollectionRateBar({required this.rate});

  final int rate;

  @override
  Widget build(BuildContext context) {
    final color = rate >= 75
        ? AppColors.activityGreen
        : rate >= 40
            ? AppColors.activityAmberBrand
            : AppColors.activityRed;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'manager_dashboard_finance_collection_rate'.tr,
                style: context.typography.xsRegular
                    .copyWith(color: AppColors.textSecondaryParagraph),
              ),
            ),
            Text(
              '$rate%',
              style: context.typography.smSemiBold.copyWith(color: color),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: rate / 100,
            minHeight: 8,
            backgroundColor: AppColors.grayLight.withValues(alpha: 0.6),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: AppColors.grayLight,
    );
  }
}

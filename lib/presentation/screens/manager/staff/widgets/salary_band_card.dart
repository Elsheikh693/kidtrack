import '../../../../../index/index_main.dart';
import '../models/salary_band_data.dart';

/// One row in the Salary Center: a role, how many staff it covers, and the
/// combined monthly payroll for that role.
class SalaryBandCard extends StatelessWidget {
  const SalaryBandCard({super.key, required this.data});

  final SalaryBandData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grayLight),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.activityBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(Icons.payments_rounded,
                color: AppColors.activityBlue, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.roleKey.tr,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                ),
                const SizedBox(height: 2),
                Text(
                  'manager_staff_band_count'.trParams({'count': '${data.count}'}),
                  style: context.typography.xsRegular
                      .copyWith(color: AppColors.textSecondaryParagraph),
                ),
              ],
            ),
          ),
          Text(
            '${data.total.toStringAsFixed(0)} ${'manager_staff_currency'.tr}',
            style: context.typography.smSemiBold
                .copyWith(color: AppColors.activityBlue),
          ),
        ],
      ),
    );
  }
}

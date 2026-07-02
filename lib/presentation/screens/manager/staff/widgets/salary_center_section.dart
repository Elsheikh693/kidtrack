import '../../../../../index/index_main.dart';
import '../../widgets/manager_section_header.dart';
import 'salary_band_card.dart';

/// "Salary Center": total monthly payroll for the branch, a flag for staff
/// missing a salary, and a per-role payroll breakdown. Read-only monitoring.
class SalaryCenterSection extends StatelessWidget {
  const SalaryCenterSection({super.key, required this.controller});

  final ManagerStaffController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ManagerSectionHeader(
          title: 'manager_staff_salary_title'.tr,
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.activityGreen,
        ),
        Obx(() => _PayrollSummary(
              total: controller.totalPayroll.value,
              missing: controller.missingSalaryCount.value,
            )),
        const SizedBox(height: 12),
        Obx(() {
          final bands = controller.salaryBands;
          if (bands.isEmpty) return const SizedBox.shrink();
          return Column(
            children: bands.map((b) => SalaryBandCard(data: b)).toList(),
          );
        }),
      ],
    );
  }
}

class _PayrollSummary extends StatelessWidget {
  const _PayrollSummary({required this.total, required this.missing});

  final double total;
  final int missing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.activityGreen, AppColors.activityGreenDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'manager_staff_salary_total'.tr,
            style: context.typography.xsMedium
                .copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 6),
          Text(
            '${total.toStringAsFixed(0)} ${'manager_staff_currency'.tr}',
            style: context.typography.xxlBold.copyWith(color: AppColors.white),
          ),
          if (missing > 0) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 15, color: AppColors.white),
                const SizedBox(width: 6),
                Text(
                  'manager_staff_salary_missing'
                      .trParams({'count': '$missing'}),
                  style: context.typography.xsRegular
                      .copyWith(color: AppColors.white),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

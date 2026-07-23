import '../../../../../../index/index_main.dart';
import '../../../executive/models/owner_insight_item.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';

/// Staff Attendance & Payroll report — monthly payroll, payroll-to-revenue
/// ratio, punctuality, pending leaves, and the attendance-status breakdown.
class OwnerStaffCostView extends StatefulWidget {
  const OwnerStaffCostView({super.key});

  @override
  State<OwnerStaffCostView> createState() => _OwnerStaffCostViewState();
}

class _OwnerStaffCostViewState extends State<OwnerStaffCostView> {
  late final OwnerStaffCostController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerStaffCostController>();
  }

  static const _indigo = Color(0xFF4F46E5);

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_staff_cost_title',
      loading: controller.firstLoading,
      onRefresh: controller.reload,
      children: (context) => [
        Row(children: [
          Expanded(
            child: AnalyticsStatTile(
              labelKey: 'owner_report_sc_payroll',
              value: formatMoney(controller.monthlyPayroll),
              unitKey: 'owner_currency',
              color: const Color(0xFFD97706),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: AnalyticsStatTile(
              labelKey: 'owner_report_sc_ratio',
              value: '${controller.payrollRatio}',
              unitKey: 'owner_percent_unit',
              color: _ratioColor(controller.payrollRatio),
            ),
          ),
        ]),
        SizedBox(height: 10.h),
        Row(children: [
          Expanded(
            child: AnalyticsStatTile(
              labelKey: 'owner_report_sc_punctuality',
              value: '${controller.punctualityRate}',
              unitKey: 'owner_percent_unit',
              color: const Color(0xFF16A34A),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(child: _count('owner_report_sc_headcount', controller.headcount)),
          SizedBox(width: 10.w),
          Expanded(child: _count('owner_report_sc_pending_leaves',
              controller.pendingLeaves)),
        ]),
        SizedBox(height: 16.h),
        AnalyticsSectionHeader(
          titleKey: 'owner_report_sc_attendance',
          color: _indigo,
        ),
        for (final s in controller.attendanceBreakdown)
          AnalyticsBarRow(
            label: s.labelKey.tr,
            trailing: '${s.count}',
            fill: s.share,
            color: _statusColor(s.status),
          ),
      ],
    );
  }

  Widget _count(String key, int n) =>
      AnalyticsStatTile(labelKey: key, value: '$n', color: const Color(0xFF64748B));

  Color _ratioColor(int pct) {
    if (pct == 0) return const Color(0xFF64748B);
    if (pct <= 40) return const Color(0xFF16A34A);
    if (pct <= 60) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'present':
        return const Color(0xFF16A34A);
      case 'late':
        return const Color(0xFFF59E0B);
      case 'absent':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFF64748B);
    }
  }
}

import '../../../../../../index/index_main.dart';
import '../../../executive/models/owner_insight_item.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';

/// Accounts-Receivable report — current unpaid balances (not a monthly flow):
/// outstanding total, overdue invoices/amount, and >60-day overdue families.
class OwnerReceivablesView extends StatefulWidget {
  const OwnerReceivablesView({super.key});

  @override
  State<OwnerReceivablesView> createState() => _OwnerReceivablesViewState();
}

class _OwnerReceivablesViewState extends State<OwnerReceivablesView> {
  late final OwnerReceivablesController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerReceivablesController>();
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_receivables_title',
      loading: controller.firstLoading,
      onRefresh: controller.reload,
      children: (context) {
        final m = controller.metrics;
        if (m == null) return [const SizedBox.shrink()];
        return [
          Text(
            'owner_report_ar_current_note'.tr,
            style: context.typography.xsRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(child: _money('owner_report_ar_outstanding',
                  m.outstanding, const Color(0xFFD97706))),
              SizedBox(width: 10.w),
              Expanded(child: _money('owner_report_ar_overdue',
                  m.overdueAmount, const Color(0xFFEF4444))),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(child: AnalyticsStatTile(
                labelKey: 'owner_report_ar_overdue_invoices',
                value: '${m.overdueInvoices}',
                color: const Color(0xFF7C3AED),
              )),
              SizedBox(width: 10.w),
              Expanded(child: AnalyticsStatTile(
                labelKey: 'owner_report_ar_families60',
                value: '${m.overdue60Families}',
                color: const Color(0xFFB91C1C),
              )),
            ],
          ),
          if (m.overdue60Amount > 0) ...[
            SizedBox(height: 10.h),
            _money('owner_report_ar_amount60', m.overdue60Amount,
                const Color(0xFFB91C1C)),
          ],
          if (controller.showBranches && controller.branches.isNotEmpty) ...[
            const AnalyticsSectionHeader(
              titleKey: 'owner_report_ar_by_branch',
              color: Color(0xFFEF4444),
            ),
            for (final b in controller.branches)
              AnalyticsBarRow(
                label: b.branchName,
                trailing:
                    '${formatMoney(b.current.overdueAmount)} ${'owner_currency'.tr}',
                fill: b.current.overdueAmount / controller.maxBranchOverdue,
                color: const Color(0xFFEF4444),
                subtitle: '${b.current.overdueInvoices} '
                    '${'owner_report_ar_invoices_unit'.tr}',
              ),
          ],
        ];
      },
    );
  }

  Widget _money(String key, double v, Color c) => AnalyticsStatTile(
        labelKey: key,
        value: formatMoney(v),
        unitKey: 'owner_currency',
        color: c,
      );
}

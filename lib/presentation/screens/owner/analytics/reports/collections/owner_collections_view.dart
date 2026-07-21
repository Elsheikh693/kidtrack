import '../../../../../../index/index_main.dart';
import '../../../executive/models/owner_insight_item.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';

/// Collections report — expected vs collected vs outstanding + collection rate,
/// then a per-branch collection-rate breakdown on the network view.
class OwnerCollectionsView extends StatefulWidget {
  const OwnerCollectionsView({super.key});

  @override
  State<OwnerCollectionsView> createState() => _OwnerCollectionsViewState();
}

class _OwnerCollectionsViewState extends State<OwnerCollectionsView> {
  late final OwnerCollectionsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerCollectionsController>();
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_collections_title',
      loading: controller.firstLoading,
      onRefresh: controller.reload,
      children: (context) {
        final f = controller.finance;
        return [
          Row(
            children: [
              Expanded(child: _money('owner_report_coll_expected',
                  f.expectedRevenue, const Color(0xFFD97706))),
              SizedBox(width: 10.w),
              Expanded(child: _money('owner_report_coll_collected',
                  f.collected, const Color(0xFF16A34A))),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(child: _money('owner_report_coll_remaining',
                  f.outstanding, const Color(0xFFEF4444))),
              SizedBox(width: 10.w),
              Expanded(child: AnalyticsStatTile(
                labelKey: 'owner_report_coll_rate',
                value: '${f.collectionPercent}',
                unitKey: 'owner_percent_unit',
                color: const Color(0xFF2563EB),
              )),
            ],
          ),
          if (controller.showBranches) ...[
            const AnalyticsSectionHeader(
              titleKey: 'owner_report_coll_by_branch',
              color: Color(0xFF16A34A),
            ),
            for (final b in controller.branches)
              AnalyticsBarRow(
                label: b.branchName,
                trailing: '${(b.current.collectionRate * 100).round()}%',
                fill: b.current.collectionRate,
                color: const Color(0xFF16A34A),
                subtitle:
                    '${formatMoney(b.current.collected)} / ${formatMoney(b.current.revenue)} ${'owner_currency'.tr}',
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

import '../../../../../../index/index_main.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';

/// Occupancy report — headline fill %, seat counts, and a per-classroom fill
/// breakdown (fullest first).
class OwnerOccupancyView extends StatefulWidget {
  const OwnerOccupancyView({super.key});

  @override
  State<OwnerOccupancyView> createState() => _OwnerOccupancyViewState();
}

class _OwnerOccupancyViewState extends State<OwnerOccupancyView> {
  late final OwnerOccupancyController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerOccupancyController>();
  }

  Color _fillColor(int pct) => pct >= 90
      ? const Color(0xFFEF4444)
      : pct >= 70
          ? const Color(0xFFD97706)
          : const Color(0xFF0891B2);

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_occupancy_title',
      loading: controller.firstLoading,
      onRefresh: controller.reload,
      children: (context) {
        final g = controller.growth;
        return [
          Row(
            children: [
              Expanded(child: AnalyticsStatTile(
                labelKey: 'owner_report_occ_rate',
                value: '${g.occupancyPercent}',
                unitKey: 'owner_percent_unit',
                color: const Color(0xFF0891B2),
              )),
              SizedBox(width: 10.w),
              Expanded(child: AnalyticsStatTile(
                labelKey: 'owner_report_occ_free',
                value: '${g.freeSeats}',
                color: const Color(0xFF16A34A),
              )),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(child: AnalyticsStatTile(
                labelKey: 'owner_report_occ_active',
                value: '${g.activeChildren}',
                color: const Color(0xFF2563EB),
              )),
              SizedBox(width: 10.w),
              Expanded(child: AnalyticsStatTile(
                labelKey: 'owner_report_occ_capacity',
                value: '${g.totalCapacity}',
                color: const Color(0xFF7C3AED),
              )),
            ],
          ),
          if (controller.rooms.isNotEmpty) ...[
            const AnalyticsSectionHeader(
              titleKey: 'owner_report_occ_by_room',
              color: Color(0xFF0891B2),
            ),
            for (final r in controller.rooms)
              AnalyticsBarRow(
                label: r.name,
                trailing: '${r.fillPercent}%',
                fill: r.fillPercent / 100,
                color: _fillColor(r.fillPercent),
                subtitle: '${r.enrolled} / ${r.capacity} '
                    '${'owner_report_occ_seats_unit'.tr}',
              ),
          ],
        ];
      },
    );
  }
}

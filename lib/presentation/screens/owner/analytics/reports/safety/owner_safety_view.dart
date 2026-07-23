import '../../../../../../index/index_main.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';

/// Incidents & Safety report — last-30-day incident volume, severity, parent
/// notification rate, and the split by severity / type / branch.
class OwnerSafetyView extends StatefulWidget {
  const OwnerSafetyView({super.key});

  @override
  State<OwnerSafetyView> createState() => _OwnerSafetyViewState();
}

class _OwnerSafetyViewState extends State<OwnerSafetyView> {
  late final OwnerSafetyController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerSafetyController>();
  }

  static const _red = Color(0xFFEF4444);

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_safety_title',
      loading: controller.firstLoading,
      onRefresh: controller.reload,
      children: (context) {
        if (controller.total == 0) return [_empty()];
        return [
          Row(children: [
            Expanded(child: _count('owner_report_saf_total', controller.total, _red)),
            SizedBox(width: 10.w),
            Expanded(child: _count('owner_report_saf_high', controller.highCount,
                const Color(0xFFB91C1C))),
          ]),
          SizedBox(height: 10.h),
          Row(children: [
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_saf_notified',
                value: '${controller.notifiedRate}',
                unitKey: 'owner_percent_unit',
                color: const Color(0xFF16A34A),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(child: _count('owner_report_saf_children',
                controller.childrenAffected, const Color(0xFF64748B))),
          ]),
          SizedBox(height: 16.h),
          AnalyticsSectionHeader(
            titleKey: 'owner_report_saf_by_severity',
            color: _red,
          ),
          ..._bars(controller.bySeverity, _severityColor),
          SizedBox(height: 6.h),
          AnalyticsSectionHeader(
            titleKey: 'owner_report_saf_by_type',
            color: _red,
          ),
          ..._bars(controller.byType, (_) => const Color(0xFFF97316)),
          if (controller.byBranch.isNotEmpty) ...[
            SizedBox(height: 6.h),
            AnalyticsSectionHeader(
              titleKey: 'owner_report_saf_by_branch',
              color: _red,
            ),
            ..._bars(controller.byBranch, (_) => const Color(0xFF7C3AED)),
          ],
        ];
      },
    );
  }

  List<Widget> _bars(List<LabelCount> rows, Color Function(LabelCount) color) => [
        for (final r in rows)
          AnalyticsBarRow(
            label: r.text,
            trailing: '${r.count}',
            fill: r.share,
            color: color(r),
          ),
      ];

  Widget _count(String key, int n, Color c) =>
      AnalyticsStatTile(labelKey: key, value: '$n', color: c);

  Widget _empty() => Padding(
        padding: EdgeInsets.only(top: 60.h),
        child: Center(
          child: Text(
            'owner_report_saf_empty'.tr,
            style: context.typography.smMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ),
      );

  Color _severityColor(LabelCount r) {
    if (r.labelKey == 'incident_severity_high') return const Color(0xFFB91C1C);
    if (r.labelKey == 'incident_severity_medium') return const Color(0xFFF59E0B);
    return const Color(0xFF64748B);
  }
}

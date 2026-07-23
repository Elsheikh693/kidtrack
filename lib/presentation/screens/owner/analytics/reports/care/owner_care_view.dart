import '../../../../../../index/index_main.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';

/// Daily Care report — this month's care logs: volume, children covered, average
/// nap & diaper changes, plus meal-outcome and mood distributions.
class OwnerCareView extends StatefulWidget {
  const OwnerCareView({super.key});

  @override
  State<OwnerCareView> createState() => _OwnerCareViewState();
}

class _OwnerCareViewState extends State<OwnerCareView> {
  late final OwnerCareController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerCareController>();
  }

  static const _teal = Color(0xFF0D9488);

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_care_title',
      loading: controller.isLoading,
      onRefresh: controller.load,
      showScope: false,
      children: (context) {
        if (controller.isEmpty) return [_empty()];
        return [
          Row(children: [
            Expanded(child: _count('owner_report_ca_logs',
                '${controller.logCount}', _teal)),
            SizedBox(width: 10.w),
            Expanded(child: _count('owner_report_ca_children',
                '${controller.childrenCovered}', const Color(0xFF64748B))),
          ]),
          SizedBox(height: 10.h),
          Row(children: [
            Expanded(
              child: AnalyticsStatTile(
                labelKey: 'owner_report_ca_nap',
                value: '${controller.avgNapMinutes}',
                unitKey: 'owner_report_pu_min',
                color: const Color(0xFF6366F1),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(child: _count('owner_report_ca_diapers',
                controller.avgDiapers.toStringAsFixed(1),
                const Color(0xFFD97706))),
          ]),
          SizedBox(height: 16.h),
          AnalyticsSectionHeader(
            titleKey: 'owner_report_ca_meals',
            color: _teal,
          ),
          for (final s in controller.mealOutcomes)
            AnalyticsBarRow(
              label: s.labelKey.tr,
              trailing: '${s.count}',
              fill: s.share,
              color: _mealColor(s.labelKey),
            ),
          SizedBox(height: 6.h),
          AnalyticsSectionHeader(
            titleKey: 'owner_report_ca_mood',
            color: _teal,
          ),
          for (final s in controller.moods)
            AnalyticsBarRow(
              label: s.labelKey.tr,
              trailing: '${s.count}',
              fill: s.share,
              color: _moodColor(s.labelKey),
            ),
        ];
      },
    );
  }

  Widget _count(String key, String v, Color c) =>
      AnalyticsStatTile(labelKey: key, value: v, color: c);

  Widget _empty() => Padding(
        padding: EdgeInsets.only(top: 60.h),
        child: Center(
          child: Text(
            'owner_report_ca_empty'.tr,
            style: context.typography.smMedium
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
        ),
      );

  Color _mealColor(String key) {
    if (key.endsWith('ate_all')) return const Color(0xFF16A34A);
    if (key.endsWith('ate_some')) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  Color _moodColor(String key) {
    if (key.endsWith('happy')) return const Color(0xFF16A34A);
    if (key.endsWith('calm')) return const Color(0xFF0EA5E9);
    if (key.endsWith('cranky')) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

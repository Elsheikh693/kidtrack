import '../../../../../../index/index_main.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_stat_tile.dart';
import '../../widgets/analytics_bar_row.dart';
import '../../widgets/analytics_section_header.dart';

/// Attendance report — today's present count and a 14-day daily check-in trend
/// (present + late). Honest volumes rather than a reconstructed rate.
class OwnerAttendanceView extends StatefulWidget {
  const OwnerAttendanceView({super.key});

  @override
  State<OwnerAttendanceView> createState() => _OwnerAttendanceViewState();
}

class _OwnerAttendanceViewState extends State<OwnerAttendanceView> {
  late final OwnerAttendanceController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerAttendanceController>();
  }

  static const _green = Color(0xFF16A34A);

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_attendance_title',
      loading: controller.isLoading,
      onRefresh: controller.load,
      showScope: false,
      children: (context) {
        if (controller.windowTotal == 0) {
          return [
            SizedBox(height: 100.h),
            Text(
              'owner_report_att_empty'.tr,
              textAlign: TextAlign.center,
              style: context.typography.smMedium
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ];
        }
        final peak = controller.peak;
        return [
          Row(
            children: [
              Expanded(child: AnalyticsStatTile(
                labelKey: 'owner_report_att_today',
                value: '${controller.presentToday.value}',
                color: _green,
              )),
              SizedBox(width: 10.w),
              Expanded(child: AnalyticsStatTile(
                labelKey: 'owner_report_att_avg',
                value: '${controller.avgPerDay}',
                color: const Color(0xFF2563EB),
              )),
            ],
          ),
          const AnalyticsSectionHeader(
            titleKey: 'owner_report_att_trend',
            color: _green,
          ),
          for (final d in controller.days)
            AnalyticsBarRow(
              label: d.label,
              trailing: '${d.count}',
              fill: d.count / peak,
              color: _green,
            ),
        ];
      },
    );
  }
}

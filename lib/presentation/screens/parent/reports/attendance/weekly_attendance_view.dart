import '../../../../../index/index_main.dart';
import '../widgets/report_skeleton.dart';
import 'widgets/report_week_switcher.dart';
import 'widgets/attendance_rate_card.dart';
import 'widgets/attendance_week_details.dart';
import 'widgets/average_arrival_card.dart';
import 'widgets/attendance_trend_card.dart';
import 'widgets/attendance_insight_card.dart';
import 'widgets/attendance_report_empty.dart';
import 'widgets/weekly_attendance_pdf.dart';

class WeeklyAttendanceView extends StatefulWidget {
  const WeeklyAttendanceView({super.key});

  @override
  State<WeeklyAttendanceView> createState() => _WeeklyAttendanceViewState();
}

class _WeeklyAttendanceViewState extends State<WeeklyAttendanceView> {
  late final WeeklyAttendanceController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => WeeklyAttendanceController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: Text(
            'report_attendance_title'.tr,
            style: context.typography.lgBold
                .copyWith(color: AppColors.textDefault),
          ),
          actions: [
            IconButton(
              tooltip: 'report_share_pdf'.tr,
              onPressed: () => shareWeeklyAttendancePdf(controller),
              icon: const Icon(Icons.ios_share_rounded,
                  color: AppColors.textDefault),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const ReportSkeleton();
          }
          return ListView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
            physics: const BouncingScrollPhysics(),
            children: [
              ReportWeekSwitcher(controller: controller),
              SizedBox(height: 16.h),
              if (controller.isEmptyWeek.value)
                const AttendanceReportEmpty()
              else ...[
                AttendanceRateCard(controller: controller),
                SizedBox(height: 12.h),
                AttendanceTrendCard(controller: controller),
                SizedBox(height: 12.h),
                AverageArrivalCard(controller: controller),
                SizedBox(height: 12.h),
                AttendanceWeekDetails(controller: controller),
                SizedBox(height: 12.h),
                AttendanceInsightCard(controller: controller),
              ],
            ],
          );
        }),
      ),
    );
  }
}

import '../../../../../index/index_main.dart';
import '../widgets/report_skeleton.dart';
import '../widgets/report_week_bar.dart';
import '../widgets/report_insight_banner.dart';
import '../widgets/report_empty_state.dart';
import 'widgets/monthly_hero_card.dart';
import 'widgets/monthly_attendance_card.dart';
import 'widgets/monthly_evaluation_card.dart';
import 'widgets/monthly_financial_card.dart';
import 'widgets/monthly_report_pdf.dart';

class MonthlyReportView extends StatefulWidget {
  const MonthlyReportView({super.key});

  @override
  State<MonthlyReportView> createState() => _MonthlyReportViewState();
}

class _MonthlyReportViewState extends State<MonthlyReportView> {
  late final MonthlyReportController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => MonthlyReportController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          title: Text('report_monthly_title'.tr,
              style: context.typography.lgBold
                  .copyWith(color: AppColors.textDefault)),
          actions: [
            IconButton(
              tooltip: 'report_share_pdf'.tr,
              onPressed: () => shareMonthlyReportPdf(controller),
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
              ReportWeekBar(
                rangeLabel: controller.monthLabel,
                subtitle: controller.monthOffset.value == 0
                    ? 'report_this_month'.tr
                    : 'report_past_month'.tr,
                canGoNext: controller.canGoNext,
                onPrev: controller.previousMonth,
                onNext: controller.nextMonth,
              ),
              SizedBox(height: 16.h),
              if (controller.isEmptyMonth.value)
                ReportEmptyState(
                  icon: Icons.calendar_month_outlined,
                  titleKey: 'report_monthly_empty_title',
                  subKey: 'report_monthly_empty_sub',
                )
              else ...[
                MonthlyHeroCard(controller: controller),
                SizedBox(height: 12.h),
                MonthlyEvaluationCard(controller: controller),
                SizedBox(height: 12.h),
                MonthlyAttendanceCard(controller: controller),
                SizedBox(height: 12.h),
                MonthlyFinancialCard(controller: controller),
                SizedBox(height: 4.h),
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: ReportInsightBanner(
                    text: controller.insight.value,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

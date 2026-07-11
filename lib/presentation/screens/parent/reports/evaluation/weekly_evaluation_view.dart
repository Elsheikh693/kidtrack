import '../../../../../index/index_main.dart';
import '../widgets/report_week_bar.dart';
import '../widgets/report_insight_banner.dart';
import '../widgets/report_empty_state.dart';
import 'widgets/daily_rating_style.dart';
import 'widgets/evaluation_summary_card.dart';
import 'widgets/evaluation_distribution_card.dart';
import 'widgets/evaluation_day_list.dart';
import 'widgets/weekly_evaluation_pdf.dart';

class WeeklyEvaluationView extends StatefulWidget {
  const WeeklyEvaluationView({super.key});

  @override
  State<WeeklyEvaluationView> createState() => _WeeklyEvaluationViewState();
}

class _WeeklyEvaluationViewState extends State<WeeklyEvaluationView> {
  late final WeeklyEvaluationController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => WeeklyEvaluationController());
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
          title: Text('report_evaluation_title'.tr,
              style: context.typography.lgBold
                  .copyWith(color: AppColors.textDefault)),
          actions: [
            IconButton(
              tooltip: 'report_share_pdf'.tr,
              onPressed: () => shareWeeklyEvaluationPdf(controller),
              icon: const Icon(Icons.ios_share_rounded,
                  color: AppColors.textDefault),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 32.h),
            physics: const BouncingScrollPhysics(),
            children: [
              ReportWeekBar(
                rangeLabel: controller.weekRangeLabel,
                subtitle: controller.weekOffset.value == 0
                    ? 'report_this_week'.tr
                    : 'report_past_week'.tr,
                canGoNext: controller.canGoNext,
                onPrev: controller.previousWeek,
                onNext: controller.nextWeek,
              ),
              SizedBox(height: 16.h),
              if (controller.isEmptyWeek.value)
                ReportEmptyState(
                  icon: Icons.emoji_emotions_outlined,
                  titleKey: 'report_eval_empty_title',
                  subKey: 'report_eval_empty_sub',
                )
              else ...[
                EvaluationSummaryCard(controller: controller),
                SizedBox(height: 12.h),
                EvaluationDistributionCard(controller: controller),
                SizedBox(height: 12.h),
                EvaluationDayList(controller: controller),
                SizedBox(height: 4.h),
                ReportInsightBanner(
                  text: controller.insight.value,
                  color: DailyRatingStyle.color(controller.dominant.value),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

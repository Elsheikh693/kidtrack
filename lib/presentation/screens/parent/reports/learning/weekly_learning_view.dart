import '../../../../../index/index_main.dart';
import '../widgets/report_skeleton.dart';
import '../widgets/report_week_bar.dart';
import '../widgets/report_empty_state.dart';
import '../widgets/report_insight_banner.dart';
import 'widgets/learning_summary_card.dart';
import 'widgets/learning_subject_card.dart';
import 'widgets/weekly_learning_pdf.dart';

class WeeklyLearningView extends StatefulWidget {
  const WeeklyLearningView({super.key});

  @override
  State<WeeklyLearningView> createState() => _WeeklyLearningViewState();
}

class _WeeklyLearningViewState extends State<WeeklyLearningView> {
  late final WeeklyLearningController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => WeeklyLearningController());
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
          title: Text('report_learning_title'.tr,
              style: context.typography.lgBold
                  .copyWith(color: AppColors.textDefault)),
          actions: [
            IconButton(
              tooltip: 'report_share_pdf'.tr,
              onPressed: () => shareWeeklyLearningPdf(controller),
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
                  icon: Icons.auto_stories_outlined,
                  titleKey: 'report_learning_empty_title',
                  subKey: 'report_learning_empty_sub',
                )
              else ...[
                LearningSummaryCard(controller: controller),
                SizedBox(height: 12.h),
                if (controller.insight.value.isNotEmpty) ...[
                  ReportInsightBanner(
                    text: controller.insight.value,
                    color: WeeklyLearningController.insightColor,
                  ),
                  SizedBox(height: 12.h),
                ],
                ...controller.groups
                    .map((g) => LearningSubjectCard(group: g)),
              ],
            ],
          );
        }),
      ),
    );
  }
}

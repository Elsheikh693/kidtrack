import '../../../../../../index/index_main.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_pdf.dart';
import 'widgets/health_rank_card.dart';

/// Branch Health Ranking report — every branch scored 0–100 with an explainable
/// breakdown, ranked best to worst. This, not revenue, is the truer health view.
class OwnerBranchHealthView extends StatefulWidget {
  const OwnerBranchHealthView({super.key});

  @override
  State<OwnerBranchHealthView> createState() => _OwnerBranchHealthViewState();
}

class _OwnerBranchHealthViewState extends State<OwnerBranchHealthView> {
  late final OwnerBranchHealthController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerBranchHealthController>();
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_branch_health_title',
      loading: controller.firstLoading,
      onRefresh: controller.reload,
      onExport: () => shareAnalyticsPdf(
        title: 'owner_report_branch_health_title'.tr,
        subtitle: controller.scopeLabel,
        kpis: controller.pdfKpis,
        sections: controller.pdfSections,
        filename: 'branch-health.pdf',
      ),
      children: (context) {
        final ranking = controller.ranking;
        if (ranking.isEmpty) {
          return [
            SizedBox(height: 100.h),
            Text(
              'owner_report_empty_generic'.tr,
              textAlign: TextAlign.center,
              style: context.typography.smMedium
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ];
        }
        return [
          for (var i = 0; i < ranking.length; i++)
            HealthRankCard(rank: i + 1, score: ranking[i]),
          if (controller.emptyBranches > 0) ...[
            SizedBox(height: 6.h),
            Text(
              'owner_report_health_no_data'.trParams(
                  {'count': '${controller.emptyBranches}'}),
              style: context.typography.xsRegular
                  .copyWith(color: AppColors.textSecondaryParagraph),
            ),
          ],
        ];
      },
    );
  }
}

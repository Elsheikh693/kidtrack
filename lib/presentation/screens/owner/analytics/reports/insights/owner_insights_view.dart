import '../../../../../../index/index_main.dart';
import '../../../executive/widgets/executive_widgets.dart';
import '../../widgets/analytics_report_scaffold.dart';
import '../../widgets/analytics_pdf.dart';

/// Executive Brief + Insights report — a one-line briefing, then the priorities
/// (problems, severity-sorted) and the wins, each rendered with the shared
/// executive [InsightCard].
class OwnerInsightsView extends StatefulWidget {
  const OwnerInsightsView({super.key});

  @override
  State<OwnerInsightsView> createState() => _OwnerInsightsViewState();
}

class _OwnerInsightsViewState extends State<OwnerInsightsView> {
  late final OwnerInsightsController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OwnerInsightsController>();
  }

  @override
  Widget build(BuildContext context) {
    return AnalyticsReportScaffold(
      titleKey: 'owner_report_insights_title',
      loading: controller.firstLoading,
      onRefresh: controller.reload,
      onExport: () => shareAnalyticsPdf(
        title: 'owner_report_insights_title'.tr,
        subtitle: controller.scopeLabel,
        kpis: controller.pdfKpis,
        sections: controller.pdfSections,
        filename: 'insights.pdf',
      ),
      children: (context) {
        final d = controller.data;
        final problems = d.problems;
        final wins = d.wins;
        return [
          if (d.brief.summary.isNotEmpty) _briefCard(context, d.brief.summary),
          const ExecSectionLabel(
            titleKey: 'owner_report_insights_priorities',
            icon: Icons.priority_high_rounded,
            color: Color(0xFFEF4444),
          ),
          if (problems.isEmpty)
            const AllClearCard()
          else
            for (final p in problems) InsightCard(item: p),
          if (wins.isNotEmpty) ...[
            const ExecSectionLabel(
              titleKey: 'owner_report_insights_wins',
              icon: Icons.emoji_events_rounded,
              color: Color(0xFF16A34A),
            ),
            for (final w in wins) InsightCard(item: w),
          ],
        ];
      },
    );
  }

  Widget _briefCard(BuildContext context, String summary) => Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withValues(alpha: 0.28),
              blurRadius: 20.r,
              spreadRadius: -8.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.auto_awesome_rounded,
                color: Colors.white.withValues(alpha: 0.9), size: 22.sp),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                summary,
                style: context.typography.smSemiBold
                    .copyWith(color: Colors.white, height: 1.5),
              ),
            ),
          ],
        ),
      );
}

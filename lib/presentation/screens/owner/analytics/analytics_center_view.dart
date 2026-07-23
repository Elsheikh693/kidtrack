import '../../../../index/index_main.dart';
import 'widgets/analytics_section_header.dart';
import 'widgets/analytics_list_row.dart';

/// Owner Analytics Center — the hub that turns the compute-once executive engine
/// into a Business-Intelligence surface. Six domain sections; Phase-1 reports
/// navigate live, the rest advertise the roadmap as dimmed "coming soon" rows.
/// A pure assembly layer — the controller only warms the shared data bundle.
class AnalyticsCenterView extends StatefulWidget {
  const AnalyticsCenterView({super.key});

  @override
  State<AnalyticsCenterView> createState() => _AnalyticsCenterViewState();
}

class _AnalyticsCenterViewState extends State<AnalyticsCenterView> {
  late final AnalyticsCenterController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<AnalyticsCenterController>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral100,
      appBar: OwnerAppBar(
        title: 'owner_analytics_title'.tr,
        showScopeSwitcher: true,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 110.h),
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: [
          _header('owner_analytics_section_business', const Color(0xFF16A34A)),
          _row(0, 'owner_report_finance_trend', Icons.show_chart_rounded,
              const Color(0xFF16A34A), route: ownerFinanceTrendReportView),
          _gap,
          _row(1, 'owner_report_collections', Icons.payments_rounded,
              const Color(0xFF0EA5E9), route: ownerCollectionsReportView),
          _gap,
          _row(2, 'owner_report_receivables', Icons.request_quote_rounded,
              const Color(0xFFEF4444), route: ownerReceivablesReportView),
          _gap,
          _row(3, 'owner_report_branch_pnl', Icons.account_balance_rounded,
              const Color(0xFFD97706), route: ownerBranchPnlReportView),
          _gap,
          _row(12, 'owner_report_collection_rate', Icons.percent_rounded,
              const Color(0xFF2563EB), route: ownerCollectionRateReportView),
          _gap,
          _row(13, 'owner_report_revenue_method', Icons.account_balance_wallet_rounded,
              const Color(0xFF6D4AFF), route: ownerRevenueMethodReportView),
          _gap,
          _row(14, 'owner_report_revenue_category', Icons.category_rounded,
              const Color(0xFF16A34A), route: ownerRevenueCategoryReportView),
          _gap,
          _row(15, 'owner_report_payment_behavior', Icons.schedule_rounded,
              const Color(0xFFF97316), route: ownerPaymentBehaviorReportView),
          _gap,
          _row(16, 'owner_report_revenue_forecast', Icons.trending_up_rounded,
              const Color(0xFF0EA5E9), route: ownerRevenueForecastReportView),
          _header('owner_analytics_section_branches', const Color(0xFF7C3AED)),
          _row(4, 'owner_report_branch_health', Icons.favorite_rounded,
              const Color(0xFF7C3AED), route: ownerBranchHealthReportView),
          _gap,
          _row(5, 'owner_report_occupancy', Icons.event_seat_rounded,
              const Color(0xFF0891B2), route: ownerOccupancyReportView),
          _header('owner_analytics_section_children', const Color(0xFF16A34A)),
          _row(6, 'owner_report_attendance', Icons.event_available_rounded,
              const Color(0xFF16A34A), route: ownerAttendanceReportView),
          _gap,
          _row(7, 'owner_report_churn', Icons.trending_down_rounded,
              const Color(0xFFF97316), route: ownerChurnReportView),
          _gap,
          _row(19, 'owner_report_safety', Icons.health_and_safety_rounded,
              const Color(0xFFEF4444), route: ownerSafetyReportView),
          _gap,
          _row(21, 'owner_report_funnel', Icons.filter_alt_rounded,
              const Color(0xFF0891B2), route: ownerFunnelReportView),
          _gap,
          _row(24, 'owner_report_care', Icons.child_care_rounded,
              const Color(0xFF0D9488), route: ownerCareReportView),
          _header('owner_analytics_section_education', const Color(0xFF2563EB)),
          _row(8, 'owner_report_teacher_perf', Icons.school_rounded,
              const Color(0xFF2563EB), route: ownerTeacherPerfReportView),
          _gap,
          _row(9, 'owner_report_evaluations', Icons.star_rounded,
              const Color(0xFFF59E0B), route: ownerEvaluationsReportView),
          _gap,
          _row(17, 'owner_report_academic', Icons.menu_book_rounded,
              const Color(0xFF2563EB), route: ownerAcademicReportView),
          _gap,
          _row(22, 'owner_report_curriculum', Icons.fact_check_rounded,
              const Color(0xFF0EA5E9), route: ownerCurriculumReportView),
          _gap,
          _row(26, 'owner_report_homework', Icons.assignment_turned_in_rounded,
              const Color(0xFF16A34A), route: ownerHomeworkReportView),
          _header('owner_analytics_section_parents', const Color(0xFFEC4899)),
          _row(10, 'owner_report_engagement', Icons.groups_rounded,
              const Color(0xFFEC4899), route: ownerEngagementReportView),
          _gap,
          _row(18, 'owner_report_satisfaction', Icons.sentiment_satisfied_rounded,
              const Color(0xFFEC4899), route: ownerSatisfactionReportView),
          _gap,
          _row(25, 'owner_report_events', Icons.celebration_rounded,
              const Color(0xFF6366F1), route: ownerEventsReportView),
          _header('owner_analytics_section_operations', const Color(0xFF4F46E5)),
          _row(20, 'owner_report_staff_cost', Icons.badge_rounded,
              const Color(0xFF4F46E5), route: ownerStaffCostReportView),
          _gap,
          _row(23, 'owner_report_punctuality', Icons.timer_outlined,
              const Color(0xFF7C3AED), route: ownerPunctualityReportView),
          _header('owner_analytics_section_insights', const Color(0xFF4F46E5)),
          _row(11, 'owner_report_insights', Icons.auto_awesome_rounded,
              const Color(0xFF4F46E5), route: ownerInsightsReportView),
        ],
      ),
    );
  }

  Widget get _gap => SizedBox(height: 12.h);

  Widget _header(String key, Color color) =>
      AnalyticsSectionHeader(titleKey: key, color: color);

  Widget _row(int i, String base, IconData icon, Color color, {String? route}) =>
      AnalyticsListRow(
        index: i,
        labelKey: '${base}_title',
        descKey: '${base}_desc',
        icon: icon,
        color: color,
        enabled: route != null,
        onTap: route == null ? null : () => Get.toNamed(route),
      );
}

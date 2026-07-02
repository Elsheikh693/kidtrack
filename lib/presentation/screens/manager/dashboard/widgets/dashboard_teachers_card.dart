import '../../../../../index/index_main.dart';
import '../../teacher_reports/widgets/tr_summary_hero.dart';

/// Teacher-activity snapshot on the manager home. Reuses the summary already
/// computed by the Teachers tab; tapping the header or the banner opens that tab.
class DashboardTeachersCard extends StatelessWidget {
  const DashboardTeachersCard({super.key, required this.controller});

  final ManagerDashboardController controller;

  // Tie the activities card to the brand primary so it stays in harmony with
  // the purple hero above it (and follows the nursery's brand color).
  Color get _accent => AppColors.primary;
  static const _teachersTabIndex = 2;

  @override
  Widget build(BuildContext context) {
    final reports = Get.find<ManagerTeacherReportsController>();
    return Obx(() {
      final summary = reports.summary.value;
      if (summary == null) return const SizedBox.shrink();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Header(onViewMore: () => controller.openTab(_teachersTabIndex)),
          SizedBox(height: 12.h),
          GestureDetector(
            onTap: () => controller.openTab(_teachersTabIndex),
            child: TrSummaryHero(summary: summary, accent: _accent),
          ),
        ],
      );
    });
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onViewMore});

  final VoidCallback onViewMore;

  Color get _accent => AppColors.primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34.w,
          height: 34.w,
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(Icons.school_rounded, color: _accent, size: 19.sp),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            'manager_tab_teachers'.tr,
            style: context.typography.mdBold
                .copyWith(color: AppColors.textDefault),
          ),
        ),
        GestureDetector(
          onTap: onViewMore,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'common_view_more'.tr,
                  style: context.typography.xsRegular.copyWith(
                    color: _accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5.sp,
                  ),
                ),
                SizedBox(width: 2.w),
                Icon(Icons.chevron_right_rounded, color: _accent, size: 16.sp),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

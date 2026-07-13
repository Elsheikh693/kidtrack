import '../../../../index/index_main.dart';
import 'widgets/teaching_donut.dart';
import 'widgets/teaching_empty.dart';
import 'widgets/teaching_legend_tile.dart';

/// Manager-home card: a live donut of what every in-session class is being
/// taught right now, with a tappable legend that drills into each teacher's
/// day. Replaces the old teacher-activity summary card.
class LiveTeachingCard extends StatefulWidget {
  const LiveTeachingCard({super.key, required this.dashboard});

  final ManagerDashboardController dashboard;

  @override
  State<LiveTeachingCard> createState() => _LiveTeachingCardState();
}

class _LiveTeachingCardState extends State<LiveTeachingCard> {
  late final LiveTeachingController controller;
  static const _teachersTabIndex = 2;

  @override
  void initState() {
    super.initState();
    controller = Get.find<LiveTeachingController>();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _CardShell(
          onViewMore: () => widget.dashboard.openTab(_teachersTabIndex),
          child: SizedBox(
            height: 180.h,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
        );
      }

      final slices = controller.slices;
      return _CardShell(
        onViewMore: () => widget.dashboard.openTab(_teachersTabIndex),
        child: slices.isEmpty
            ? const TeachingEmpty()
            : Column(
                children: [
                  Center(child: TeachingDonut(slices: slices)),
                  SizedBox(height: 16.h),
                  for (final s in slices) ...[
                    TeachingLegendTile(
                      slice: s,
                      onTap: () => controller.openTeacherDay(s),
                    ),
                    SizedBox(height: 8.h),
                  ],
                ],
              ),
      );
    });
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.onViewMore, required this.child});

  final VoidCallback onViewMore;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(onViewMore: onViewMore),
        SizedBox(height: 12.h),
        child,
      ],
    );
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
            'live_teaching_title'.tr,
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

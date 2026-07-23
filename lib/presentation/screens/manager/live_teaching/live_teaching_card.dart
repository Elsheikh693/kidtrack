import '../../../../index/index_main.dart';
import 'widgets/teaching_empty.dart';
import 'widgets/teaching_live_card.dart';
import 'widgets/live_pulse_dot.dart';

/// Manager-home card: a live list of every session in progress right now — each
/// whole-class حصة and subset نشاط as its own card with a ticking timer,
/// updating the moment a teacher starts or ends one. Tapping drills into the
/// teacher's day.
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _LiveNowBar(count: slices.length),
                  SizedBox(height: 10.h),
                  for (final s in slices) ...[
                    TeachingLiveCard(
                      slice: s,
                      onTap: () => controller.openTeacherDay(s),
                    ),
                    SizedBox(height: 10.h),
                  ],
                ],
              ),
      );
    });
  }
}

/// "مباشر الآن · N شغّالة" strip above the running-session cards.
class _LiveNowBar extends StatelessWidget {
  const _LiveNowBar({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LivePulseDot(color: AppColors.activityGreen, size: 7.w),
        SizedBox(width: 6.w),
        Text(
          'live_teaching_live_now'.tr,
          style: context.typography.smSemiBold.copyWith(
            color: AppColors.activityGreen,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          '·',
          style: context.typography.smSemiBold
              .copyWith(color: AppColors.textSecondaryParagraph),
        ),
        SizedBox(width: 6.w),
        Text(
          'live_teaching_running_count'.trParams({'count': '$count'}),
          style: context.typography.xsRegular
              .copyWith(color: AppColors.textSecondaryParagraph),
        ),
      ],
    );
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

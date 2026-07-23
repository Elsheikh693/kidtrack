import '../../../../../index/index_main.dart';
import 'section_header.dart';
import 'bus_tracking_sheet.dart';

class LiveAndActivitySection extends StatelessWidget {
  const LiveAndActivitySection({super.key, required this.controller});
  final ParentDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.effectiveStatus;
      final activity = controller.runningClassroomActivity.value;

      return Container(
        margin: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: status.color.withValues(alpha: status.isActive ? 0.14 : 0.06),
              blurRadius: 20.r,
              offset: Offset(0.w, 6.h)),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8.r,
              offset: Offset(0.w, 2.h)),
          ],
        ),
        child: Column(
          children: [
            // ── header ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0.h),
              child: ParentSectionHeader(
                titleKey: 'parent_live_track_title',
                onViewAll: () => Get.toNamed(parentTodayScheduleView),
                viewAllKey: 'parent_live_track_view_full',
                largeViewAll: true,
              ),
            ),
            // ── live status row ──────────────────────────────────────
            _LiveRow(
              color: status.color,
              icon: status.icon,
              label: status.label,
              isActive: status.isActive,
            ),
            // ── bus tracking button (only when child is on bus) ──────
            if (status.isOnBus)
              _BusTrackButton(
                onTap: () => showBusTrackingSheet(context, controller.branchId),
              ),
            // ── running classroom activity row ───────────────────────
            if (status.isActivity && activity != null) ...[
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Divider(
                  color: AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
                  height: 1,
                ),
              ),
              _ActivityRow(
                activityTitle: activity.title,
                subjectName: activity.subjectName ?? '',
                startTime: _formatTime(activity.startedAt),
                startedAgo: _timeAgo(activity.startedAt),
              ),
            ],
          ],
        ),
      );
    });
  }

  static String _formatTime(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String _timeAgo(int ms) {
    final diff =
        DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ms));
    if (diff.inMinutes < 1) return 'parentdash22_moments_ago'.tr;
    if (diff.inHours < 1) {
      return 'parentdash22_minutes_ago'.trParams({'n': '${diff.inMinutes}'});
    }
    return 'parentdash22_hours_ago'.trParams({'n': '${diff.inHours}'});
  }
}

// ── Live status row ───────────────────────────────────────────────────────────

class _LiveRow extends StatelessWidget {
  const _LiveRow({
    required this.color,
    required this.icon,
    required this.label,
    required this.isActive,
  });

  final Color color;
  final IconData icon;
  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
      child: Row(
        children: [
          if (isActive) ...[
            _LiveBadge(color: color),
            SizedBox(width: 14.w),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'parent_live_track_title'.tr,
                  style: context.typography.xsMedium.copyWith(color: AppColors.textSecondaryParagraph, fontSize: 11),
                ),
                SizedBox(height: 4.h),
                Text(
                  label,
                  style: context.typography.lgBold.copyWith(color: color, fontSize: 20, height: 1.1),
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    Icon(Icons.schedule_rounded,
                        size: 12.sp, color: AppColors.textSecondaryParagraph),
                    SizedBox(width: 4.w),
                    Text(
                      isActive
                          ? 'parentdash22_last_update_moments'.tr
                          : 'parentdash22_outside_nursery'.tr,
                      style: context.typography.xsRegular.copyWith(color: AppColors.textSecondaryParagraph, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 16.w),
          _PulsingIcon(color: color, icon: icon, isActive: isActive),
        ],
      ),
    );
  }
}

// ── Current activity row ──────────────────────────────────────────────────────

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.activityTitle,
    required this.subjectName,
    required this.startTime,
    required this.startedAgo,
  });

  final String activityTitle;
  final String subjectName;
  final String startTime;
  final String startedAgo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.auto_stories_rounded,
              color: AppColors.primary,
              size: 22.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _NowBadge(),
                    const Spacer(),
                    Icon(Icons.schedule_rounded,
                        size: 12.sp,
                        color: AppColors.textSecondaryParagraph),
                    SizedBox(width: 4.w),
                    Text(
                      startTime,
                      style: context.typography.smSemiBold.copyWith(color: AppColors.textSecondaryParagraph, fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 5.h),
                if (subjectName.isNotEmpty)
                  Text(
                    subjectName,
                    style: context.typography.xsMedium.copyWith(color: AppColors.primary, fontSize: 11),
                  ),
                Text(
                  activityTitle,
                  style: context.typography.smSemiBold
                      .copyWith(color: AppColors.textDefault),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(Icons.timelapse_rounded,
                        size: 12.sp,
                        color: AppColors.textSecondaryParagraph),
                    SizedBox(width: 4.w),
                    Text(
                      startedAgo,
                      style: context.typography.xsRegular.copyWith(
                        color: AppColors.textSecondaryParagraph,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Get.toNamed(parentTodayScheduleView),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'parent_edu_view_all_activities'.tr,
                            style: context.typography.xsMedium
                                .copyWith(color: AppColors.primary),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.arrow_forward_ios,
                              size: 11.sp, color: AppColors.primary),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NowBadge extends StatefulWidget {
  @override
  State<_NowBadge> createState() => _NowBadgeState();
}

class _NowBadgeState extends State<_NowBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: AppColors.primary
              .withValues(alpha: 0.08 + _ctrl.value * 0.06),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6.w,
              height: 6.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary
                    .withValues(alpha: 0.6 + _ctrl.value * 0.4),
              )),
            SizedBox(width: 4.w),
            Text(
              'parent_edu_live_now'.tr,
              style: context.typography.displaySmBold.copyWith(color: AppColors.primary, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Pulsing icon (status) ─────────────────────────────────────────────────────

class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon({
    required this.color,
    required this.icon,
    required this.isActive,
  });

  final Color color;
  final IconData icon;
  final bool isActive;

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _ring = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
    if (widget.isActive) _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64.w,
      height: 64.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (widget.isActive)
            AnimatedBuilder(
              animation: _ring,
              builder: (_, __) => Container(
                width: 64 * (0.8 + _ring.value * 0.4),
                height: 64 * (0.8 + _ring.value * 0.4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: widget.color
                        .withValues(alpha: (1 - _ring.value) * 0.35),
                    width: 1.5,
                  ),
                )),
            ),
          Container(
            width: 56.w,
            height: 56.h,
            decoration: BoxDecoration(
              color: widget.color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(widget.icon, color: widget.color, size: 26.sp)),
        ],
      ),
    );
  }
}

// ── Live badge (مباشر) ────────────────────────────────────────────────────────

class _LiveBadge extends StatefulWidget {
  const _LiveBadge({required this.color});
  final Color color;

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.08 + _ctrl.value * 0.06),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: widget.color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7.w,
              height: 7.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color
                    .withValues(alpha: 0.6 + _ctrl.value * 0.4),
                boxShadow: [
                  BoxShadow(
                    color: widget.color
                        .withValues(alpha: _ctrl.value * 0.5),
                    blurRadius: 4.r,
                    spreadRadius: 1.r),
                ],
              )),
            SizedBox(width: 5.w),
            Text(
              'parentdash22_live'.tr,
              style: context.typography.displaySmBold.copyWith(color: widget.color, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Bus track button ──────────────────────────────────────────────────────────

class _BusTrackButton extends StatelessWidget {
  const _BusTrackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 14.h),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0xFFD97706).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: const Color(0xFFD97706).withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_rounded,
                  size: 18.sp, color: Color(0xFFD97706)),
              SizedBox(width: 8.w),
              Text(
                'tracking_open_map'.tr,
                style: context.typography.displaySmBold.copyWith(color: Color(0xFFD97706), fontSize: 13),
              ),
            ],
          )),
      ),
    );
  }
}

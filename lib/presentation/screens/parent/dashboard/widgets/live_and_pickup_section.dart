import '../../../../../index/index_main.dart';
import 'bus_tracking_sheet.dart';
import 'pickup_request_sheet.dart';

/// Merged card: live tracking at top + pickup request at bottom.
/// Pickup area is only shown when the child is physically at the nursery.
class LiveAndPickupSection extends StatelessWidget {
  const LiveAndPickupSection({super.key, required this.controller});
  final ParentDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final status = controller.effectiveStatus;
      final activity = controller.runningClassroomActivity.value;
      final requested = controller.pickupRequested.value;
      final pickupEta = controller.pickupEta.value;
      final pickupStatus = controller.pickupStatus.value;
      final childFirst = controller.childName.split(' ').first;
      final isActive = controller.isChildActive;

      return Container(
        margin: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color:
                  status.color.withValues(alpha: status.isActive ? 0.16 : 0.06),
              blurRadius: 24.r,
              offset: Offset(0.w, 8.h)),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8.r,
              offset: Offset(0.w, 2.h)),
          ],
        ),
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0.h),
              child: Row(
                children: [
                  _StatusIconBox(color: status.color, icon: status.icon),
                  SizedBox(width: 10.w),
                  Text(
                    'parent_live_track_title'.tr,
                    style: context.typography.smSemiBold
                        .copyWith(color: AppColors.textDefault),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Get.toNamed(parentTodayScheduleView),
                    child: Row(
                      children: [
                        Text(
                          'parent_live_track_view_full'.tr,
                          style: context.typography.xsMedium
                              .copyWith(color: AppColors.primary),
                        ),
                        SizedBox(width: 3.w),
                        Icon(Icons.arrow_forward_ios,
                            size: 11.sp, color: AppColors.primary),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Live status row ───────────────────────────────────────────────
            _LiveStatusRow(
              color: status.color,
              icon: status.icon,
              label: status.label,
              isActive: status.isActive,
              checkInTime: controller.realCheckInTime,
            ),

            // ── Bus tracking button (only when on bus) ────────────────────────
            if (status.isOnBus)
              _BusTrackButton(
                onTap: () =>
                    showBusTrackingSheet(context, controller.branchId),
              ),

            // ── Running classroom activity row ────────────────────────────────
            if (status.isActivity && activity != null) ...[
              _SectionDivider(),
              _ActivityRow(
                activityTitle: activity.title,
                subjectName: activity.subjectName ?? '',
                startTime: _fmt(activity.startedAt),
                startedAgo: _ago(activity.startedAt),
              ),
            ],

            // ── Pickup section (child at nursery only) ────────────────────────
            if (isActive || requested) ...[
              _PickupDivider(),
              if (requested)
                _ActivePickup(
                  eta: pickupEta,
                  status: pickupStatus,
                  childName: childFirst,
                  onCancel: controller.cancelPickup,
                )
              else
                _IdlePickup(
                  controller: controller,
                  childName: childFirst,
                ),
            ],
          ],
        ),
      );
    });
  }

  static String _fmt(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  static String _ago(int ms) {
    final d = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ms));
    if (d.inMinutes < 1) return 'parentdash22_moments_ago'.tr;
    if (d.inHours < 1) {
      return 'parentdash22_minutes_ago'.trParams({'n': '${d.inMinutes}'});
    }
    return 'parentdash22_hours_ago'.trParams({'n': '${d.inHours}'});
  }
}

// ── Small icon box in header ──────────────────────────────────────────────────

class _StatusIconBox extends StatelessWidget {
  const _StatusIconBox({required this.color, required this.icon});
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 32.w,
      height: 32.h,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Icon(icon, color: color, size: 17.sp));
  }
}

// ── Live status row ───────────────────────────────────────────────────────────

class _LiveStatusRow extends StatelessWidget {
  const _LiveStatusRow({
    required this.color,
    required this.icon,
    required this.label,
    required this.isActive,
    required this.checkInTime,
  });

  final Color color;
  final IconData icon;
  final String label;
  final bool isActive;
  final String checkInTime;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: live badge + label + sub-info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isActive) ...[
                  _LiveBadge(color: color),
                  SizedBox(height: 8.h),
                ],
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 300),
                  style: context.typography.xlBold.copyWith(color: color, fontSize: 22, fontWeight: FontWeight.w800, height: 1.1),
                  child: Text(label),
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    if (isActive && checkInTime != '--:--') ...[
                      Icon(Icons.login_rounded,
                          size: 12.sp, color: const Color(0xFF059669)),
                      SizedBox(width: 4.w),
                      Text(
                        'parentdash22_checked_in_at'.trParams({'time': checkInTime}),
                        style: context.typography.smSemiBold.copyWith(color: Color(0xFF059669), fontSize: 11),
                      ),
                      SizedBox(width: 10.w),
                    ],
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
          // Right: pulsing icon
          _PulsingStatusIcon(color: color, icon: icon, isActive: isActive),
        ],
      ),
    );
  }
}

// ── Activity row ──────────────────────────────────────────────────────────────

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
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
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
            child: Icon(Icons.auto_stories_rounded,
                color: AppColors.primary, size: 22.sp)),
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
                        size: 12.sp, color: AppColors.textSecondaryParagraph),
                    SizedBox(width: 4.w),
                    Text(
                      startTime,
                      style: context.typography.smSemiBold.copyWith(color: AppColors.textSecondaryParagraph, fontSize: 12),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
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
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.timelapse_rounded,
                        size: 12.sp, color: AppColors.textSecondaryParagraph),
                    SizedBox(width: 4.w),
                    Text(startedAgo,
                        style: context.typography.xsRegular.copyWith(
                            color: AppColors.textSecondaryParagraph)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Get.toNamed(parentTodayScheduleView),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('parent_edu_view_all_activities'.tr,
                              style: context.typography.xsMedium
                                  .copyWith(color: AppColors.primary)),
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

// ── Pickup divider with label ─────────────────────────────────────────────────

class _PickupDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: Divider(
              color: AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
              height: 1,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.directions_car_rounded,
                    size: 13.sp, color: AppColors.textSecondaryParagraph),
                SizedBox(width: 5.w),
                Text(
                  'parentdash22_pickup'.tr,
                  style: context.typography.smSemiBold.copyWith(color: AppColors.textSecondaryParagraph, fontSize: 11),
                ),
              ],
            ),
          ),
          Expanded(
            child: Divider(
              color: AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
              height: 1,
            ),
          ),
          // History link
          GestureDetector(
            onTap: () => Get.toNamed(parentPickupHistoryView),
            child: Padding(
              padding: EdgeInsets.only(right: 4.w, left: 10.w),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'parentdash22_history'.tr,
                    style: context.typography.xsMedium
                        .copyWith(color: AppColors.primary),
                  ),
                  SizedBox(width: 3.w),
                  Icon(Icons.arrow_forward_ios,
                      size: 10.sp, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Simple divider ────────────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Divider(
        color: AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
        height: 1,
      ),
    );
  }
}

// ── Idle pickup body ──────────────────────────────────────────────────────────

class _IdlePickup extends StatelessWidget {
  const _IdlePickup({required this.controller, required this.childName});
  final ParentDashboardController controller;
  final String childName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => showPickupRequestSheet(context, controller),
          icon: Icon(Icons.directions_car_rounded, size: 18.sp),
          label: Text(
            'parentdash22_request_pickup_name'.trParams({'name': childName}),
            style: context.typography.displaySmBold.copyWith(fontSize: 14),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 13.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            elevation: 0,
          ),
        ),
      ),
    );
  }
}

// ── Active pickup body ────────────────────────────────────────────────────────

class _ActivePickup extends StatelessWidget {
  const _ActivePickup({
    required this.eta,
    required this.status,
    required this.childName,
    required this.onCancel,
  });

  final String eta;
  final String status;
  final String childName;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 16.h),
      child: Column(
        children: [
          _PickupStatusBanner(
              status: status, eta: eta, childName: childName),
          SizedBox(height: 10.h),
          GestureDetector(
            onTap: onCancel,
            child: Text(
              'parentdash22_cancel_pickup_request'.tr,
              style: context.typography.smSemiBold.copyWith(color: Color(0xFFDC2626), fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pickup status banner ──────────────────────────────────────────────────────

class _PickupStatusBanner extends StatelessWidget {
  const _PickupStatusBanner({
    required this.status,
    required this.eta,
    required this.childName,
  });

  final String status;
  final String eta;
  final String childName;

  @override
  Widget build(BuildContext context) {
    return switch (status) {
      'preparing' => _banner(
          gradient: const [Color(0xFFF97316), Color(0xFFFB923C)],
          shadowColor: const Color(0xFFF97316),
          icon: Icons.backpack_rounded,
          title: 'parentdash22_preparing_child'.trParams({'name': childName}),
          subtitle: 'parentdash22_ready_soon'.tr,
        ),
      _ => _banner(
          gradient: const [Color(0xFF059669), Color(0xFF10B981)],
          shadowColor: const Color(0xFF059669),
          icon: Icons.directions_car_rounded,
          title: 'parentdash22_on_the_way'.tr,
          subtitle: 'parentdash22_arriving_for_child'
              .trParams({'name': childName, 'eta': eta}),
          trailing: _etaBadge(eta),
        ),
    };
  }

  Widget _banner({
    required List<Color> gradient,
    required Color shadowColor,
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.25),
            blurRadius: 12.r,
            offset: Offset(0.w, 4.h)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.h,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 22.sp)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800)),
                SizedBox(height: 2.h),
                Text(subtitle,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 12)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }

  Widget _etaBadge(String eta) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Text(eta,
          style: const TextStyle(
              color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)));
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

// ── Pulsing status icon ───────────────────────────────────────────────────────

class _PulsingStatusIcon extends StatefulWidget {
  const _PulsingStatusIcon({
    required this.color,
    required this.icon,
    required this.isActive,
  });
  final Color color;
  final IconData icon;
  final bool isActive;

  @override
  State<_PulsingStatusIcon> createState() => _PulsingStatusIconState();
}

class _PulsingStatusIconState extends State<_PulsingStatusIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _ring;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1800));
    _ring = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
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
                    color:
                        widget.color.withValues(alpha: (1 - _ring.value) * 0.35),
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

// ── Live badge (مباشر ●) ──────────────────────────────────────────────────────

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
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
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
          color:
              widget.color.withValues(alpha: 0.08 + _ctrl.value * 0.06),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
              color: widget.color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7.w,
              height: 7.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    widget.color.withValues(alpha: 0.6 + _ctrl.value * 0.4),
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

// ── "الآن" badge ─────────────────────────────────────────────────────────────

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
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
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
              color: AppColors.primary.withValues(alpha: 0.3), width: 1),
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

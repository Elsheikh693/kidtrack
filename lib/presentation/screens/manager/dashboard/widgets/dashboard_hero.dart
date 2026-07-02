import '../../../../../index/index_main.dart';

/// Premium gradient header for the Branch Manager home. Combines a warm
/// time-based greeting, the quick actions (notifications + settings) and the
/// single most important live signal — today's child attendance — into one
/// cohesive focal surface that stays pinned above the scrolling content.
class DashboardHero extends StatelessWidget {
  const DashboardHero({super.key, required this.controller});

  final ManagerDashboardController controller;

  String get _greetingKey {
    final h = DateTime.now().hour;
    if (h < 12) return 'home_greeting_morning';
    if (h < 17) return 'home_greeting_afternoon';
    return 'home_greeting_evening';
  }

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, topInset + 14.h, 20.w, 22.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            AppColors.primary80,
            AppColors.primary,
            AppColors.primary60,
          ],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28.r)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _greetingKey.tr,
                      style: context.typography.xlBold
                          .copyWith(color: AppColors.white),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      arabicFullDate(),
                      style: context.typography.xsRegular.copyWith(
                        color: AppColors.white.withValues(alpha: 0.72),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _HeroAction(
                icon: Icons.search_rounded,
                onTap: controller.openChildrenSearch,
              ),
              SizedBox(width: 10.w),
              _HeroAction(
                icon: Icons.notifications_none_rounded,
                onTap: () => Get.toNamed(notificationsView),
              ),
              SizedBox(width: 10.w),
              _HeroAction(
                icon: Icons.settings_outlined,
                onTap: () => Get.toNamed(settingsView),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          _AttendanceFocal(controller: controller),
        ],
      ),
    );
  }
}

class _HeroAction extends StatelessWidget {
  const _HeroAction({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: AppColors.white.withValues(alpha: 0.16),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.white.withValues(alpha: 0.18)),
        ),
        child: Icon(icon, color: AppColors.white, size: 21.sp),
      ),
    );
  }
}

/// Translucent glass panel inside the hero: an attendance ring beside the
/// present/active headline and a present-vs-absent breakdown.
class _AttendanceFocal extends StatelessWidget {
  const _AttendanceFocal({required this.controller});

  final ManagerDashboardController controller;

  static const _presentDot = Color(0xFF6EE7B7);
  static const _absentDot = Color(0xFFFCD34D);

  @override
  Widget build(BuildContext context) {
    // The hero lives OUTSIDE the dashboard tab's isLoading Obx, so without its
    // own reactive scope this card would freeze on the initial 0/0 and never
    // reflect attendance once it loads. Wrap in Obx so it tracks the underlying
    // presentNow / activeChildren observables and rebuilds live.
    return Obx(() {
      final present = controller.presentChildren;
      final active = controller.activeChildren;
      final rate = controller.attendanceRate;

      return Container(
        padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.white.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          _Ring(rate: rate),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'manager_dashboard_today_attendance_title'.tr,
                  style: context.typography.xsMedium.copyWith(
                    color: AppColors.white.withValues(alpha: 0.75),
                  ),
                ),
                SizedBox(height: 3.h),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: '$present',
                        style: context.typography.xxlBold
                            .copyWith(color: AppColors.white),
                      ),
                      TextSpan(
                        text: ' / $active',
                        style: context.typography.smSemiBold.copyWith(
                          color: AppColors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    _MiniLegend(
                      color: _presentDot,
                      label: 'manager_dashboard_kpi_present_children'.tr,
                      value: '$present',
                    ),
                    SizedBox(width: 14.w),
                    _MiniLegend(
                      color: _absentDot,
                      label: 'manager_dashboard_kpi_absent_children'.tr,
                      value: '${controller.absentChildren}',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      );
    });
  }
}

class _Ring extends StatelessWidget {
  const _Ring({required this.rate});

  final int rate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 84.w,
      height: 84.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 84.w,
            height: 84.w,
            child: CircularProgressIndicator(
              value: (rate / 100).clamp(0.0, 1.0),
              strokeWidth: 8.w,
              strokeCap: StrokeCap.round,
              backgroundColor: AppColors.white.withValues(alpha: 0.22),
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$rate%',
                style: context.typography.mdBold.copyWith(
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniLegend extends StatelessWidget {
  const _MiniLegend({
    required this.color,
    required this.label,
    required this.value,
  });

  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(
          label,
          style: context.typography.xsRegular.copyWith(
            color: AppColors.white.withValues(alpha: 0.7),
          ),
        ),
        SizedBox(width: 5.w),
        Text(
          value,
          style: context.typography.smSemiBold.copyWith(color: AppColors.white),
        ),
      ],
    );
  }
}

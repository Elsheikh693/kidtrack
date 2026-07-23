import '../../../../../index/index_main.dart';

/// Quick entry points for the sections that used to sit in the bottom nav bar
/// (chat / finance / social). The bar got too crowded, so these moved up onto
/// the home as a three-up row — their pages still live in the stack and open
/// via [ManagerDashboardController.openTab].
class DashboardQuickLinks extends StatelessWidget {
  const DashboardQuickLinks({super.key, required this.controller});

  final ManagerDashboardController controller;

  // Stack page indices (see _managerPages in main_page_controller).
  static const _chatPage = 3;
  static const _financePage = 4;
  static const _socialPage = 5;
  static const _schedulePage = 7;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickLink(
          icon: Icons.forum_rounded,
          labelKey: 'chat_tab_label',
          color: const Color(0xFF6366F1),
          onTap: () => controller.openTab(_chatPage),
          badge: () => controller.chatUnread,
        ),
        SizedBox(width: 12.w),
        _QuickLink(
          icon: Icons.account_balance_wallet_rounded,
          labelKey: 'manager_tab_finance',
          color: const Color(0xFFD97706),
          onTap: () => controller.openTab(_financePage),
        ),
        SizedBox(width: 12.w),
        _QuickLink(
          icon: Icons.dynamic_feed_rounded,
          labelKey: 'manager_tab_social',
          color: const Color(0xFFEC4899),
          onTap: () => controller.openTab(_socialPage),
        ),
        SizedBox(width: 12.w),
        _QuickLink(
          icon: Icons.calendar_month_rounded,
          labelKey: 'manager_tab_schedule',
          color: const Color(0xFF2563EB),
          onTap: () => controller.openTab(_schedulePage),
        ),
      ],
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.icon,
    required this.labelKey,
    required this.color,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final String labelKey;
  final Color color;
  final VoidCallback onTap;

  /// Optional live unread count, read inside an [Obx] so the badge updates as
  /// messages arrive.
  final int Function()? badge;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 46.w,
                    height: 46.w,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Icon(icon, color: color, size: 23.sp),
                  ),
                  if (badge != null)
                    Positioned(
                      top: -6.h,
                      right: -6.w,
                      child: Obx(() {
                        final n = badge!();
                        if (n <= 0) return const SizedBox.shrink();
                        return ChatUnreadBadge(count: n);
                      }),
                    ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                labelKey.tr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.typography.xsMedium
                    .copyWith(color: AppColors.textDefault),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

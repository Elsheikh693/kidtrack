import '../../../../index/index_main.dart';

class NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnread ? AppColors.primaryLight : AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isUnread ? AppColors.primary.withValues(alpha: 0.3) : Colors.transparent,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.grayLight.withValues(alpha: 0.6),
              blurRadius: 6.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: EdgeInsets.all(14.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Icon ─────────────────────────────────────────────
            _NotifIcon(type: notification.type, isUnread: isUnread),

            SizedBox(width: 12.w),

            // ── Content ──────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: AppText(
                          text: notification.title,
                          textStyle: context.typography.smSemiBold.copyWith(
                            color: AppColors.textDefault,
                          ),
                          maxLines: 1,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          margin: EdgeInsets.only(right: 4.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  AppText(
                    text: notification.body,
                    textStyle: context.typography.xsRegular.copyWith(
                      color: AppColors.textSecondaryParagraph,
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      // Type chip
                      _TypeChip(type: notification.type),
                      const Spacer(),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // ── Delete ────────────────────────────────────────────
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 32.w,
                height: 32.w,
                decoration: BoxDecoration(
                  color: AppColors.errorBackground,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Center(
                  child: SvgPicture.asset(
                    IconsConstants.delete_btn,
                    width: 16.w,
                    height: 16.w,
                    colorFilter: const ColorFilter.mode(
                      AppColors.errorForeground,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Notification Icon ─────────────────────────────────────────────────────────

class _NotifIcon extends StatelessWidget {
  final String? type;
  final bool isUnread;

  const _NotifIcon({this.type, required this.isUnread});

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color bg;
    Color fg;

    switch (type) {
      case 'order_status':
        icon = Icons.receipt_long_rounded;
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0EA5E9);
        break;
      case 'promo':
        icon = Icons.local_offer_rounded;
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFF59E0B);
        break;
      default:
        icon = Icons.notifications_rounded;
        bg = AppColors.primaryLight;
        fg = AppColors.primary;
    }

    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Center(
        child: Icon(icon, size: 22.sp, color: fg),
      ),
    );
  }
}

// ── Type Chip ─────────────────────────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  final String? type;
  const _TypeChip({this.type});

  @override
  Widget build(BuildContext context) {
    final label = switch (type) {
      'order_status' => 'notif_type_order'.tr,
      'promo' => 'notif_type_promo'.tr,
      _ => 'notif_type_general'.tr,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundNeutral100,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: context.typography.xsRegular.copyWith(
          color: AppColors.textSecondaryParagraph,
        ),
      ),
    );
  }
}

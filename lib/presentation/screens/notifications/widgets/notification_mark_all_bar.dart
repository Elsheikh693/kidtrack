import '../../../../index/index_main.dart';
import '../controller.dart';

class NotificationMarkAllBar extends StatelessWidget {
  const NotificationMarkAllBar({super.key, required this.controller});

  final NotificationsController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.unreadCount == 0) return const SizedBox.shrink();
      return GestureDetector(
        onTap: controller.markAllAsRead,
        child: Container(
          color: AppColors.white,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(Icons.done_all_rounded, size: 16.sp, color: AppColors.primary),
              SizedBox(width: 6.w),
              AppText(
                text: 'notif_mark_all_read'.tr,
                textStyle: context.typography.smMedium.copyWith(color: AppColors.primary),
              ),
            ],
          ),
        ),
      );
    });
  }
}

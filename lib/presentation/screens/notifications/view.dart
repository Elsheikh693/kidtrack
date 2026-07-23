import '../../../index/index_main.dart';
import 'widgets/notification_card.dart';
import 'widgets/notification_empty.dart';
import 'widgets/notification_mark_all_bar.dart';
import 'widgets/notification_shimmer.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key, this.showSendButton = true});

  final bool showSendButton;

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  late final NotificationsController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => NotificationsController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundNeutral100,
      appBar: HomeAppBar(
        title: 'notif_title'.tr,
        showFilterIcon: false,
        showNotificationDot: false,
      ),
      floatingActionButton: widget.showSendButton && controller.canSendBroadcast
          ? FloatingActionButton(
              onPressed: controller.openSendSheet,
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
              elevation: 4,
              child: Icon(Icons.send_rounded, color: AppColors.white, size: 24.sp),
            )
          : null,
      body: Column(
        children: [
          NotificationMarkAllBar(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) return const NotificationShimmer();
              if (controller.notifications.isEmpty) return const NotificationEmpty();
              return RefreshIndicator(
                onRefresh: () async => NotificationStreamService.to.startListening(),
                color: AppColors.primary,
                backgroundColor: AppColors.white,
                child: ListView.separated(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 100.h),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount: controller.notifications.length,
                  separatorBuilder: (_, __) => SizedBox(height: 10.h),
                  itemBuilder: (_, i) {
                    final notif = controller.notifications[i];
                    return NotificationCard(
                      notification: notif,
                      onTap: () => controller.markAsRead(notif),
                      onDelete: () => controller.confirmDelete(notif),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

import 'package:firebase_database/firebase_database.dart';
import '../../../index/index_main.dart';
import 'widgets/send_notification_sheet.dart';

class NotificationsController extends GetxController {
  // ============================================================
  // OBSERVABLES
  // ============================================================

  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;

  // ============================================================
  // DEPENDENCIES
  // ============================================================

  late final NotificationStreamService _stream;
  final _sendService = NotificationSendService();
  final _session = SessionService();

  // ============================================================
  // LIFECYCLE
  // ============================================================

  @override
  void onInit() {
    super.onInit();
    _stream = NotificationStreamService.to;

    // Mirror stream into local observable (view binds to this)
    ever(_stream.notifications, (list) => notifications.value = List.from(list));
    ever(_stream.loading, (v) => isLoading.value = v);

    // Seed with current data if stream is already running
    isLoading.value = _stream.loading.value;
    notifications.value = List.from(_stream.notifications);

    _stream.startListening();
  }

  // ============================================================
  // MARK AS READ
  // ============================================================

  Future<void> markAsRead(NotificationModel notif) async {
    if (notif.isRead || notif.key == null) return;
    final userId = _session.userId;
    if (userId == null) return;

    try {
      await FirebaseDatabase.instance
          .ref('notifications/$userId/${notif.key}')
          .update({'isRead': true});
    } catch (_) {
      Loader.showError('notif_error_failed'.tr);
    }
  }

  Future<void> markAllAsRead() async {
    final userId = _session.userId;
    if (userId == null) return;

    final unread = notifications.where((n) => !n.isRead && n.key != null).toList();
    for (final n in unread) {
      await FirebaseDatabase.instance
          .ref('notifications/$userId/${n.key}')
          .update({'isRead': true});
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  void confirmDelete(NotificationModel notif) {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'notif_delete_title'.tr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('notif_delete_confirm'.tr),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('notif_cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _doDelete(notif);
            },
            child: Text(
              'notif_delete'.tr,
              style: TextStyle(color: AppColors.errorForeground, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _doDelete(NotificationModel notif) async {
    if (notif.key == null) return;
    final userId = _session.userId;
    if (userId == null) return;

    try {
      await FirebaseDatabase.instance
          .ref('notifications/$userId/${notif.key}')
          .remove();
    } catch (_) {
      Loader.showError('notif_error_failed'.tr);
    }
  }

  // ============================================================
  // SEND
  // ============================================================

  Future<void> sendNotification({
    required String title,
    required String body,
    required String type,
    required bool toAll,
    String? targetUserId,
  }) async {
    Loader.show();

    final notif = NotificationModel(
      userId: _session.userId ?? '',
      nurseryId: _session.nurseryId ?? '',
      title: title.trim(),
      body: body.trim(),
      type: type,
    );

    if (toAll) {
      final count = await _sendService.sendToAll(notif);
      if (count > 0) {
        Loader.showSuccess('${'notif_success_sent_all'.tr} ($count)');
      } else {
        Loader.showError('notif_error_no_users'.tr);
      }
    } else {
      if (targetUserId == null || targetUserId.trim().isEmpty) return;
      final success = await _sendService.sendToUser(targetUserId.trim(), notif);
      if (success) {
        Loader.showSuccess('notif_success_sent'.tr);
      } else {
        Loader.showError('notif_error_failed'.tr);
      }
    }
  }

  // ============================================================
  // DERIVED
  // ============================================================

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  String formatDate(int? ms) {
    if (ms == null) return '';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'notif_just_now'.tr;
    if (diff.inHours < 1) return '${diff.inMinutes} ${'notif_min_ago'.tr}';
    if (diff.inDays < 1) return '${diff.inHours} ${'notif_hr_ago'.tr}';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  // ============================================================
  // BOTTOM SHEET
  // ============================================================

  void openSendSheet() {
    Get.bottomSheet(
      SendNotificationSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    );
  }
}

import '../../../index/index_main.dart';

class NotificationParentService {
  final BaseService<NotificationModel> _service =
      Get.find<BaseService<NotificationModel>>(tag: "notifications");

  Future<void> getNotifications({
    required Function(List<NotificationModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> markAsRead({
    required NotificationModel notification,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.updateData(
      item: notification.copyWith(isRead: true),
      toJson: (item) => item.toJson(),
      id: notification.key ?? '',
      voidCallBack: callBack,
    );
  }

  Future<void> deleteNotification({
    required String id,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.deleteData(id: id, voidCallBack: callBack);
  }
}

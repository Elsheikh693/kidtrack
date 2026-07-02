import '../../../index/index_main.dart';

class NotificationSettingsController extends GetxController {
  static const _storageKey = 'notification_settings';

  final ordersEnabled = true.obs;
  final reservationsEnabled = true.obs;
  final promosEnabled = true.obs;
  final generalEnabled = true.obs;

  final _storage = StorageService();
  final _messaging = FirebaseMessaging.instance;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  void _load() {
    final data = _storage.getData(_storageKey);
    if (data == null) return;
    ordersEnabled.value = (data['orders'] as bool?) ?? true;
    reservationsEnabled.value = (data['reservations'] as bool?) ?? true;
    promosEnabled.value = (data['promos'] as bool?) ?? true;
    generalEnabled.value = (data['general'] as bool?) ?? true;
  }

  Future<void> setOrders(bool v) async {
    ordersEnabled.value = v;
    await _persist();
    await _syncTopic('orders', v);
  }

  Future<void> setReservations(bool v) async {
    reservationsEnabled.value = v;
    await _persist();
    await _syncTopic('reservations', v);
  }

  Future<void> setPromos(bool v) async {
    promosEnabled.value = v;
    await _persist();
    await _syncTopic('promos', v);
  }

  Future<void> setGeneral(bool v) async {
    generalEnabled.value = v;
    await _persist();
    await _syncTopic('general', v);
  }

  Future<void> _persist() async {
    await _storage.setData(_storageKey, {
      'orders': ordersEnabled.value,
      'reservations': reservationsEnabled.value,
      'promos': promosEnabled.value,
      'general': generalEnabled.value,
    });
    Loader.showSuccess('notif_settings_saved'.tr);
  }

  Future<void> _syncTopic(String topic, bool subscribe) async {
    try {
      if (subscribe) {
        await _messaging.subscribeToTopic(topic);
      } else {
        await _messaging.unsubscribeFromTopic(topic);
      }
    } catch (_) {}
  }
}

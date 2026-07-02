import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:get/get.dart';
import 'package:kidtrack/Global/services/session_service.dart';
import '../../Data/models/notification/notification_model.dart';
import '../../Global/Utils/logger.dart';
import '../../Global/constants/api_constants.dart';

/// Streams notifications for the current user from Firebase Realtime Database.
/// Path: notifications/{userId}/{notificationId}
class NotificationStreamService extends GetxController {
  static NotificationStreamService get to =>
      Get.find<NotificationStreamService>();

  // ─── Reactive state ───────────────────────────────────────────────────────

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool                    loading       = true.obs;

  // ─── Private ──────────────────────────────────────────────────────────────

  final List<StreamSubscription> _subs = [];
  String? _activeUserId;

  // ═══════════════════════════════════════════════════════════════════════════
  // Public
  // ═══════════════════════════════════════════════════════════════════════════

  /// Start streaming — call after login or guest session is ready.
  /// No-op if already streaming for the same user.
  Future<void> startListening() async {
    final userId = SessionService().userId;
    if (userId == null || userId.isEmpty) {
      AppLogger.warning('NOTIF_STREAM', 'No userId — skipping');
      return;
    }

    // Already streaming for this user — don't restart
    if (_subs.isNotEmpty && _activeUserId == userId) return;

    await _start(userId);
  }

  Future<void> stopListening() async {
    for (final s in List.of(_subs)) { await s.cancel(); }
    _subs.clear();
    _activeUserId = null;
    notifications.clear();
    loading.value = true;
    AppLogger.info('NOTIF_STREAM', 'Stopped listening');
  }

  // ─── Derived ──────────────────────────────────────────────────────────────

  int get unreadCount =>
      notifications.where((n) => !n.isRead).length;

  bool get hasUnread => unreadCount > 0;

  List<NotificationModel> get unread =>
      notifications.where((n) => !n.isRead).toList();

  // ═══════════════════════════════════════════════════════════════════════════
  // Private
  // ═══════════════════════════════════════════════════════════════════════════

  Future<void> _start(String userId) async {
    await stopListening();
    _activeUserId = userId;
    loading.value = true;

    final path = ApiConstants.notifications(userId);
    final ref  = FirebaseDatabase.instance.ref(path);

    AppLogger.info('NOTIF_STREAM', 'Listening → $path');

    _subs.addAll([
      // ── New notification ─────────────────────────────────────────────────
      ref.onChildAdded.listen(
        (event) {
          loading.value = false;
          final notif = _parse(event.snapshot);
          if (notif == null) return;

          final idx = notifications.indexWhere((n) => n.key == notif.key);
          if (idx == -1) {
            notifications.insert(0, notif); // newest first
          }
        },
        onError: (e) => AppLogger.error('NOTIF_STREAM', 'onAdded error: $e'),
      ),

      // ── Notification updated (e.g. isRead toggled) ───────────────────────
      ref.onChildChanged.listen(
        (event) {
          final notif = _parse(event.snapshot);
          if (notif == null) return;

          final idx = notifications.indexWhere((n) => n.key == notif.key);
          if (idx != -1) notifications[idx] = notif;
        },
        onError: (e) => AppLogger.error('NOTIF_STREAM', 'onChanged error: $e'),
      ),

      // ── Notification removed ─────────────────────────────────────────────
      ref.onChildRemoved.listen(
        (event) {
          final key = event.snapshot.key;
          if (key != null) notifications.removeWhere((n) => n.key == key);
        },
        onError: (e) => AppLogger.error('NOTIF_STREAM', 'onRemoved error: $e'),
      ),
    ]);

    // Fallback: stop loading after 3s (handles empty-data case where onChildAdded never fires)
    Future.delayed(const Duration(seconds: 3), () {
      if (loading.value) loading.value = false;
    });
  }

  NotificationModel? _parse(DataSnapshot snapshot) {
    try {
      final data = snapshot.value;
      if (data == null || data is! Map) return null;

      final json = Map<String, dynamic>.from(
        data.map((k, v) => MapEntry(k.toString(), v)),
      );
      json['key'] = snapshot.key;
      return NotificationModel.fromJson(json);
    } catch (e) {
      AppLogger.warning('NOTIF_STREAM', 'Parse error: $e');
      return null;
    }
  }

  // ─── GetX Lifecycle ───────────────────────────────────────────────────────

  @override
  void onClose() {
    stopListening();
    super.onClose();
  }
}

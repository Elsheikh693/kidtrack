import 'package:firebase_database/firebase_database.dart';
import 'package:uuid/uuid.dart';
import '../../Data/models/notification/notification_model.dart';
import '../../Global/Utils/logger.dart';

/// Writes notifications directly to Firebase RTDB.
/// Path: notifications/{userId}/{notifId}
///
/// Separate from NotificationStreamService (which only reads).
/// Used by admin to send notifications to customers.
class NotificationSendService {
  final _db = FirebaseDatabase.instance;

  Future<bool> sendToUser(String userId, NotificationModel notification) async {
    try {
      final id = const Uuid().v4();
      final notif = notification.copyWith(
        key: id,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _db.ref('notifications/$userId/$id').set(notif.toJson());
      AppLogger.info('NOTIF_SEND', 'Sent to $userId');
      return true;
    } catch (e) {
      AppLogger.error('NOTIF_SEND', 'Failed for $userId: $e');
      return false;
    }
  }

  Future<int> sendToAll(NotificationModel notification) async {
    try {
      final snapshot = await _db.ref('users').get();
      if (!snapshot.exists || snapshot.value == null) return 0;

      final data = snapshot.value;
      if (data is! Map) return 0;

      int sent = 0;
      for (final key in data.keys) {
        final success = await sendToUser(key.toString(), notification);
        if (success) sent++;
      }
      AppLogger.info('NOTIF_SEND', 'Broadcast sent to $sent users');
      return sent;
    } catch (e) {
      AppLogger.error('NOTIF_SEND', 'Broadcast failed: $e');
      return 0;
    }
  }
}

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import '../../Data/models/bus_tracking/bus_tracking_model.dart';
import '../../Global/Utils/logger.dart';
import 'notification_send_service.dart';
import '../../Data/models/notification/notification_model.dart';

// Firebase path: busTracking/{branchId}/{sessionId}

class BusTrackingService {
  static const _tag = 'BUS_TRACK';

  final _db = FirebaseDatabase.instance;
  final _notifService = NotificationSendService();

  StreamSubscription<Position>? _locationSub;
  StreamSubscription<DatabaseEvent>? _sessionSub;

  // ── Chaperone: start a session ────────────────────────────────────────────

  Future<String?> startSession({
    required String chaperoneId,
    required String chaperoneName,
    required String branchId,
    required List<BusChildEntry> children,
    required BusTripDirection direction,
  }) async {
    try {
      final now = DateTime.now();
      final sessionId = '${branchId}_${now.millisecondsSinceEpoch}';
      final dayStart =
          DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
      final session = BusSession(
        sessionId: sessionId,
        chaperoneId: chaperoneId,
        chaperoneName: chaperoneName,
        branchId: branchId,
        direction: direction,
        date: dayStart,
        status: 'active',
        children: children,
        createdAt: now.millisecondsSinceEpoch,
      );
      await _db
          .ref('busTracking/$branchId/$sessionId')
          .set(session.toJson());
      AppLogger.info(_tag, 'Session started: $sessionId');
      return sessionId;
    } catch (e) {
      AppLogger.error(_tag, 'startSession failed: $e');
      return null;
    }
  }

  // ── Chaperone: stream location updates to Firebase ────────────────────────

  void startLocationStream({
    required String branchId,
    required String sessionId,
    required List<BusChildEntry> children,
    required String chaperoneId,
  }) {
    stopLocationStream();

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
    );

    _locationSub = Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _db
          .ref('busTracking/$branchId/$sessionId/location')
          .set({'lat': pos.latitude, 'lng': pos.longitude, 'updatedAt': now});

      // Check proximity for each pending/onBus child
      for (final child in children) {
        if (child.status == ChildBusStatus.delivered) continue;
        // If child has address coordinates, we could check proximity here.
        // For now, proximity check is manual (chaperone taps "وصلت").
      }
    });
  }

  void stopLocationStream() {
    _locationSub?.cancel();
    _locationSub = null;
  }

  // ── Chaperone: mark child as onBus ───────────────────────────────────────

  Future<void> markChildOnBus({
    required String branchId,
    required String sessionId,
    required BusChildEntry child,
    required String nurseryId,
    required BusTripDirection direction,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _db
          .ref('busTracking/$branchId/$sessionId/children/${child.childId}')
          .update({
        'status': ChildBusStatus.onBus.name,
        'pickedUpAt': now,
        'updatedAt': now,
      });

      if (child.parentId != null) {
        final body = direction == BusTripDirection.toHome
            ? 'انطلق ${child.childName} من الحضانة في طريقه للمنزل'
            : 'تم استلام ${child.childName} من المنزل في طريقه للحضانة';
        await _notifService.sendToUser(
          child.parentId!,
          NotificationModel(
            userId: child.parentId!,
            nurseryId: nurseryId,
            title: 'الطفل في الحافلة',
            body: body,
            type: 'bus_on_bus',
            createdAt: now,
          ),
        );
      }
      AppLogger.info(_tag, 'Child ${child.childId} marked onBus');
    } catch (e) {
      AppLogger.error(_tag, 'markChildOnBus: $e');
    }
  }

  // ── Chaperone: mark child as delivered + notify parent ───────────────────

  Future<void> markChildDelivered({
    required String branchId,
    required String sessionId,
    required BusChildEntry child,
    required String nurseryId,
    required BusTripDirection direction,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _db
          .ref('busTracking/$branchId/$sessionId/children/${child.childId}')
          .update({
        'status': ChildBusStatus.delivered.name,
        'deliveredAt': now,
        'updatedAt': now,
      });

      if (child.parentId != null) {
        final body = direction == BusTripDirection.toHome
            ? 'وصل ${child.childName} إلى المنزل بأمان'
            : 'وصل ${child.childName} إلى الحضانة بأمان';
        await _notifService.sendToUser(
          child.parentId!,
          NotificationModel(
            userId: child.parentId!,
            nurseryId: nurseryId,
            title: 'الطفل وصل بأمان',
            body: body,
            type: 'bus_delivered',
            createdAt: now,
          ),
        );
      }
      AppLogger.info(_tag, 'Child ${child.childId} delivered');
    } catch (e) {
      AppLogger.error(_tag, 'markChildDelivered: $e');
    }
  }

  // ── Chaperone: send "near house" notification ─────────────────────────────

  Future<void> notifyNearHouse({
    required BusChildEntry child,
    required String? parentUserId,
    required String nurseryId,
  }) async {
    if (parentUserId == null) return;
    try {
      await _notifService.sendToUser(
        parentUserId,
        NotificationModel(
          userId: parentUserId,
          nurseryId: nurseryId,
          title: 'الحافلة قريبة',
          body: 'الحافلة في طريقها لتوصيل ${child.childName}، كن مستعداً',
          type: 'bus_near',
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      AppLogger.error(_tag, 'notifyNearHouse: $e');
    }
  }

  // ── Chaperone: end session ────────────────────────────────────────────────

  Future<void> endSession({
    required String branchId,
    required String sessionId,
  }) async {
    stopLocationStream();
    try {
      await _db.ref('busTracking/$branchId/$sessionId').update({
        'status': 'completed',
        'endedAt': DateTime.now().millisecondsSinceEpoch,
      });
      AppLogger.info(_tag, 'Session $sessionId completed');
    } catch (e) {
      AppLogger.error(_tag, 'endSession: $e');
    }
  }

  // ── Chaperone: history (completed sessions in a day range) ────────────────

  Future<List<BusSession>> getHistory({
    required String branchId,
    required String chaperoneId,
    required int dayStartMs,
    required int dayEndMs,
  }) async {
    try {
      final snap = await _db.ref('busTracking/$branchId').get();
      if (!snap.exists || snap.value == null) return [];
      final data = snap.value as Map? ?? {};
      final result = <BusSession>[];
      for (final entry in data.entries) {
        final raw = entry.value as Map<dynamic, dynamic>?;
        if (raw == null) continue;
        final session = BusSession.fromJson(entry.key.toString(), raw);
        final created = session.createdAt;
        if (session.chaperoneId == chaperoneId &&
            created >= dayStartMs &&
            created <= dayEndMs) {
          result.add(session);
        }
      }
      result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return result;
    } catch (e) {
      AppLogger.error(_tag, 'getHistory: $e');
      return [];
    }
  }

  // ── Parent: listen to active session for branch ───────────────────────────

  Stream<BusSession?> watchActiveSessions(String branchId) {
    return _db.ref('busTracking/$branchId').onValue.map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return null;
      final data = event.snapshot.value as Map? ?? {};
      for (final entry in data.entries) {
        final raw = entry.value as Map<dynamic, dynamic>?;
        if (raw == null) continue;
        if ((raw['status'] as String?) == 'active') {
          return BusSession.fromJson(entry.key.toString(), raw);
        }
      }
      return null;
    });
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  void dispose() {
    stopLocationStream();
    _sessionSub?.cancel();
  }
}

import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../Data/models/pickup_request/pickup_request_model.dart';
import '../Utils/logger.dart';

class PickupRealtimeService {
  static const _tag = 'PICKUP_RT';

  final _db = FirebaseDatabase.instance;

  DatabaseReference _ref(String nurseryId) =>
      _db.ref('platform/$nurseryId/pickupRequests');

  // ── Receptionist: watch all branch requests live ────────────────────────────

  Stream<List<PickupRequestModel>> watchBranchRequests(
      String nurseryId, String branchId) {
    final ctrl = StreamController<List<PickupRequestModel>>.broadcast();
    // Query all nursery-scoped requests; filter by branchId client-side
    // (also accepts empty branchId for backward compat with old requests).
    _ref(nurseryId).onValue.listen(
      (event) {
        try {
          final data = event.snapshot.value;
          if (data == null) {
            ctrl.add([]);
            return;
          }
          final map = Map<String, dynamic>.from(data as Map);
          final list = map.entries
              .map((e) => PickupRequestModel.fromJson(
                  Map<String, dynamic>.from(e.value as Map),
                  key: e.key))
              .where((r) =>
                  r.branchId.isEmpty || r.branchId == branchId)
              .toList()
            ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
          ctrl.add(list);
        } catch (e) {
          AppLogger.error(_tag, 'watchBranchRequests: $e');
          ctrl.add([]);
        }
      },
      onError: (e) {
        AppLogger.error(_tag, 'watchBranchRequests error: $e');
        ctrl.add([]);
      },
    );
    return ctrl.stream;
  }

  // ── Parent: watch a single request for status changes ──────────────────────

  Stream<PickupRequestModel?> watchRequest(
      String nurseryId, String requestKey) {
    final ctrl = StreamController<PickupRequestModel?>.broadcast();
    _ref(nurseryId).child(requestKey).onValue.listen(
      (event) {
        try {
          final data = event.snapshot.value;
          if (data == null) {
            ctrl.add(null);
            return;
          }
          ctrl.add(PickupRequestModel.fromJson(
              Map<String, dynamic>.from(data as Map),
              key: requestKey));
        } catch (e) {
          AppLogger.error(_tag, 'watchRequest: $e');
          ctrl.add(null);
        }
      },
      onError: (e) {
        AppLogger.error(_tag, 'watchRequest error: $e');
        ctrl.add(null);
      },
    );
    return ctrl.stream;
  }

  // ── Parent: create a new pickup request ─────────────────────────────────────

  Future<String?> createRequest(
      String nurseryId, PickupRequestModel request) async {
    try {
      final ref = _ref(nurseryId).push();
      final model = request.copyWith(key: ref.key);
      await ref.set(model.toJson());
      return ref.key;
    } catch (e) {
      AppLogger.error(_tag, 'createRequest: $e');
      return null;
    }
  }

  // ── Parent: cancel their active request ─────────────────────────────────────

  Future<bool> cancelRequest(String nurseryId, String requestKey) async {
    try {
      await _ref(nurseryId).child(requestKey).update({
        'status': 'cancelled',
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      return true;
    } catch (e) {
      AppLogger.error(_tag, 'cancelRequest: $e');
      return false;
    }
  }

  // ── Receptionist: advance request status ────────────────────────────────────

  Future<bool> updateStatus(
    String nurseryId,
    String requestKey,
    String status, {
    String? approvedBy,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };
      if (approvedBy != null) {
        updates['approvedBy'] = approvedBy;
        updates['approvedAt'] = DateTime.now().millisecondsSinceEpoch;
      }
      await _ref(nurseryId).child(requestKey).update(updates);
      return true;
    } catch (e) {
      AppLogger.error(_tag, 'updateStatus: $e');
      return false;
    }
  }

  // ── Parent: fetch completed pickup history ──────────────────────────────────

  Future<List<PickupRequestModel>> fetchCompletedByParent(
      String nurseryId, String parentId) async {
    try {
      final snap = await _ref(nurseryId)
          .orderByChild('parentId')
          .equalTo(parentId)
          .get();
      if (!snap.exists || snap.value == null) return [];
      final map = Map<String, dynamic>.from(snap.value as Map);
      final list = map.entries
          .map((e) => PickupRequestModel.fromJson(
              Map<String, dynamic>.from(e.value as Map),
              key: e.key))
          .where((r) => r.status == 'completed')
          .toList()
        ..sort((a, b) => (b.updatedAt ?? 0).compareTo(a.updatedAt ?? 0));
      return list;
    } catch (e) {
      AppLogger.error(_tag, 'fetchCompletedByParent: $e');
      return [];
    }
  }

  // ── Load all children names for a nursery ───────────────────────────────────

  Future<Map<String, String>> loadChildrenNames(String nurseryId) async {
    try {
      final snap = await _db.ref('platform/$nurseryId/children').get();
      if (!snap.exists || snap.value == null) return {};
      final map = Map<String, dynamic>.from(snap.value as Map);
      return {
        for (final e in map.entries)
          e.key: () {
            final d = Map<String, dynamic>.from(e.value as Map);
            return '${d['firstName'] ?? ''} ${d['lastName'] ?? ''}'.trim();
          }(),
      };
    } catch (e) {
      AppLogger.error(_tag, 'loadChildrenNames: $e');
      return {};
    }
  }
}

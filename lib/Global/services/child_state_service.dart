import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../Data/models/child_state_template/child_state_template_model.dart';
import '../../Data/models/child/child_model.dart';
import '../../Data/models/child_current_status/child_current_status_model.dart';
import '../../Data/models/child_daily_event/child_daily_event_model.dart';
import '../Utils/logger.dart';

// Real-time service for the child current state feature.
// Used by teacher to update individual child states (sleeping, eating, etc.)
// This is separate from classroom activities and attendance.
class ChildStateService {
  static const _tag = 'CHILD_STATE';
  final _db = FirebaseDatabase.instance;

  String _today() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  // ── Templates ─────────────────────────────────────────────────────────────

  Future<List<ChildStateTemplateModel>> loadActiveTemplates(
    String nurseryId,
  ) async {
    try {
      final snap =
          await _db.ref('platform/$nurseryId/childStateTemplates').get();
      if (!snap.exists || snap.value == null) return [];
      final map = snap.value as Map? ?? {};
      final list = map.entries
          .where((e) => e.value is Map)
          .map((e) => ChildStateTemplateModel.fromJson(
                Map<String, dynamic>.from(e.value as Map),
                key: e.key.toString(),
              ))
          .where((t) => t.isActive)
          .toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    } catch (e) {
      AppLogger.error(_tag, 'loadActiveTemplates: $e');
      return [];
    }
  }

  // ── Children ──────────────────────────────────────────────────────────────

  Future<List<ChildModel>> loadClassroomChildren(
    String nurseryId,
    String classroomId,
  ) async {
    try {
      final snap = await _db
          .ref('platform/$nurseryId/children')
          .orderByChild('classroomId')
          .equalTo(classroomId)
          .get();
      if (!snap.exists || snap.value == null) return [];
      final map = snap.value as Map? ?? {};
      final result = <ChildModel>[];
      for (final e in map.entries) {
        if (e.value is! Map) continue;
        final d = Map<String, dynamic>.from(e.value as Map);
        if ((d['status'] ?? 'active') != 'active') continue;
        result.add(ChildModel.fromJson(d, key: e.key.toString()));
      }
      result.sort((a, b) => a.fullName.compareTo(b.fullName));
      return result;
    } catch (e) {
      AppLogger.error(_tag, 'loadClassroomChildren: $e');
      return [];
    }
  }

  // ── State Watching ────────────────────────────────────────────────────────

  // Watches the entire childCurrentStatus node and returns only the
  // childIds requested. Efficient for classroom-level watching.
  Stream<Map<String, ChildCurrentStatusModel?>> watchChildrenStates(
    String nurseryId,
    List<String> childIds,
  ) {
    if (childIds.isEmpty) return Stream.value({});
    return _db
        .ref('platform/$nurseryId/childCurrentStatus')
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data == null) {
        return {for (final id in childIds) id: null};
      }
      final map = data as Map? ?? {};
      final result = <String, ChildCurrentStatusModel?>{};
      for (final id in childIds) {
        final val = map[id];
        if (val is Map) {
          result[id] = ChildCurrentStatusModel.fromJson(
            Map<String, dynamic>.from(val),
            childId: id,
          );
        } else {
          result[id] = null;
        }
      }
      return result;
    });
  }

  // ── State Update ──────────────────────────────────────────────────────────

  Future<bool> updateChildState({
    required String nurseryId,
    required String branchId,
    required String childId,
    required String teacherId,
    required String stateId,
    required String stateTitle,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final date = _today();
      final isDefault =
          stateId == kDefaultStateId || stateId.isEmpty;

      final eventRef = _db
          .ref('platform/$nurseryId/childDailyEvents/$date/$childId')
          .push();

      final event = {
        'childId': childId,
        'nurseryId': nurseryId,
        'branchId': branchId,
        'eventType': ChildEventType.childStateChanged,
        'source': ChildEventSource.teacher,
        'title': isDefault ? 'child_state_default_event_title' : stateTitle,
        'createdBy': teacherId,
        'createdByRole': ChildEventSource.teacher,
        'createdAt': now,
      };

      await _db.ref().update({
        'platform/$nurseryId/childCurrentStatus/$childId/currentStateId':
            isDefault ? null : stateId,
        'platform/$nurseryId/childCurrentStatus/$childId/currentStateTitle':
            isDefault ? null : stateTitle,
        'platform/$nurseryId/childCurrentStatus/$childId/currentStateStartedAt':
            isDefault ? null : now,
        'platform/$nurseryId/childCurrentStatus/$childId/updatedAt': now,
        'platform/$nurseryId/childCurrentStatus/$childId/updatedById':
            teacherId,
        'platform/$nurseryId/childCurrentStatus/$childId/updatedByRole':
            ChildEventSource.teacher,
        'platform/$nurseryId/childDailyEvents/$date/$childId/${eventRef.key}':
            event,
      });
      return true;
    } catch (e) {
      AppLogger.error(_tag, 'updateChildState: $e');
      return false;
    }
  }
}

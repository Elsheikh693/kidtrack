import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../Data/models/classroom_activity/classroom_activity_model.dart';
import '../../Data/models/assessment/assessment_model.dart';
import '../../Data/models/child/child_model.dart';
import '../../Data/models/child_daily_event/child_daily_event_model.dart';
import '../../Data/models/classroom/classroom_model.dart';
import '../../Data/models/classroom_post/classroom_post_model.dart';
import '../../Data/models/homework/homework_model.dart';
import '../../Data/models/homework_status/homework_status_model.dart';
import '../../Data/models/homework_submission/homework_submission_model.dart';
import '../../Data/models/note/note_model.dart';
import '../../Data/models/schedule/schedule_model.dart';
import '../../Data/models/session/session_model.dart';
import '../../Data/models/subject/subject_model.dart';
import '../../Global/Utils/logger.dart';
import 'session_service.dart';

// Firebase path: platform/{nurseryId}/classroomActivities/{classroomId}/{activityId}

class TeacherActivityService {
  static const _tag = 'TEACHER_ACTIVITY';

  final _db = FirebaseDatabase.instance;

  // ── Path helpers ─────────────────────────────────────────────────────────

  DatabaseReference _activitiesRef(String nurseryId, String classroomId) =>
      _db.ref('platform/$nurseryId/classroomActivities/$classroomId');

  DatabaseReference _activityRef(
    String nurseryId,
    String classroomId,
    String activityId,
  ) => _activitiesRef(nurseryId, classroomId).child(activityId);

  DatabaseReference _assessmentsRef(String nurseryId) =>
      _db.ref('platform/$nurseryId/assessments');

  // ── Classroom / Children / Subject Loading ───────────────────────────────

  Future<List<ClassroomModel>> resolveClassrooms(
    String nurseryId,
    String uid,
  ) async {
    final classrooms = <ClassroomModel>[];
    final loadedIds = <String>{};

    try {
      final staffSnap = await _db.ref('platform/$nurseryId/staff/$uid').get();
      if (staffSnap.exists && staffSnap.value is Map) {
        final d = Map<String, dynamic>.from(staffSnap.value as Map);
        final idsToLoad = <String>{};
        final single = d['classroomId']?.toString() ?? '';
        if (single.isNotEmpty) idsToLoad.add(single);
        final multi = d['classroomIds'];
        if (multi is List) {
          for (final v in multi) {
            if (v != null) idsToLoad.add(v.toString());
          }
        } else if (multi is Map) {
          for (final v in multi.values) {
            if (v != null) idsToLoad.add(v.toString());
          }
        }
        for (final cId in idsToLoad) {
          try {
            final cSnap = await _db
                .ref('platform/$nurseryId/classrooms/$cId')
                .get();
            if (cSnap.exists && cSnap.value is Map) {
              classrooms.add(
                ClassroomModel.fromJson(
                  Map<String, dynamic>.from(cSnap.value as Map),
                  key: cId,
                ),
              );
              loadedIds.add(cId);
            }
          } catch (_) {}
        }
      }
    } catch (_) {}

    try {
      final snap = await _db
          .ref('platform/$nurseryId/classrooms')
          .orderByChild('teacherId')
          .equalTo(uid)
          .get();
      if (snap.exists && snap.value is Map) {
        for (final e in (snap.value as Map).entries) {
          final key = e.key.toString();
          if (e.value is Map && !loadedIds.contains(key)) {
            classrooms.add(
              ClassroomModel.fromJson(
                Map<String, dynamic>.from(e.value as Map),
                key: key,
              ),
            );
          }
        }
      }
    } catch (_) {}

    classrooms.sort((a, b) => a.name.compareTo(b.name));
    return classrooms;
  }

  /// Display name of a staff member (e.g. the classroom's assigned teacher).
  /// Returns '' when the id is empty or the record/name is missing, so callers
  /// can simply hide the line.
  Future<String> resolveStaffName(String nurseryId, String staffId) async {
    if (staffId.isEmpty) return '';
    try {
      final snap =
          await _db.ref('platform/$nurseryId/staff/$staffId/name').get();
      final v = snap.value;
      return v == null ? '' : v.toString();
    } catch (_) {
      return '';
    }
  }

  Future<List<ChildModel>> loadChildren(
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
      final data = snap.value as Map? ?? {};
      return data.entries
          .where((e) => e.value is Map)
          .map(
            (e) => ChildModel.fromJson(
              Map<String, dynamic>.from(e.value as Map),
              key: e.key.toString(),
            ),
          )
          // A classroom may be shared across branches — keep only children of
          // the teacher's own branch (owners/unscoped users see all).
          .where((c) => c.status == 'active' && SessionService().seesBranch(c.branchId))
          .toList()
        ..sort((a, b) => a.firstName.compareTo(b.firstName));
    } catch (_) {
      return [];
    }
  }

  /// Of [childIds], the ones marked present today per the date-scoped
  /// `childAttendance` record (status present/late) — the SAME source the
  /// teacher home card, classroom-states sheet and reception dashboard use, so
  /// the counts can never drift. Reading the dated record (not the
  /// non-resetting childCurrentStatus cache) means a child checked in on a
  /// previous day and never checked out is NOT counted as present today.
  /// Returns null when nobody is present so callers can fall back to showing
  /// every child instead of an empty list.
  Future<Set<String>?> loadPresentChildIds(
    String nurseryId,
    List<String> childIds,
  ) async {
    if (childIds.isEmpty) return null;
    try {
      final date = _dateKey(DateTime.now().millisecondsSinceEpoch);
      final snap = await _db
          .ref('platform/$nurseryId/childAttendance')
          .orderByChild('date')
          .equalTo(date)
          .get();
      if (!snap.exists || snap.value == null) return null;
      final data = snap.value as Map? ?? {};
      final requested = childIds.toSet();
      final present = <String>{};
      for (final v in data.values) {
        if (v is! Map) continue;
        final status = v['status']?.toString();
        if (status != 'present' && status != 'late') continue;
        final childId = v['childId']?.toString();
        if (childId != null && requested.contains(childId)) {
          present.add(childId);
        }
      }
      return present.isEmpty ? null : present;
    } catch (_) {
      return null;
    }
  }

  Future<List<SubjectModel>> loadSubjects(String nurseryId) async {
    try {
      final snap = await _db.ref('platform/$nurseryId/subjects').get();
      if (!snap.exists || snap.value == null) return [];
      final data = snap.value as Map? ?? {};
      return data.entries
          .where((e) => e.value is Map)
          .map(
            (e) => SubjectModel.fromJson(
              Map<String, dynamic>.from(e.value as Map),
              key: e.key.toString(),
            ),
          )
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (_) {
      return [];
    }
  }

  // ── Photo upload / delete ─────────────────────────────────────────────────

  /// Reads the nursery-wide photo-approval policy
  /// (`platform/info/{nurseryId}/photosNeedApproval`). A missing value or any
  /// read error defaults to `true` (review required) to preserve the flow.
  Future<bool> _photosNeedApproval(String nurseryId) async {
    if (nurseryId.isEmpty) return true;
    try {
      final snap =
          await _db.ref('platform/info/$nurseryId/photosNeedApproval').get();
      final v = snap.value;
      return !(v == false || v == 0 || v == '0' || v == 'false');
    } catch (_) {
      return true;
    }
  }

  /// Uploads a photo for an activity. When the nursery requires review it is
  /// stored as `isApproved = false` (hidden from guardians) until a reviewer
  /// approves it; when review is turned off it is published immediately
  /// (`isApproved = true`). Returns the created [ActivityPhoto] so the caller
  /// can update local state.
  Future<ActivityPhoto?> uploadActivityPhoto({
    required String nurseryId,
    required String classroomId,
    required String activityId,
    required File file,
    String? uploadedBy,
  }) async {
    final photoId = DateTime.now().millisecondsSinceEpoch.toString();
    try {
      final autoApprove = !await _photosNeedApproval(nurseryId);
      final ref = FirebaseStorage.instance.ref(
        'platform/$nurseryId/activity_photos/$classroomId/$activityId/$photoId.jpg',
      );
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      final now = DateTime.now().millisecondsSinceEpoch;
      final photo = ActivityPhoto(
        id: photoId,
        url: url,
        isApproved: autoApprove,
        approvedBy: autoApprove ? (uploadedBy ?? 'auto') : null,
        approvedAt: autoApprove ? now : null,
        uploadedBy: uploadedBy,
        uploadedAt: now,
      );
      await addPhoto(
        nurseryId: nurseryId,
        classroomId: classroomId,
        activityId: activityId,
        photo: photo,
      );
      return photo;
    } catch (e) {
      AppLogger.error(_tag, 'uploadActivityPhoto: $e');
      return null;
    }
  }

  Future<void> deleteActivityPhoto({
    required String nurseryId,
    required String classroomId,
    required String activityId,
    required String photoId,
  }) async {
    await removePhoto(
      nurseryId: nurseryId,
      classroomId: classroomId,
      activityId: activityId,
      photoId: photoId,
    );
    try {
      await FirebaseStorage.instance
          .ref(
            'platform/$nurseryId/activity_photos/$classroomId/$activityId/$photoId.jpg',
          )
          .delete();
    } catch (_) {}
  }

  // ── Quick homework post ───────────────────────────────────────────────────

  Future<bool> postQuickHomework({
    required String nurseryId,
    required String classroomId,
    required String teacherId,
    required String title,
    String? description,
  }) async {
    try {
      final content = description != null && description.trim().isNotEmpty
          ? '$title\n${description.trim()}'
          : title;
      final model = ClassroomPostModel(
        key: DateTime.now().millisecondsSinceEpoch.toString(),
        nurseryId: nurseryId,
        classroomId: classroomId,
        postedBy: teacherId,
        content: content,
        type: 'homework',
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _db
          .ref('platform/$nurseryId/classroomPosts/${model.key}')
          .set(model.toJson());
      return true;
    } catch (e) {
      AppLogger.error(_tag, 'postQuickHomework: $e');
      return false;
    }
  }

  // ── Start activity ───────────────────────────────────────────────────────

  Future<({String? activityId, String? sessionId})> startActivity({
    required String nurseryId,
    required String branchId,
    required String classroomId,
    required String teacherId,
    required String title,
    required List<String> childIds,
    String? subjectId,
    String? subjectName,
    String mode = 'class',
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      // 1. Create the activity
      final ref = _activitiesRef(nurseryId, classroomId).push();
      final activityId = ref.key!;
      final activity = ClassroomActivityModel(
        key: activityId,
        nurseryId: nurseryId,
        classroomId: classroomId,
        branchId: branchId,
        subjectId: subjectId,
        subjectName: subjectName,
        title: title,
        teacherId: teacherId,
        status: 'active',
        startedAt: now,
        createdAt: now,
        childIds: childIds,
        mode: mode,
      );
      await ref.set(activity.toJson());

      // 2. Create a Session only when a subject is selected
      String? sessionId;
      if (subjectId != null && subjectId.isNotEmpty) {
        final dayStart = _dayStartMs(now);
        final sRef =
            _db.ref('platform/$nurseryId/sessions').push();
        sessionId = sRef.key!;
        final session = SessionModel(
          key: sessionId,
          nurseryId: nurseryId,
          classroomId: classroomId,
          branchId: branchId,
          subjectId: subjectId,
          subjectName: subjectName,
          teacherId: teacherId,
          date: dayStart,
          activityId: activityId,
          status: 'active',
          startedAt: now,
        );
        await sRef.set(session.toJson());
      }

      AppLogger.info(
          _tag,
          'Activity started: $activityId | session: $sessionId'
          ' (${childIds.length} children)');

      // 3. Fan-out to child daily events
      if (childIds.isNotEmpty) {
        await _fanOutActivityEvent(
          nurseryId: nurseryId,
          branchId: branchId,
          classroomId: classroomId,
          activityId: activityId,
          teacherId: teacherId,
          title: title,
          subjectName: subjectName,
          eventType: ChildEventType.activityStarted,
          childIds: childIds,
          now: now,
        );
      }

      return (activityId: activityId, sessionId: sessionId);
    } catch (e) {
      AppLogger.error(_tag, 'startActivity failed: $e');
      return (activityId: null, sessionId: null);
    }
  }

  // ── End activity + save assessments ─────────────────────────────────────

  Future<void> endActivity({
    required String nurseryId,
    required String branchId,
    required String classroomId,
    required String activityId,
    required ClassroomActivityModel activity,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      await _activityRef(
        nurseryId,
        classroomId,
        activityId,
      ).update({'status': 'completed', 'endedAt': now});

      // Save one AssessmentModel per evaluated child
      final batch = <Future>[];
      activity.evaluations.forEach((childId, levelKey) {
        final level = _mapEvalToAssessmentLevel(levelKey);
        final aRef = _assessmentsRef(nurseryId).push();
        final assessment = AssessmentModel(
          key: aRef.key,
          nurseryId: nurseryId,
          childId: childId,
          classroomId: classroomId,
          assessedBy: activity.teacherId,
          subjectId: activity.subjectId,
          title: activity.title,
          description: activity.notes[childId],
          level: level,
          date: now,
          createdAt: now,
        );
        batch.add(aRef.set(assessment.toJson()));
      });
      await Future.wait(batch);
      AppLogger.info(
        _tag,
        'Activity $activityId ended + ${activity.evaluations.length} assessments saved',
      );

      // Fan-out: write activity_completed to each child's daily timeline
      if (activity.childIds.isNotEmpty) {
        await _fanOutActivityEvent(
          nurseryId: nurseryId,
          branchId: branchId,
          classroomId: classroomId,
          activityId: activityId,
          teacherId: activity.teacherId,
          title: activity.title,
          subjectName: activity.subjectName,
          eventType: ChildEventType.activityCompleted,
          childIds: activity.childIds,
          now: now,
        );
      }
    } catch (e) {
      AppLogger.error(_tag, 'endActivity failed: $e');
    }
  }

  // ── End activity with full assessment + optional homework ─────────────────

  Future<void> endActivityWithData({
    required String nurseryId,
    required String branchId,
    required String classroomId,
    required String activityId,
    required ClassroomActivityModel activity,
    required Map<String, String> finalEvals,
    required Map<String, String> finalNotes,
    Map<String, List<String>> finalReasons = const {},
    String? groupNote,
    HomeworkModel? homework,
    String? sessionId,
  }) async {
    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      // 1. Single multi-path update: eval + notes + groupNote + status
      final updates = <String, dynamic>{};
      updates['status'] = 'completed';
      updates['endedAt'] = now;
      for (final e in finalEvals.entries) {
        updates['evaluations/${e.key}'] = e.value;
      }
      for (final e in finalNotes.entries) {
        if (e.value.isNotEmpty) {
          updates['notes/${e.key}'] = e.value;
        }
      }
      for (final e in finalReasons.entries) {
        if (e.value.isNotEmpty) {
          updates['childReasons/${e.key}'] = {
            for (int i = 0; i < e.value.length; i++) '$i': e.value[i],
          };
        }
      }
      if (groupNote != null && groupNote.isNotEmpty) {
        updates['groupNote'] = groupNote;
      }
      await _activityRef(nurseryId, classroomId, activityId).update(updates);

      // 2. Save one AssessmentModel per evaluated child + fan-out to parent
      final batch = <Future>[];
      finalEvals.forEach((childId, levelKey) {
        final level = _mapEvalToAssessmentLevel(levelKey);
        // Use structured reasons as description; fall back to free-text note
        final reasonsList = finalReasons[childId] ?? [];
        final description = reasonsList.isNotEmpty
            ? reasonsList.join('، ')
            : (finalNotes[childId]?.isNotEmpty == true
                ? finalNotes[childId]
                : null);

        final aRef = _assessmentsRef(nurseryId).push();
        final assessment = AssessmentModel(
          key: aRef.key,
          nurseryId: nurseryId,
          childId: childId,
          classroomId: classroomId,
          assessedBy: activity.teacherId,
          subjectId: activity.subjectId,
          title: activity.title,
          description: description,
          level: level,
          date: now,
          createdAt: now,
        );
        batch.add(aRef.set(assessment.toJson()));

        // Fan-out to parent-visible notes
        final noteText = description ?? '';
        final noteKey = 'act_${activityId}_$childId';
        final visibleRef = _db.ref('platform/$nurseryId/notes/$noteKey');
        if (noteText.isNotEmpty) {
          final noteModel = NoteModel(
            key: noteKey,
            nurseryId: nurseryId,
            childId: childId,
            classroomId: classroomId,
            createdBy: activity.teacherId,
            content: noteText,
            type: 'parent_note',
            category: _evalToNoteCategory(levelKey),
            isVisibleToGuardian: true,
            createdAt: now,
          );
          batch.add(visibleRef.set(noteModel.toJson()));
        } else {
          batch.add(visibleRef.remove());
        }
      });

      // 3. Save homework + fan-out to childDailyEvents
      String? homeworkId;
      if (homework != null) {
        final hwRef = _db.ref('platform/$nurseryId/homework').push();
        homeworkId = hwRef.key!;
        final hw = homework.copyWith(
          key: homeworkId,
          sessionId: sessionId,
          createdAt: now,
        );
        batch.add(hwRef.set(hw.toJson()));

        if (activity.childIds.isNotEmpty) {
          final eventsRoot = _db.ref(
            'platform/$nurseryId/childDailyEvents/${_dateKey(now)}',
          );
          for (final childId in activity.childIds) {
            final eRef = eventsRoot.child(childId).push();
            final event = ChildDailyEventModel(
              id: eRef.key!,
              childId: childId,
              nurseryId: nurseryId,
              branchId: branchId,
              eventType: ChildEventType.homeworkAssigned,
              source: ChildEventSource.teacher,
              title: 'واجب جديد: ${hw.title}',
              activityId: activityId,
              classroomId: classroomId,
              subjectName: hw.subjectName,
              createdBy: activity.teacherId,
              createdByRole: 'teacher',
              createdAt: now,
            );
            batch.add(eRef.set(event.toJson()));
          }
        }
      }

      // 4. Complete the session
      if (sessionId != null) {
        final sessionUpdates = <String, dynamic>{
          'status': 'completed',
          'endedAt': now,
        };
        if (homeworkId != null) {
          sessionUpdates['homeworkId'] = homeworkId;
        }
        batch.add(
          _db
              .ref('platform/$nurseryId/sessions/$sessionId')
              .update(sessionUpdates),
        );
      }

      // 5. Fan-out activity_completed
      if (activity.childIds.isNotEmpty) {
        batch.add(
          _fanOutActivityEvent(
            nurseryId: nurseryId,
            branchId: branchId,
            classroomId: classroomId,
            activityId: activityId,
            teacherId: activity.teacherId,
            title: activity.title,
            subjectName: activity.subjectName,
            eventType: ChildEventType.activityCompleted,
            childIds: activity.childIds,
            now: now,
          ),
        );
      }

      await Future.wait(batch);
      AppLogger.info(
        _tag,
        'endWithData: $activityId | evals=${finalEvals.length} | hw=${homework != null}',
      );
    } catch (e) {
      AppLogger.error(_tag, 'endActivityWithData failed: $e');
    }
  }

  // ── Update evaluation for a child ────────────────────────────────────────

  Future<void> updateEvaluation({
    required String nurseryId,
    required String classroomId,
    required String activityId,
    required String childId,
    required EvalLevel level,
  }) async {
    try {
      await _activityRef(
        nurseryId,
        classroomId,
        activityId,
      ).child('evaluations/$childId').set(level.key);
    } catch (e) {
      AppLogger.error(_tag, 'updateEvaluation: $e');
    }
  }

  // ── Remove evaluation for a child (toggle off) ───────────────────────────

  Future<void> removeEvaluation({
    required String nurseryId,
    required String classroomId,
    required String activityId,
    required String childId,
  }) async {
    try {
      await _activityRef(
        nurseryId,
        classroomId,
        activityId,
      ).child('evaluations/$childId').remove();
    } catch (e) {
      AppLogger.error(_tag, 'removeEvaluation: $e');
    }
  }

  // ── Add / update note for a child ────────────────────────────────────────

  Future<void> saveNote({
    required String nurseryId,
    required String classroomId,
    required String activityId,
    required String childId,
    required String note,
    String teacherId = '',
  }) async {
    // Deterministic key so we can update/remove by the same key
    final noteKey = 'act_${activityId}_$childId';
    final visibleNotesRef = _db.ref('platform/$nurseryId/notes/$noteKey');

    try {
      if (note.trim().isEmpty) {
        await Future.wait([
          _activityRef(
            nurseryId,
            classroomId,
            activityId,
          ).child('notes/$childId').remove(),
          visibleNotesRef.remove(),
        ]);
      } else {
        final noteText = note.trim();
        final now = DateTime.now().millisecondsSinceEpoch;
        final noteModel = NoteModel(
          key: noteKey,
          nurseryId: nurseryId,
          childId: childId,
          classroomId: classroomId,
          createdBy: teacherId,
          content: noteText,
          type: 'parent_note',
          category: 'info',
          isVisibleToGuardian: true,
          createdAt: now,
        );
        await Future.wait([
          _activityRef(
            nurseryId,
            classroomId,
            activityId,
          ).child('notes/$childId').set(noteText),
          visibleNotesRef.set(noteModel.toJson()),
        ]);
      }
    } catch (e) {
      AppLogger.error(_tag, 'saveNote: $e');
    }
  }

  // ── Stream active activity for classroom ─────────────────────────────────

  Stream<ClassroomActivityModel?> watchActiveActivity(
    String nurseryId,
    String classroomId, {
    String? teacherId,
  }) {
    return _activitiesRef(
      nurseryId,
      classroomId,
    ).orderByChild('status').equalTo('active').onValue.map((
      event,
    ) {
      if (!event.snapshot.exists || event.snapshot.value == null) return null;
      final data = event.snapshot.value as Map? ?? {};
      // The active activity is scoped to the teacher who started it: co-teachers
      // sharing a classroom each see only their own running activity. When no
      // teacherId is given (parent side) the latest active one is returned.
      ClassroomActivityModel? latest;
      for (final entry in data.entries) {
        final raw = entry.value;
        if (raw is! Map) continue;
        final activity = ClassroomActivityModel.fromJson(
          raw,
          key: entry.key.toString(),
        );
        if (teacherId != null &&
            teacherId.isNotEmpty &&
            activity.teacherId != teacherId) {
          continue;
        }
        if (latest == null || activity.startedAt > latest.startedAt) {
          latest = activity;
        }
      }
      return latest;
    });
  }

  // ── Get today's completed activities ─────────────────────────────────────

  Future<List<ClassroomActivityModel>> getTodayCompleted(
    String nurseryId,
    String classroomId, {
    String? teacherId,
  }) async {
    try {
      final todayStart = _todayStartMillis();
      final snap = await _activitiesRef(
        nurseryId,
        classroomId,
      ).orderByChild('startedAt').startAt(todayStart).get();
      if (!snap.exists || snap.value == null) return [];
      final data = snap.value as Map? ?? {};
      return data.entries
          .where((e) => e.value is Map)
          .map(
            (e) => ClassroomActivityModel.fromJson(
              e.value as Map,
              key: e.key.toString(),
            ),
          )
          .where((a) => a.status == 'completed')
          // Scope to the teacher's own completed activities when requested.
          .where((a) =>
              teacherId == null ||
              teacherId.isEmpty ||
              a.teacherId == teacherId)
          .toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    } catch (e) {
      AppLogger.error(_tag, 'getTodayCompleted: $e');
      return [];
    }
  }

  // ── Get completed activities for a date range ────────────────────────────

  Future<List<ClassroomActivityModel>> getCompletedForDateRange(
    String nurseryId,
    String classroomId, {
    required int startMs,
    required int endMs,
    String? teacherId,
  }) async {
    try {
      final snap = await _activitiesRef(nurseryId, classroomId)
          .orderByChild('startedAt')
          .startAt(startMs.toDouble())
          .endAt(endMs.toDouble())
          .get();
      if (!snap.exists || snap.value == null) return [];
      final data = snap.value as Map? ?? {};
      return data.entries
          .where((e) => e.value is Map)
          .map(
            (e) => ClassroomActivityModel.fromJson(
              e.value as Map,
              key: e.key.toString(),
            ),
          )
          .where((a) => a.status == 'completed')
          // Scope to the teacher's own completed activities when requested.
          .where((a) =>
              teacherId == null ||
              teacherId.isEmpty ||
              a.teacherId == teacherId)
          .toList()
        ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    } catch (e) {
      AppLogger.error(_tag, 'getCompletedForDateRange: $e');
      return [];
    }
  }

  // ── Aggregate completed activities across many classrooms ────────────────
  // Used by the manager teacher-performance reports: fans out one ranged read
  // per classroom in parallel and flattens the result.

  Future<List<ClassroomActivityModel>> getCompletedForClassrooms(
    String nurseryId,
    List<String> classroomIds, {
    required int startMs,
    required int endMs,
  }) async {
    if (classroomIds.isEmpty) return [];
    final batches = await Future.wait(classroomIds.map(
      (id) => getCompletedForDateRange(
        nurseryId,
        id,
        startMs: startMs,
        endMs: endMs,
      ),
    ));
    return [for (final b in batches) ...b];
  }

  // ── Live "what's being taught now" across many classrooms ────────────────
  // Fans out one `status == active` read per classroom in parallel. Used by the
  // manager home donut to show which classes are currently in session.

  Future<List<ClassroomActivityModel>> getActiveForClassrooms(
    String nurseryId,
    List<String> classroomIds,
  ) async {
    if (classroomIds.isEmpty) return [];
    final batches = await Future.wait(classroomIds.map((id) async {
      try {
        final snap = await _activitiesRef(nurseryId, id)
            .orderByChild('status')
            .equalTo('active')
            .get();
        if (!snap.exists || snap.value == null) {
          return <ClassroomActivityModel>[];
        }
        final data = snap.value as Map? ?? {};
        return data.entries
            .where((e) => e.value is Map)
            .map((e) => ClassroomActivityModel.fromJson(
                  e.value as Map,
                  key: e.key.toString(),
                ))
            .toList();
      } catch (e) {
        AppLogger.error(_tag, 'getActiveForClassrooms($id): $e');
        return <ClassroomActivityModel>[];
      }
    }));
    return [for (final b in batches) ...b];
  }

  /// Real-time version of [getActiveForClassrooms]: streams the set of
  /// `status == active` activities across the given classrooms, re-emitting the
  /// merged list whenever any teacher starts or ends one. Powers the manager
  /// home "what's being taught now" card so it updates live — no hot reload.
  Stream<List<ClassroomActivityModel>> watchActiveForClassrooms(
    String nurseryId,
    List<String> classroomIds,
  ) {
    if (nurseryId.isEmpty || classroomIds.isEmpty) {
      return Stream.value(const []);
    }
    final controller =
        StreamController<List<ClassroomActivityModel>>.broadcast();
    final latest = <String, List<ClassroomActivityModel>>{};
    final subs = <StreamSubscription>[];

    void emit() {
      final all = <ClassroomActivityModel>[
        for (final list in latest.values) ...list,
      ]..sort((a, b) => a.startedAt.compareTo(b.startedAt));
      controller.add(all);
    }

    for (final cId in classroomIds) {
      final sub = _activitiesRef(nurseryId, cId)
          .orderByChild('status')
          .equalTo('active')
          .onValue
          .listen((event) {
        final data = event.snapshot.value as Map? ?? {};
        final list = <ClassroomActivityModel>[];
        for (final e in data.entries) {
          if (e.value is! Map) continue;
          list.add(ClassroomActivityModel.fromJson(
            e.value as Map,
            key: e.key.toString(),
          ));
        }
        latest[cId] = list;
        emit();
      }, onError: (e) => AppLogger.error(_tag, 'watchActive($cId): $e'));
      subs.add(sub);
    }

    controller.onCancel = () async {
      for (final s in subs) {
        await s.cancel();
      }
    };
    return controller.stream;
  }

  // ── Today's activities (any status) across many classrooms ───────────────
  // Powers the per-teacher day drill-down: everything started today, so both
  // the running activity and already-completed ones show in one timeline.

  Future<List<ClassroomActivityModel>> getTodayForClassrooms(
    String nurseryId,
    List<String> classroomIds,
  ) async {
    if (classroomIds.isEmpty) return [];
    final todayStart = _todayStartMillis();
    final batches = await Future.wait(classroomIds.map((id) async {
      try {
        final snap = await _activitiesRef(nurseryId, id)
            .orderByChild('startedAt')
            .startAt(todayStart)
            .get();
        if (!snap.exists || snap.value == null) {
          return <ClassroomActivityModel>[];
        }
        final data = snap.value as Map? ?? {};
        return data.entries
            .where((e) => e.value is Map)
            .map((e) => ClassroomActivityModel.fromJson(
                  e.value as Map,
                  key: e.key.toString(),
                ))
            .toList();
      } catch (e) {
        AppLogger.error(_tag, 'getTodayForClassrooms($id): $e');
        return <ClassroomActivityModel>[];
      }
    }));
    return [for (final b in batches) ...b];
  }

  // ── Photo management ─────────────────────────────────────────────────────

  Future<void> addPhoto({
    required String nurseryId,
    required String classroomId,
    required String activityId,
    required ActivityPhoto photo,
  }) async {
    try {
      await _activityRef(
        nurseryId,
        classroomId,
        activityId,
      ).child('photos/${photo.id}').set(photo.toJson());
    } catch (e) {
      AppLogger.error(_tag, 'addPhoto: $e');
    }
  }

  // ── Reviewer: approval & audience ────────────────────────────────────────

  /// Approves the given pending photos of an activity in one batch — they flip
  /// to `isApproved = true` and become visible to guardians together.
  Future<void> approveActivityPhotos({
    required String nurseryId,
    required String classroomId,
    required String activityId,
    required List<String> photoIds,
    required String approvedBy,
  }) async {
    if (photoIds.isEmpty) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final updates = <String, dynamic>{
      // Clear the review-notification debounce flag so a later batch of photos
      // on this activity notifies reviewers again (see photoReviewTriggers.js).
      'reviewNotifiedAt': null,
    };
    for (final id in photoIds) {
      updates['photos/$id/isApproved'] = true;
      updates['photos/$id/approvedBy'] = approvedBy;
      updates['photos/$id/approvedAt'] = now;
    }
    try {
      await _activityRef(nurseryId, classroomId, activityId).update(updates);
    } catch (e) {
      AppLogger.error(_tag, 'approveActivityPhotos: $e');
    }
  }

  /// Sets a single photo's audience (classroom-wide or a set of children).
  /// Clears `targetChildren` when switching back to classroom-wide.
  Future<void> updatePhotoAudience({
    required String nurseryId,
    required String classroomId,
    required String activityId,
    required String photoId,
    required AudienceType audienceType,
    List<String> targetChildren = const [],
  }) async {
    final ref = _activityRef(nurseryId, classroomId, activityId)
        .child('photos/$photoId');
    try {
      await ref.update({
        'audienceType': audienceType.key,
        'targetChildren':
            audienceType == AudienceType.children ? targetChildren : null,
      });
    } catch (e) {
      AppLogger.error(_tag, 'updatePhotoAudience: $e');
    }
  }

  /// Real-time stream of today's activities that still have pending photos,
  /// merged across the reviewer's classrooms. Used by the media-approval screen.
  Stream<List<ClassroomActivityModel>> watchPendingActivitiesForClassrooms(
    String nurseryId,
    List<String> classroomIds,
  ) {
    if (nurseryId.isEmpty || classroomIds.isEmpty) {
      return Stream.value(const []);
    }
    final todayStart = _todayStartMillis();
    final controller =
        StreamController<List<ClassroomActivityModel>>.broadcast();
    final latest = <String, List<ClassroomActivityModel>>{};
    final subs = <StreamSubscription>[];

    void emit() {
      final all = <ClassroomActivityModel>[
        for (final list in latest.values) ...list,
      ]..sort((a, b) => b.startedAt.compareTo(a.startedAt));
      controller.add(all);
    }

    for (final cId in classroomIds) {
      final sub = _activitiesRef(nurseryId, cId)
          .orderByChild('startedAt')
          .startAt(todayStart.toDouble())
          .onValue
          .listen((event) {
        final data = event.snapshot.value as Map? ?? {};
        final list = <ClassroomActivityModel>[];
        for (final e in data.entries) {
          if (e.value is! Map) continue;
          final act = ClassroomActivityModel.fromJson(
            e.value as Map,
            key: e.key.toString(),
          );
          if (act.hasPendingPhotos) list.add(act);
        }
        latest[cId] = list;
        emit();
      }, onError: (e) => AppLogger.error(_tag, 'watchPending($cId): $e'));
      subs.add(sub);
    }

    controller.onCancel = () async {
      for (final s in subs) {
        await s.cancel();
      }
    };
    return controller.stream;
  }

  Future<void> removePhoto({
    required String nurseryId,
    required String classroomId,
    required String activityId,
    required String photoId,
  }) async {
    try {
      await _activityRef(
        nurseryId,
        classroomId,
        activityId,
      ).child('photos/$photoId').remove();
    } catch (e) {
      AppLogger.error(_tag, 'removePhoto: $e');
    }
  }

  // ── Group note ────────────────────────────────────────────────────────────

  Future<void> saveGroupNote({
    required String nurseryId,
    required String classroomId,
    required String activityId,
    required String note,
  }) async {
    try {
      if (note.trim().isEmpty) {
        await _activityRef(
          nurseryId,
          classroomId,
          activityId,
        ).child('groupNote').remove();
      } else {
        await _activityRef(
          nurseryId,
          classroomId,
          activityId,
        ).child('groupNote').set(note.trim());
      }
    } catch (e) {
      AppLogger.error(_tag, 'saveGroupNote: $e');
    }
  }

  // ── Bulk evaluation ───────────────────────────────────────────────────────

  Future<void> bulkEvaluation({
    required String nurseryId,
    required String classroomId,
    required String activityId,
    required List<String> childIds,
    required EvalLevel level,
  }) async {
    if (childIds.isEmpty) return;
    try {
      final updates = <String, dynamic>{
        for (final id in childIds) 'evaluations/$id': level.key,
      };
      await _activityRef(nurseryId, classroomId, activityId).update(updates);
    } catch (e) {
      AppLogger.error(_tag, 'bulkEvaluation: $e');
    }
  }

  // ── Today's schedule for classroom ───────────────────────────────────────

  Future<List<ScheduleModel>> getTodayScheduleForClassroom({
    required String nurseryId,
    required String classroomId,
  }) async {
    try {
      final dayName = _todayDayName();
      final snap = await _db
          .ref('platform/$nurseryId/schedules')
          .orderByChild('classroomId')
          .equalTo(classroomId)
          .get();
      if (!snap.exists || snap.value == null) return [];
      final data = snap.value as Map? ?? {};
      return data.entries
          .where((e) => e.value is Map)
          .map(
            (e) => ScheduleModel.fromJson(
              Map<String, dynamic>.from(e.value as Map),
              key: e.key.toString(),
            ),
          )
          .where((s) => s.day == dayName)
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
    } catch (e) {
      AppLogger.error(_tag, 'getTodaySchedule: $e');
      return [];
    }
  }

  // ── Fan-out to childDailyEvents ──────────────────────────────────────────

  Future<void> _fanOutActivityEvent({
    required String nurseryId,
    required String branchId,
    required String classroomId,
    required String activityId,
    required String teacherId,
    required String title,
    required String eventType,
    required List<String> childIds,
    required int now,
    String? subjectName,
  }) async {
    final dateKey = _dateKey(now);
    final eventsRoot = _db.ref('platform/$nurseryId/childDailyEvents/$dateKey');

    final label = eventType == ChildEventType.activityStarted
        ? 'بدأ نشاط: $title'
        : 'انتهى نشاط: $title';

    final batch = <Future>[];
    for (final childId in childIds) {
      final eventRef = eventsRoot.child(childId).push();
      final event = ChildDailyEventModel(
        id: eventRef.key!,
        childId: childId,
        nurseryId: nurseryId,
        branchId: branchId,
        eventType: eventType,
        source: ChildEventSource.teacher,
        title: label,
        activityId: activityId,
        classroomId: classroomId,
        subjectName: subjectName,
        createdBy: teacherId,
        createdByRole: 'teacher',
        createdAt: now,
      );
      batch.add(eventRef.set(event.toJson()));
    }
    await Future.wait(batch);
    AppLogger.info(_tag, 'Fan-out $eventType → ${childIds.length} children');
  }

  // ── Get homework by classroom ─────────────────────────────────────────────

  Future<List<HomeworkModel>> getHomeworkByClassroom({
    required String nurseryId,
    required String classroomId,
    int? fromMs,
  }) async {
    try {
      final snap = await _db
          .ref('platform/$nurseryId/homework')
          .orderByChild('classroomId')
          .equalTo(classroomId)
          .get();
      if (!snap.exists || snap.value == null) return [];
      final data = snap.value as Map? ?? {};
      var list = data.entries
          .where((e) => e.value is Map)
          .map((e) => HomeworkModel.fromJson(
                Map<dynamic, dynamic>.from(e.value as Map),
                key: e.key.toString(),
              ))
          .toList();
      if (fromMs != null) {
        list = list.where((hw) => (hw.createdAt ?? 0) >= fromMs).toList();
      }
      list.sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
      return list;
    } catch (e) {
      AppLogger.error(_tag, 'getHomeworkByClassroom: $e');
      return [];
    }
  }

  /// Nursery school days as Dart weekday ints (Mon=1 … Sun=7). Falls back to
  /// "every day except Friday" when unset. Nursery info lives at
  /// `platform/info/{nurseryId}` (note: NOT `platform/{nurseryId}/info`).
  Future<List<int>> getNurseryWorkingDays(String nurseryId) async {
    const fallback = [1, 2, 3, 4, 6, 7];
    if (nurseryId.isEmpty) return fallback;
    try {
      final snap =
          await _db.ref('platform/info/$nurseryId/workingDays').get();
      final raw = snap.value;
      Iterable<dynamic>? items;
      if (raw is List) items = raw;
      if (raw is Map) items = raw.values;
      if (items == null) return fallback;
      final days = items
          .map((e) => int.tryParse(e.toString()))
          .whereType<int>()
          .where((d) => d >= 1 && d <= 7)
          .toSet()
          .toList()
        ..sort();
      return days.isEmpty ? fallback : days;
    } catch (e) {
      AppLogger.error(_tag, 'getNurseryWorkingDays: $e');
      return fallback;
    }
  }

  // ── Session + Homework tracking ───────────────────────────────────────────

  Future<SessionModel?> getLastCompletedSession({
    required String nurseryId,
    required String classroomId,
    required String subjectId,
  }) async {
    try {
      final snap = await _db
          .ref('platform/$nurseryId/sessions')
          .orderByChild('subjectId')
          .equalTo(subjectId)
          .limitToLast(50)
          .get();
      if (!snap.exists || snap.value == null) return null;
      final data = Map<dynamic, dynamic>.from(snap.value as Map);
      final list = data.entries
          .where((e) => e.value is Map)
          .map((e) => SessionModel.fromJson(
                Map<dynamic, dynamic>.from(e.value as Map),
                key: e.key.toString(),
              ))
          .where((s) =>
              s.classroomId == classroomId &&
              s.status == 'completed' &&
              s.homeworkId != null)
          .toList()
        ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
      return list.isEmpty ? null : list.first;
    } catch (e) {
      AppLogger.error(_tag, 'getLastCompletedSession: $e');
      return null;
    }
  }

  Future<HomeworkModel?> getHomeworkById({
    required String nurseryId,
    required String homeworkId,
  }) async {
    try {
      final snap =
          await _db.ref('platform/$nurseryId/homework/$homeworkId').get();
      if (!snap.exists || snap.value == null) return null;
      return HomeworkModel.fromJson(
        Map<dynamic, dynamic>.from(snap.value as Map),
        key: homeworkId,
      );
    } catch (e) {
      AppLogger.error(_tag, 'getHomeworkById: $e');
      return null;
    }
  }

  Future<Map<String, HomeworkStatus>> getHomeworkStatuses({
    required String nurseryId,
    required String homeworkId,
  }) async {
    try {
      final snap = await _db
          .ref('platform/$nurseryId/homeworkStatus/$homeworkId')
          .get();
      if (!snap.exists || snap.value == null) return {};
      final data = Map<dynamic, dynamic>.from(snap.value as Map);
      return Map.fromEntries(data.entries
          .where((e) => e.value is Map)
          .map((e) {
            final statusKey =
                (Map<dynamic, dynamic>.from(e.value as Map))['status']
                        ?.toString() ??
                    '';
            return MapEntry(
              e.key.toString(),
              HomeworkStatusX.fromKey(statusKey),
            );
          }));
    } catch (e) {
      AppLogger.error(_tag, 'getHomeworkStatuses: $e');
      return {};
    }
  }

  /// Parent submissions for a homework, keyed by childId. Each carries the
  /// parent's confirmation that it was done at home plus their optional
  /// "how did it go" answers (needed help / guided hand / did it easily).
  Future<Map<String, HomeworkSubmissionModel>> getHomeworkSubmissions({
    required String nurseryId,
    required String homeworkId,
  }) async {
    try {
      final snap = await _db
          .ref('platform/$nurseryId/homeworkSubmissions/$homeworkId')
          .get();
      if (!snap.exists || snap.value == null) return {};
      final data = Map<dynamic, dynamic>.from(snap.value as Map);
      return Map.fromEntries(data.entries.where((e) => e.value is Map).map(
            (e) => MapEntry(
              e.key.toString(),
              HomeworkSubmissionModel.fromJson(
                Map<dynamic, dynamic>.from(e.value as Map),
                homeworkId: homeworkId,
                childId: e.key.toString(),
              ),
            ),
          ));
    } catch (e) {
      AppLogger.error(_tag, 'getHomeworkSubmissions: $e');
      return {};
    }
  }

  Future<void> saveAllHomeworkStatuses({
    required String nurseryId,
    required String homeworkId,
    required String classroomId,
    required Map<String, HomeworkStatus> statuses,
    required String teacherId,
  }) async {
    if (statuses.isEmpty) return;
    try {
      final now = DateTime.now().millisecondsSinceEpoch;
      final updates = <String, dynamic>{};
      for (final e in statuses.entries) {
        updates['platform/$nurseryId/homeworkStatus/$homeworkId/${e.key}'] = {
          'homeworkId': homeworkId,
          'childId': e.key,
          'nurseryId': nurseryId,
          'classroomId': classroomId,
          'status': e.value.key,
          'markedBy': teacherId,
          'markedAt': now,
        };
      }
      await _db.ref().update(updates);
    } catch (e) {
      AppLogger.error(_tag, 'saveAllHomeworkStatuses: $e');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  static String _dateKey(int epochMs) {
    final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static int _todayStartMillis() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
  }

  static int _dayStartMs(int epochMs) {
    final d = DateTime.fromMillisecondsSinceEpoch(epochMs);
    return DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
  }

  static String _todayDayName() {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return days[DateTime.now().weekday - 1];
  }

  static String _mapEvalToAssessmentLevel(String evalKey) {
    switch (evalKey) {
      case 'excellent':
        return 'excellent';
      case 'needs_follow':
        return 'average';
      case 'needs_attention':
        return 'needs_improvement';
      default:
        return 'good';
    }
  }

  static String _evalToNoteCategory(String evalKey) {
    switch (evalKey) {
      case 'excellent':
        return 'positive';
      case 'needs_follow':
        return 'needs_follow';
      case 'needs_attention':
        return 'important';
      default:
        return 'info';
    }
  }
}

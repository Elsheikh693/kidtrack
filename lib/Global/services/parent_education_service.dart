import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
import '../../Data/models/note/note_model.dart';
import '../../Data/models/assessment/assessment_model.dart';
import '../../Data/models/homework/homework_model.dart';
import '../../Data/models/homework_submission/homework_submission_model.dart';
import '../../Data/models/lesson_plan/lesson_plan_model.dart';
import '../../Data/models/subject/subject_model.dart';
import '../../Data/models/classroom_activity/classroom_activity_model.dart';
import 'teacher_activity_service.dart';
import '../Utils/logger.dart';

class ParentEducationService {
  static const _tag = 'PARENT_EDU';
  final _db = FirebaseDatabase.instance;
  final _activitySvc = TeacherActivityService();

  // Today's activity photos for a classroom (real-time aggregation).
  // Only approved photos the given child may see (classroom-wide or targeted).
  Stream<List<String>> watchTodayPhotos(
      String nurseryId, String classroomId, String childId) {
    if (nurseryId.isEmpty || classroomId.isEmpty) return Stream.value([]);
    final todayStart = _todayStartMillis();
    return _db
        .ref('platform/$nurseryId/classroomActivities/$classroomId')
        .orderByChild('startedAt')
        .startAt(todayStart)
        .onValue
        .map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return <String>[];
      }
      final data = event.snapshot.value as Map? ?? {};
      final photos = <String>[];
      for (final e in data.entries) {
        if (e.value is! Map) continue;
        final act = ClassroomActivityModel.fromJson(
          e.value as Map,
          key: e.key.toString(),
        );
        photos.addAll(act.approvedUrlsForChild(childId));
      }
      return photos;
    });
  }

  // Activity photos for a SINGLE day only — the gallery fetches one day at a
  // time (never the whole history at once). Each photo carries the activity's
  // title + timestamp.
  Stream<List<ClassPhoto>> watchPhotosForDay(
      String nurseryId, String classroomId, DateTime day, String childId) {
    if (nurseryId.isEmpty || classroomId.isEmpty) {
      return Stream.value(const []);
    }
    final dayStart =
        DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;
    final dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59, 999)
        .millisecondsSinceEpoch;
    return _db
        .ref('platform/$nurseryId/classroomActivities/$classroomId')
        .orderByChild('startedAt')
        .startAt(dayStart)
        .endAt(dayEnd)
        .onValue
        .map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return <ClassPhoto>[];
      }
      final data = event.snapshot.value as Map? ?? {};
      final result = <ClassPhoto>[];
      for (final e in data.entries) {
        if (e.value is! Map) continue;
        final act = ClassroomActivityModel.fromJson(
          e.value as Map,
          key: e.key.toString(),
        );
        final label = (act.subjectName?.isNotEmpty == true)
            ? act.subjectName!
            : act.title;
        for (final p in act.photos.values) {
          // Only approved photos this child may see.
          if (!p.isApproved || !p.visibleTo(childId)) continue;
          result.add(ClassPhoto(
            url: p.url,
            takenAt: act.startedAt,
            activityTitle: label,
            isPrivate: !p.isClassroomWide,
          ));
        }
      }
      result.sort((a, b) => b.takenAt.compareTo(a.takenAt));
      return result;
    });
  }

  // Today's notes visible to parent for specific child (real-time)
  Stream<List<NoteModel>> watchTodayNotes(
      String nurseryId, String childId) {
    if (nurseryId.isEmpty || childId.isEmpty) return Stream.value([]);
    final todayStart = _todayStartMillis();
    return watchVisibleNotes(nurseryId, childId).map(
      (notes) => notes.where((n) => (n.createdAt ?? 0) >= todayStart).toList(),
    );
  }

  // Notes visible to parent for a child on a SINGLE past day (history view)
  Stream<List<NoteModel>> watchNotesForDay(
      String nurseryId, String childId, DateTime day) {
    if (nurseryId.isEmpty || childId.isEmpty) return Stream.value([]);
    final start =
        DateTime(day.year, day.month, day.day).millisecondsSinceEpoch;
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59, 999)
        .millisecondsSinceEpoch;
    return watchVisibleNotes(nurseryId, childId).map(
      (notes) => notes.where((n) {
        final t = n.createdAt ?? 0;
        return t >= start && t <= end;
      }).toList(),
    );
  }

  static int _todayStartMillis() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
  }

  // Notes visible to parent for specific child (real-time)
  Stream<List<NoteModel>> watchVisibleNotes(
      String nurseryId, String childId) {
    return _db
        .ref('platform/$nurseryId/notes')
        .orderByChild('childId')
        .equalTo(childId)
        .onValue
        .map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];
      final data = event.snapshot.value as Map? ?? {};
      final list = data.entries
          .where((e) => e.value is Map)
          .map((e) => NoteModel.fromJson(
                Map<String, dynamic>.from(e.value as Map),
                key: e.key.toString(),
              ))
          .where((n) => n.isVisibleToGuardian)
          .toList()
        ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
      return list;
    });
  }

  // One-time read: guardian-visible teacher notes for a child within a date
  // range. Used by the manager child-profile screen (no live stream needed).
  Future<List<NoteModel>> getNotesForRange(
    String nurseryId,
    String childId, {
    required int startMs,
    required int endMs,
  }) async {
    if (nurseryId.isEmpty || childId.isEmpty) return [];
    try {
      final snap = await _db
          .ref('platform/$nurseryId/notes')
          .orderByChild('childId')
          .equalTo(childId)
          .get();
      if (!snap.exists || snap.value == null) return [];
      final data = snap.value as Map? ?? {};
      return data.entries
          .where((e) => e.value is Map)
          .map((e) => NoteModel.fromJson(
                Map<String, dynamic>.from(e.value as Map),
                key: e.key.toString(),
              ))
          .where((n) => n.isVisibleToGuardian)
          .where((n) {
            final t = n.createdAt ?? 0;
            return t >= startMs && t <= endMs;
          })
          .toList()
        ..sort((a, b) => (b.createdAt ?? 0).compareTo(a.createdAt ?? 0));
    } catch (e) {
      AppLogger.error(_tag, 'getNotesForRange: $e');
      return [];
    }
  }

  // Classroom name lookup (one-time read)
  Future<String> getClassroomName(String nurseryId, String classroomId) async {
    try {
      final snap = await _db
          .ref('platform/$nurseryId/classrooms/$classroomId')
          .get();
      if (!snap.exists || snap.value == null) return '';
      final data = snap.value as Map? ?? {};
      return data['name']?.toString() ?? '';
    } catch (e) {
      AppLogger.error(_tag, 'getClassroomName: $e');
      return '';
    }
  }

  // Active classroom activity (real-time)
  Stream<ClassroomActivityModel?> watchActiveActivity(
      String nurseryId, String classroomId) {
    return _activitySvc.watchActiveActivity(nurseryId, classroomId);
  }

  // Today's completed activities for classroom
  Future<List<ClassroomActivityModel>> getTodayActivities(
      String nurseryId, String classroomId) {
    return _activitySvc.getTodayCompleted(nurseryId, classroomId);
  }

  // Completed activities within a date range (for subject-grouped education view)
  Future<List<ClassroomActivityModel>> getActivitiesForRange(
    String nurseryId,
    String classroomId, {
    required int startMs,
    required int endMs,
  }) {
    return _activitySvc.getCompletedForDateRange(
      nurseryId,
      classroomId,
      startMs: startMs,
      endMs: endMs,
    );
  }

  // Most recent assessment per subject for a child (real-time stream)
  Stream<List<AssessmentModel>> watchRecentAssessments(
      String nurseryId, String childId) {
    if (nurseryId.isEmpty || childId.isEmpty) return Stream.value([]);
    return _db
        .ref('platform/$nurseryId/assessments')
        .orderByChild('childId')
        .equalTo(childId)
        .onValue
        .map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];
      final data = event.snapshot.value as Map? ?? {};
      final all = data.entries
          .where((e) => e.value is Map)
          .map((e) => AssessmentModel.fromJson(
                Map<String, dynamic>.from(e.value as Map),
                key: e.key.toString(),
              ))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      // one most-recent entry per subjectId/title
      final seen = <String>{};
      final result = <AssessmentModel>[];
      for (final a in all) {
        final bucket = a.subjectId?.isNotEmpty == true ? a.subjectId! : a.title;
        if (seen.add(bucket)) result.add(a);
      }
      return result;
    });
  }

  // All assessments for a child (real-time, not deduped) — for date filtering
  Stream<List<AssessmentModel>> watchAllAssessments(
      String nurseryId, String childId) {
    if (nurseryId.isEmpty || childId.isEmpty) return Stream.value([]);
    return _db
        .ref('platform/$nurseryId/assessments')
        .orderByChild('childId')
        .equalTo(childId)
        .onValue
        .map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) return [];
      final data = event.snapshot.value as Map? ?? {};
      return data.entries
          .where((e) => e.value is Map)
          .map((e) => AssessmentModel.fromJson(
                Map<String, dynamic>.from(e.value as Map),
                key: e.key.toString(),
              ))
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    });
  }

  // Most recent assessment per subject for a child (one-time, kept for compatibility)
  Future<List<AssessmentModel>> getRecentAssessments(
      String nurseryId, String childId) async {
    try {
      return await watchRecentAssessments(nurseryId, childId).first;
    } catch (e) {
      AppLogger.error(_tag, 'getRecentAssessments: $e');
      return [];
    }
  }

  // Current week's lesson plans for a classroom
  Future<List<LessonPlanModel>> getWeekLessonPlans(
      String nurseryId, String classroomId) async {
    try {
      final weekStart = _weekStartMillis();
      final snap = await _db
          .ref('platform/$nurseryId/lessonPlans')
          .orderByChild('classroomId')
          .equalTo(classroomId)
          .get();
      if (!snap.exists || snap.value == null) return [];
      final data = snap.value as Map? ?? {};
      return data.entries
          .where((e) => e.value is Map)
          .map((e) => LessonPlanModel.fromJson(
                Map<String, dynamic>.from(e.value as Map),
                key: e.key.toString(),
              ))
          .where((lp) => lp.weekStart >= weekStart)
          .toList()
        ..sort((a, b) => a.weekStart.compareTo(b.weekStart));
    } catch (e) {
      AppLogger.error(_tag, 'getWeekLessonPlans: $e');
      return [];
    }
  }

  // All subjects for nursery (for name lookup)
  Future<List<SubjectModel>> loadSubjects(String nurseryId) async {
    try {
      final snap = await _db.ref('platform/$nurseryId/subjects').get();
      if (!snap.exists || snap.value == null) return [];
      final data = snap.value as Map? ?? {};
      return data.entries
          .where((e) => e.value is Map)
          .map((e) => SubjectModel.fromJson(
                Map<String, dynamic>.from(e.value as Map),
                key: e.key.toString(),
              ))
          .toList();
    } catch (e) {
      AppLogger.error(_tag, 'loadSubjects: $e');
      return [];
    }
  }

  // ── Homework ──────────────────────────────────────────────────────────────

  /// Real-time stream of active (non-expired) homework for a classroom.
  /// Shows homework where dueDate >= today, or (no dueDate AND created today).
  Stream<List<HomeworkModel>> watchClassroomHomework(
      String nurseryId, String classroomId) {
    if (nurseryId.isEmpty || classroomId.isEmpty) return Stream.value([]);
    final todayStart = _todayStartMillis();

    return _db
        .ref('platform/$nurseryId/homework')
        .orderByChild('classroomId')
        .equalTo(classroomId)
        .onValue
        .map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return <HomeworkModel>[];
      }
      final data = event.snapshot.value as Map? ?? {};
      final list = data.entries
          .where((e) => e.value is Map)
          .map((e) => HomeworkModel.fromJson(
                e.value as Map,
                key: e.key.toString(),
              ))
          .where((hw) {
            // has a due date → show until that day passes
            if (hw.dueDate != null) return hw.dueDate! >= todayStart;
            // no due date → show only if assigned today
            return (hw.createdAt ?? 0) >= todayStart;
          })
          .toList()
        ..sort((a, b) {
          final aMs = a.dueDate ?? a.createdAt ?? 0;
          final bMs = b.dueDate ?? b.createdAt ?? 0;
          return aMs.compareTo(bMs);
        });
      return list;
    });
  }

  /// Real-time stream of ALL homework for a classroom (no active/expiry filter).
  /// Used by the per-day journal, which scopes homework to the viewed day itself
  /// rather than to "now" — so past days can show homework that is already due.
  Stream<List<HomeworkModel>> watchAllClassroomHomework(
      String nurseryId, String classroomId) {
    if (nurseryId.isEmpty || classroomId.isEmpty) return Stream.value([]);
    return _db
        .ref('platform/$nurseryId/homework')
        .orderByChild('classroomId')
        .equalTo(classroomId)
        .onValue
        .map((event) {
      if (!event.snapshot.exists || event.snapshot.value == null) {
        return <HomeworkModel>[];
      }
      final data = event.snapshot.value as Map? ?? {};
      return data.entries
          .where((e) => e.value is Map)
          .map((e) => HomeworkModel.fromJson(
                e.value as Map,
                key: e.key.toString(),
              ))
          .toList()
        ..sort((a, b) {
          final aMs = a.dueDate ?? a.createdAt ?? 0;
          final bMs = b.dueDate ?? b.createdAt ?? 0;
          return aMs.compareTo(bMs);
        });
    });
  }

  // ── Homework submissions (parent completion events) ────────────────────────
  // A submission is the parent's confirmation that the homework was done at
  // home. Stored at homeworkSubmissions/{homeworkId}/{childId} so the teacher
  // can read all submissions for a homework in one place. Carries no quality
  // judgment — the teacher's review is a separate record.

  /// Which of [homeworkIds] this child has already submitted.
  Future<Set<String>> getSubmittedHomeworkIds(
      String nurseryId, String childId, List<String> homeworkIds) async {
    if (nurseryId.isEmpty || childId.isEmpty || homeworkIds.isEmpty) {
      return <String>{};
    }
    final result = <String>{};
    await Future.wait(homeworkIds.map((hwId) async {
      try {
        final snap = await _db
            .ref('platform/$nurseryId/homeworkSubmissions/$hwId/$childId')
            .get();
        if (snap.exists && snap.value != null) result.add(hwId);
      } catch (e) {
        AppLogger.error(_tag, 'getSubmittedHomeworkIds($hwId): $e');
      }
    }));
    return result;
  }

  Future<void> submitHomework({
    required String nurseryId,
    required String classroomId,
    required String homeworkId,
    required String childId,
    required SubmittedBy submittedBy,
    required String submittedByUid,
    String? note,
  }) async {
    final model = HomeworkSubmissionModel(
      homeworkId: homeworkId,
      childId: childId,
      nurseryId: nurseryId,
      classroomId: classroomId,
      submittedAt: DateTime.now().millisecondsSinceEpoch,
      submittedBy: submittedBy,
      submittedByUid: submittedByUid,
      note: note,
    );
    await _db
        .ref('platform/$nurseryId/homeworkSubmissions/$homeworkId/$childId')
        .set(model.toJson());
  }

  Future<void> removeHomeworkSubmission({
    required String nurseryId,
    required String homeworkId,
    required String childId,
  }) async {
    await _db
        .ref('platform/$nurseryId/homeworkSubmissions/$homeworkId/$childId')
        .remove();
  }

  static int _weekStartMillis() {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day)
        .millisecondsSinceEpoch;
  }
}

/// A single classroom photo tagged with the moment + activity it belongs to.
class ClassPhoto {
  const ClassPhoto({
    required this.url,
    required this.takenAt,
    required this.activityTitle,
    this.isPrivate = false,
  });

  final String url;
  final int takenAt;
  final String activityTitle;

  /// True when the photo was targeted to specific children (a "private moment")
  /// rather than shared classroom-wide.
  final bool isPrivate;

  DateTime get date => DateTime.fromMillisecondsSinceEpoch(takenAt);

  /// Millis at start-of-day — used to group/filter photos by day.
  int get dayKey {
    final d = date;
    return DateTime(d.year, d.month, d.day).millisecondsSinceEpoch;
  }
}

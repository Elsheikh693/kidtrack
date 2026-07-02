import 'package:firebase_database/firebase_database.dart';
import '../../index/index_main.dart';
import '../../Data/models/academic_topic/academic_topic_model.dart';
import '../../Data/models/teacher_assignment/teacher_assignment_model.dart';
import '../../Data/models/daily_assessment/daily_assessment_model.dart';
import '../../Data/models/topic_progress/topic_progress_model.dart';
import '../../Data/models/classroom/classroom_model.dart';
import '../../Data/models/program/program_model.dart';
import '../../Data/models/subject/subject_model.dart';
import '../../Data/models/child/child_model.dart';

class TeacherAcademicService {
  final _db = FirebaseDatabase.instance;
  final _session = SessionService();

  String get _n => 'platform/${_session.nurseryId}';
  String get _teacherId => _session.userId ?? '';

  // ─── Teacher Assignment ───────────────────────────────────────────────────

  Future<TeacherAssignmentModel?> loadAssignment() async {
    try {
      final snap = await _db.ref('$_n/teacherAssignments/$_teacherId').get();
      if (!snap.exists || snap.value == null) return null;
      return TeacherAssignmentModel.fromJson(
        Map<String, dynamic>.from(snap.value as Map),
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> saveAssignment(TeacherAssignmentModel model) async {
    await _db.ref('$_n/teacherAssignments/$_teacherId').set(model.toJson());
    // Mirror into staff node so TeacherHomeController still works
    await _db.ref('$_n/staff/$_teacherId').update({
      'subjectIds': model.subjectIds,
      'classroomIds': model.classroomIds,
      'setupDone': true,
    });
  }

  Future<bool> isSetupDone() async {
    try {
      final snap = await _db
          .ref('$_n/teacherAssignments/$_teacherId/isSetupDone')
          .get();
      if (!snap.exists) return false;
      final v = snap.value;
      if (v is bool) return v;
      if (v is int) return v == 1;
      return false;
    } catch (_) {
      return false;
    }
  }

  // ─── Load Programs / Subjects / Classrooms for Onboarding ────────────────

  Future<List<ProgramModel>> loadPrograms() async {
    try {
      final snap = await _db.ref('$_n/programs').get();
      if (!snap.exists || snap.value == null) return [];
      final data = snap.value as Map;
      return data.entries
          .where((e) => e.value is Map)
          .map((e) => ProgramModel.fromJson(
                Map<String, dynamic>.from(e.value as Map),
                key: e.key.toString(),
              ))
          .where((p) => p.isActive)
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (_) {
      return [];
    }
  }

  Future<List<SubjectModel>> loadSubjects({List<String>? programIds}) async {
    try {
      final snap = await _db.ref('$_n/subjects').get();
      if (!snap.exists || snap.value == null) return [];
      final data = snap.value as Map;
      return data.entries
          .where((e) => e.value is Map)
          .map((e) => SubjectModel.fromJson(
                Map<String, dynamic>.from(e.value as Map),
                key: e.key.toString(),
              ))
          .where((s) =>
              programIds == null ||
              programIds.isEmpty ||
              programIds.contains(s.programId))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (_) {
      return [];
    }
  }

  Future<List<ClassroomModel>> loadClassrooms() async {
    try {
      final branchId = _session.branchId ?? '';
      final snap = await _db.ref('$_n/classrooms').get();
      if (!snap.exists || snap.value == null) return [];
      final data = snap.value as Map;
      return data.entries
          .where((e) => e.value is Map)
          .map((e) => ClassroomModel.fromJson(
                Map<String, dynamic>.from(e.value as Map),
                key: e.key.toString(),
              ))
          .where((c) =>
              c.isActive &&
              (branchId.isEmpty || c.isAllBranches || c.branchIds.contains(branchId)))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
    } catch (_) {
      return [];
    }
  }

  // ─── Academic Topics ──────────────────────────────────────────────────────

  Future<List<AcademicTopicModel>> loadTopics({
    required String subjectId,
    String? programId,
  }) async {
    try {
      final snap = await _db
          .ref('$_n/academicTopics')
          .orderByChild('subjectId')
          .equalTo(subjectId)
          .get();
      if (!snap.exists || snap.value == null) return [];
      final data = snap.value as Map;
      return data.entries
          .where((e) => e.value is Map)
          .map((e) => AcademicTopicModel.fromJson(
                Map<String, dynamic>.from(e.value as Map),
                key: e.key.toString(),
              ))
          .where((t) =>
              t.isActive &&
              (programId == null || programId.isEmpty || t.programId == programId || t.programId == null))
          .toList()
        ..sort((a, b) => a.order.compareTo(b.order));
    } catch (_) {
      return [];
    }
  }

  Future<void> createTopic(AcademicTopicModel topic) async {
    final ref = _db.ref('$_n/academicTopics').push();
    await ref.set(topic.copyWith(key: ref.key).toJson());
  }

  Future<void> updateTopic(AcademicTopicModel topic) async {
    if (topic.key == null) return;
    await _db.ref('$_n/academicTopics/${topic.key}').update(topic.toJson());
  }

  Future<void> deleteTopic(String topicId) async {
    await _db.ref('$_n/academicTopics/$topicId').remove();
  }

  // ─── Topic Progress ───────────────────────────────────────────────────────

  Future<Map<String, TopicProgressModel>> loadTopicProgress({
    required String classroomId,
    required String subjectId,
  }) async {
    try {
      final snap = await _db
          .ref('$_n/topicProgress')
          .orderByChild('classroomId')
          .equalTo(classroomId)
          .get();
      if (!snap.exists || snap.value == null) return {};
      final data = snap.value as Map;
      final result = <String, TopicProgressModel>{};
      for (final e in data.entries) {
        if (e.value is! Map) continue;
        final m = TopicProgressModel.fromJson(
          Map<String, dynamic>.from(e.value as Map),
          key: e.key.toString(),
        );
        if (m.subjectId == subjectId) {
          result[m.topicId] = m;
        }
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  Future<void> toggleTopicDone({
    required String classroomId,
    required String subjectId,
    required String topicId,
    required bool isDone,
  }) async {
    final key = TopicProgressModel.buildKey(classroomId, topicId);
    final ref = _db.ref('$_n/topicProgress/$key');
    if (isDone) {
      final model = TopicProgressModel(
        key: key,
        nurseryId: _session.nurseryId ?? '',
        classroomId: classroomId,
        teacherId: _teacherId,
        topicId: topicId,
        subjectId: subjectId,
        isDone: true,
        completedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await ref.set(model.toJson());
    } else {
      await ref.update({'isDone': false, 'completedAt': null, 'updatedAt': DateTime.now().millisecondsSinceEpoch});
    }
  }

  // ─── Daily Assessments ────────────────────────────────────────────────────

  Future<Map<String, DailyAssessmentModel>> loadTodayAssessments({
    required String classroomId,
    required String date,
  }) async {
    try {
      final snap = await _db
          .ref('$_n/dailyAssessments')
          .orderByChild('classroomId')
          .equalTo(classroomId)
          .get();
      if (!snap.exists || snap.value == null) return {};
      final data = snap.value as Map;
      final result = <String, DailyAssessmentModel>{};
      for (final e in data.entries) {
        if (e.value is! Map) continue;
        final m = DailyAssessmentModel.fromJson(
          Map<String, dynamic>.from(e.value as Map),
          key: e.key.toString(),
        );
        if (m.date == date) {
          result[m.childId] = m;
        }
      }
      return result;
    } catch (_) {
      return {};
    }
  }

  Future<void> saveDailyAssessment({
    required String classroomId,
    required String childId,
    required String date,
    required DailyRating rating,
    String? comment,
  }) async {
    final key = DailyAssessmentModel.buildKey(date, classroomId, childId);
    final model = DailyAssessmentModel(
      key: key,
      nurseryId: _session.nurseryId ?? '',
      branchId: _session.branchId ?? '',
      classroomId: classroomId,
      teacherId: _teacherId,
      childId: childId,
      date: date,
      rating: rating,
      comment: comment?.isEmpty == true ? null : comment,
    );
    await _db.ref('$_n/dailyAssessments/$key').set(model.toJson());
  }

  Future<void> saveBatchAssessments({
    required String classroomId,
    required String date,
    required Map<String, DailyRating> ratings,
    required Map<String, String?> comments,
  }) async {
    final updates = <String, dynamic>{};
    for (final childId in ratings.keys) {
      final key = DailyAssessmentModel.buildKey(date, classroomId, childId);
      final model = DailyAssessmentModel(
        key: key,
        nurseryId: _session.nurseryId ?? '',
        branchId: _session.branchId ?? '',
        classroomId: classroomId,
        teacherId: _teacherId,
        childId: childId,
        date: date,
        rating: ratings[childId]!,
        comment: comments[childId]?.isEmpty == true ? null : comments[childId],
      );
      updates['$_n/dailyAssessments/$key'] = model.toJson();
    }
    if (updates.isNotEmpty) {
      await _db.ref().update(updates);
    }
  }

  // ─── Load Children for Assessment ─────────────────────────────────────────

  Future<List<ChildModel>> loadClassroomChildren(String classroomId) async {
    try {
      final snap = await _db
          .ref('$_n/children')
          .orderByChild('classroomId')
          .equalTo(classroomId)
          .get();
      if (!snap.exists || snap.value == null) return [];
      final data = snap.value as Map;
      return data.entries
          .where((e) => e.value is Map)
          .map((e) => ChildModel.fromJson(
                Map<String, dynamic>.from(e.value as Map),
                key: e.key.toString(),
              ))
          .where((c) => c.status == 'active')
          .toList()
        ..sort((a, b) => a.fullName.compareTo(b.fullName));
    } catch (_) {
      return [];
    }
  }
}

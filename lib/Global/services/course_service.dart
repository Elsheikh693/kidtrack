import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../Data/models/nursery_course/nursery_course_model.dart';
import '../../Data/models/course_enrollment/course_enrollment_model.dart';
import '../../Data/models/notification/notification_model.dart';
import '../Utils/logger.dart';
import 'session_service.dart';
import 'notification_send_service.dart';

class CourseService {
  final _db = FirebaseDatabase.instance;
  final _storage = FirebaseStorage.instance;
  final _session = SessionService();

  String get _nurseryId => _session.nurseryId ?? '';

  DatabaseReference get _coursesRef => _db.ref('platform/$_nurseryId/courses');
  DatabaseReference _lessonsRef(String courseId) =>
      _db.ref('platform/$_nurseryId/courseLessons/$courseId');
  DatabaseReference _progressRef(String uid) =>
      _db.ref('platform/$_nurseryId/courseProgress/$uid');
  DatabaseReference _enrollRef(String courseId) =>
      _db.ref('platform/$_nurseryId/courseEnrollments/$courseId');
  DatabaseReference _attendanceRef(String courseId) =>
      _db.ref('platform/$_nurseryId/courseAttendance/$courseId');

  // ─── Watch active courses (parent) ────────────────────────────────────────
  Stream<List<NurseryCourse>> watchActiveCourses() {
    return _coursesRef.orderByChild('createdAt').onValue.map(_parseCourses)
        .map((list) => list.where((c) => c.isActive).toList());
  }

  // ─── Watch all courses (owner/manager) ────────────────────────────────────
  Stream<List<NurseryCourse>> watchAllCourses() {
    return _coursesRef.orderByChild('createdAt').onValue.map(_parseCourses);
  }

  List<NurseryCourse> _parseCourses(DatabaseEvent event) {
    final data = event.snapshot.value;
    if (data == null || data is! Map) return [];
    final list = <NurseryCourse>[];
    for (final entry in (data as Map).entries) {
      try {
        final map = Map<String, dynamic>.from(entry.value as Map);
        list.add(NurseryCourse.fromJson(map, id: entry.key.toString()));
      } catch (_) {}
    }
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  // ─── Watch lessons for a course ───────────────────────────────────────────
  Stream<List<CourseLesson>> watchLessons(String courseId) {
    return _lessonsRef(courseId).onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return <CourseLesson>[];
      final list = <CourseLesson>[];
      for (final entry in (data as Map).entries) {
        try {
          final map = Map<String, dynamic>.from(entry.value as Map);
          list.add(CourseLesson.fromJson(map, id: entry.key.toString()));
        } catch (_) {}
      }
      list.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      return list;
    });
  }

  // ─── Fetch lessons once ───────────────────────────────────────────────────
  Future<List<CourseLesson>> getLessons(String courseId) async {
    try {
      final snap = await _lessonsRef(courseId).get();
      if (snap.value == null || snap.value is! Map) return [];
      final list = <CourseLesson>[];
      for (final entry in (snap.value as Map).entries) {
        try {
          final map = Map<String, dynamic>.from(entry.value as Map);
          list.add(CourseLesson.fromJson(map, id: entry.key.toString()));
        } catch (_) {}
      }
      list.sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      return list;
    } catch (_) {
      return [];
    }
  }

  // ─── Create course ────────────────────────────────────────────────────────
  Future<bool> createCourse({
    required String title,
    required String description,
    required double price,
    required CourseCategory category,
    required String ageGroup,
    int sessionCount = 0,
    int? startDate,
    bool isActive = true,
    List<String> branchIds = const [],
    XFile? coverImage,
  }) async {
    try {
      final id = const Uuid().v4();
      String? coverUrl;
      if (coverImage != null) {
        coverUrl = await _uploadCover(id, coverImage);
      }
      final course = NurseryCourse(
        id: id,
        nurseryId: _nurseryId,
        branchId: _session.branchId,
        branchIds: branchIds,
        title: title,
        description: description,
        price: price,
        coverUrl: coverUrl,
        category: category,
        ageGroup: ageGroup,
        sessionCount: sessionCount,
        startDate: startDate,
        isActive: isActive,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _coursesRef.child(id).set(course.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Update course ────────────────────────────────────────────────────────
  Future<bool> updateCourse({
    required NurseryCourse course,
    required String title,
    required String description,
    required double price,
    required CourseCategory category,
    required String ageGroup,
    int? sessionCount,
    int? startDate,
    bool clearStartDate = false,
    bool? isActive,
    List<String>? branchIds,
    XFile? newCoverImage,
    bool removeCover = false,
  }) async {
    try {
      String? coverUrl = course.coverUrl;
      if (removeCover) {
        if (coverUrl != null) await _deleteCoverByUrl(coverUrl);
        coverUrl = null;
      } else if (newCoverImage != null) {
        if (coverUrl != null) await _deleteCoverByUrl(coverUrl);
        coverUrl = await _uploadCover(course.id, newCoverImage);
      }
      final updated = course.copyWith(
        title: title,
        description: description,
        price: price,
        category: category,
        ageGroup: ageGroup,
        sessionCount: sessionCount ?? course.sessionCount,
        startDate: startDate,
        clearStartDate: clearStartDate,
        isActive: isActive ?? course.isActive,
        branchIds: branchIds ?? course.branchIds,
        coverUrl: coverUrl,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _coursesRef.child(course.id).update(updated.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Toggle active ────────────────────────────────────────────────────────
  Future<void> toggleActive(String courseId, bool current) async {
    await _coursesRef.child(courseId).update({'isActive': !current});
  }

  // ─── Delete course ────────────────────────────────────────────────────────
  Future<bool> deleteCourse(NurseryCourse course) async {
    try {
      if (course.coverUrl != null) await _deleteCoverByUrl(course.coverUrl!);
      await _lessonsRef(course.id).remove();
      await _coursesRef.child(course.id).remove();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Create lesson ────────────────────────────────────────────────────────
  Future<bool> createLesson({
    required String courseId,
    required String title,
    required String? description,
    required int durationMinutes,
    required LessonContentType contentType,
    required String? contentUrl,
    required String? textContent,
    required int orderIndex,
  }) async {
    try {
      final id = const Uuid().v4();
      final lesson = CourseLesson(
        id: id,
        courseId: courseId,
        title: title,
        description: description,
        orderIndex: orderIndex,
        durationMinutes: durationMinutes,
        contentType: contentType,
        contentUrl: contentUrl,
        textContent: textContent,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _lessonsRef(courseId).child(id).set(lesson.toJson());
      await _updateCourseCounts(courseId);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Update lesson ────────────────────────────────────────────────────────
  Future<bool> updateLesson({
    required String courseId,
    required CourseLesson lesson,
    required String title,
    required String? description,
    required int durationMinutes,
    required LessonContentType contentType,
    required String? contentUrl,
    required String? textContent,
  }) async {
    try {
      final updated = lesson.copyWith(
        title: title,
        description: description,
        durationMinutes: durationMinutes,
        contentType: contentType,
        contentUrl: contentUrl,
        textContent: textContent,
      );
      await _lessonsRef(courseId).child(lesson.id).update(updated.toJson());
      await _updateCourseCounts(courseId);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Delete lesson ────────────────────────────────────────────────────────
  Future<bool> deleteLesson(String courseId, String lessonId) async {
    try {
      await _lessonsRef(courseId).child(lessonId).remove();
      await _updateCourseCounts(courseId);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Reorder lessons ──────────────────────────────────────────────────────
  Future<void> reorderLessons(String courseId, List<CourseLesson> lessons) async {
    final updates = <String, dynamic>{};
    for (var i = 0; i < lessons.length; i++) {
      updates['${lessons[i].id}/orderIndex'] = i;
    }
    await _lessonsRef(courseId).update(updates);
  }

  // ─── Update course lesson/duration counts ─────────────────────────────────
  Future<void> _updateCourseCounts(String courseId) async {
    try {
      final lessons = await getLessons(courseId);
      final total = lessons.fold<int>(0, (s, l) => s + l.durationMinutes);
      await _coursesRef.child(courseId).update({
        'lessonCount': lessons.length,
        'totalMinutes': total,
      });
    } catch (_) {}
  }

  // ─── Progress (parent) ────────────────────────────────────────────────────
  Stream<Map<String, CourseEnrollment>> watchProgress(String uid) {
    return _progressRef(uid).onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return {};
      final result = <String, CourseEnrollment>{};
      for (final entry in (data as Map).entries) {
        try {
          final courseId = entry.key.toString();
          final map = Map<String, dynamic>.from(entry.value as Map);
          result[courseId] = CourseEnrollment.fromJson(map, courseId: courseId);
        } catch (_) {}
      }
      return result;
    });
  }

  Future<void> markLessonCompleted(String uid, String courseId, String lessonId) async {
    try {
      final snap = await _progressRef(uid).child(courseId).get();
      List<String> ids = [];
      if (snap.value is Map) {
        final m = Map<String, dynamic>.from(snap.value as Map);
        final raw = m['completedLessonIds'];
        if (raw is List) ids = raw.map((e) => e.toString()).toList();
        if (raw is Map) ids = raw.values.map((e) => e.toString()).toList();
      }
      if (!ids.contains(lessonId)) {
        ids.add(lessonId);
        await _progressRef(uid).child(courseId).update({
          'completedLessonIds': ids,
          'savedAt': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } catch (_) {}
  }

  // ─── Enrollment (reception) ───────────────────────────────────────────────

  // All enrollments across every course, keyed courseId → set of enrolled
  // childIds. Used by the parent Courses screen to decide (per active child)
  // which courses the child is actually enrolled in by reception.
  Stream<Map<String, Set<String>>> watchAllEnrollments() {
    return _db.ref('platform/$_nurseryId/courseEnrollments').onValue.map((event) {
      final data = event.snapshot.value;
      final result = <String, Set<String>>{};
      if (data is Map) {
        for (final entry in data.entries) {
          final childIds = <String>{};
          if (entry.value is Map) {
            for (final k in (entry.value as Map).keys) {
              childIds.add(k.toString());
            }
          }
          result[entry.key.toString()] = childIds;
        }
      }
      return result;
    });
  }

  Stream<List<CourseChildEnrollment>> watchEnrollments(String courseId) {
    return _enrollRef(courseId).onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return <CourseChildEnrollment>[];
      final list = <CourseChildEnrollment>[];
      for (final entry in (data as Map).entries) {
        try {
          final map = Map<String, dynamic>.from(entry.value as Map);
          list.add(CourseChildEnrollment.fromJson(
            map,
            courseId: courseId,
            childId: entry.key.toString(),
          ));
        } catch (_) {}
      }
      list.sort((a, b) => a.childName.compareTo(b.childName));
      return list;
    });
  }

  Future<void> enrollChild({
    required String courseId,
    required String childId,
    required String childName,
    String? childImage,
  }) async {
    final enrollment = CourseChildEnrollment(
      courseId: courseId,
      childId: childId,
      childName: childName,
      childImage: childImage,
      enrolledAt: DateTime.now().millisecondsSinceEpoch,
      enrolledBy: _session.userId,
    );
    await _enrollRef(courseId).child(childId).set(enrollment.toJson());
  }

  Future<void> unenrollChild(String courseId, String childId) async {
    await _enrollRef(courseId).child(childId).remove();
    // Clean up any attendance records for this child in this course.
    final snap = await _attendanceRef(courseId).get();
    if (snap.value is Map) {
      final updates = <String, dynamic>{};
      for (final entry in (snap.value as Map).entries) {
        final key = entry.key.toString();
        if (key.endsWith('_$childId')) updates[key] = null;
      }
      if (updates.isNotEmpty) await _attendanceRef(courseId).update(updates);
    }
  }

  // ─── Session attendance (reception) ───────────────────────────────────────
  Stream<List<CourseSessionAttendance>> watchAttendance(String courseId) {
    return _attendanceRef(courseId).onValue.map(_parseAttendance);
  }

  // All attendance across every course, keyed courseId → records. Used by the
  // parent Courses screen to show an at-a-glance track progress on each card.
  Stream<Map<String, List<CourseSessionAttendance>>> watchAllAttendance() {
    return _db.ref('platform/$_nurseryId/courseAttendance').onValue.map((event) {
      final data = event.snapshot.value;
      final result = <String, List<CourseSessionAttendance>>{};
      if (data is Map) {
        for (final entry in data.entries) {
          final list = <CourseSessionAttendance>[];
          if (entry.value is Map) {
            for (final rec in (entry.value as Map).values) {
              if (rec is Map) {
                try {
                  list.add(CourseSessionAttendance.fromJson(
                      Map<String, dynamic>.from(rec)));
                } catch (_) {}
              }
            }
          }
          result[entry.key.toString()] = list;
        }
      }
      return result;
    });
  }

  Future<List<CourseSessionAttendance>> getAttendanceOnce(String courseId) async {
    try {
      final snap = await _attendanceRef(courseId).get();
      if (snap.value == null || snap.value is! Map) return [];
      final list = <CourseSessionAttendance>[];
      for (final entry in (snap.value as Map).entries) {
        try {
          final map = Map<String, dynamic>.from(entry.value as Map);
          list.add(CourseSessionAttendance.fromJson(map));
        } catch (_) {}
      }
      return list;
    } catch (_) {
      return [];
    }
  }

  List<CourseSessionAttendance> _parseAttendance(DatabaseEvent event) {
    final data = event.snapshot.value;
    if (data == null || data is! Map) return [];
    final list = <CourseSessionAttendance>[];
    for (final entry in (data as Map).entries) {
      try {
        final map = Map<String, dynamic>.from(entry.value as Map);
        list.add(CourseSessionAttendance.fromJson(map));
      } catch (_) {}
    }
    return list;
  }

  // Mark a child present (check-in) for a session. Overwrites the record.
  Future<void> markSessionCheckIn({
    required String courseId,
    required int sessionIndex,
    required String childId,
  }) async {
    final record = CourseSessionAttendance(
      courseId: courseId,
      sessionIndex: sessionIndex,
      childId: childId,
      status: CourseAttendanceStatus.present,
      checkedInAt: DateTime.now().millisecondsSinceEpoch,
      markedBy: _session.userId,
    );
    await _attendanceRef(courseId).child(record.storageKey).set(record.toJson());
  }

  // Mark a child absent for a session. Overwrites any existing record.
  Future<void> markSessionAbsent({
    required String courseId,
    required int sessionIndex,
    required String childId,
  }) async {
    final record = CourseSessionAttendance(
      courseId: courseId,
      sessionIndex: sessionIndex,
      childId: childId,
      status: CourseAttendanceStatus.absent,
      markedBy: _session.userId,
    );
    await _attendanceRef(courseId).child(record.storageKey).set(record.toJson());
  }

  // Mark check-out time for a session the child already attended.
  Future<void> markSessionCheckOut({
    required String courseId,
    required int sessionIndex,
    required String childId,
  }) async {
    await _attendanceRef(courseId).child('${sessionIndex}_$childId').update({
      'checkedOutAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Undo attendance for a session (removes the record entirely).
  Future<void> clearSessionAttendance({
    required String courseId,
    required int sessionIndex,
    required String childId,
  }) async {
    await _attendanceRef(courseId).child('${sessionIndex}_$childId').remove();
  }

  // Notify the child's parent that their child attended a course session,
  // including the content of that session (the lesson mapped to it). Called
  // by reception on a fresh check-in. Best-effort: silently no-ops if the
  // child has no linked parent.
  Future<void> notifySessionAttendance({
    required NurseryCourse course,
    required int sessionIndex,
    required String childId,
    required String childName,
  }) async {
    try {
      final parentSnap = await _db
          .ref('platform/$_nurseryId/children/$childId/parentId')
          .get();
      final parentId = parentSnap.value?.toString();
      if (parentId == null || parentId.isEmpty) return;

      // Resolve the session content: the lesson whose order maps to this
      // session (session N == orderIndex N-1).
      final lessons = await getLessons(course.id);
      CourseLesson? lesson;
      for (final l in lessons) {
        if (l.orderIndex + 1 == sessionIndex) {
          lesson = l;
          break;
        }
      }

      final body = StringBuffer(
        'حضر $childName الحصة $sessionIndex من كورس «${course.title}»',
      );
      if (lesson != null) {
        body.write('\nمحتوى الحصة: ${lesson.title}');
        final detail = (lesson.textContent?.trim().isNotEmpty ?? false)
            ? lesson.textContent!.trim()
            : (lesson.description?.trim() ?? '');
        if (detail.isNotEmpty) body.write('\n$detail');
      }

      await NotificationSendService().sendToUser(
        parentId,
        NotificationModel(
          userId: parentId,
          nurseryId: _nurseryId,
          title: 'حضور الكورس',
          body: body.toString(),
          type: 'course_attendance',
          entityId: course.id,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      AppLogger.error('COURSE_NOTIF', 'notifySessionAttendance: $e');
    }
  }

  // Per-child attendance in a course (parent track). Sorted by session index.
  Stream<List<CourseSessionAttendance>> watchChildAttendance(
    String courseId,
    String childId,
  ) {
    return watchAttendance(courseId).map(
      (list) => list.where((a) => a.childId == childId).toList()
        ..sort((a, b) => a.sessionIndex.compareTo(b.sessionIndex)),
    );
  }

  // ─── Image helpers ────────────────────────────────────────────────────────
  Future<String?> _uploadCover(String courseId, XFile xfile) async {
    try {
      final compressed = await _compress(xfile.path);
      final file = compressed ?? File(xfile.path);
      final ref = _storage.ref('nurseries/$_nurseryId/courses/$courseId/cover.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  Future<File?> _compress(String path) async {
    try {
      final dir = await getTemporaryDirectory();
      final target = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_c.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        path, target, quality: 80, minWidth: 1080, minHeight: 720,
      );
      return result != null ? File(result.path) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _deleteCoverByUrl(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {}
  }
}

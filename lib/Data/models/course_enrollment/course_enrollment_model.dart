// Reception-driven course enrollment + per-session attendance.
//
// Enrollment  → platform/{nurseryId}/courseEnrollments/{courseId}/{childId}
// Attendance  → platform/{nurseryId}/courseAttendance/{courseId}/{sessionIndex}_{childId}
//
// Sessions are order-only (1..N). A child's course "track" is derived from how
// many sessions they attended (present) out of the course's totalSessions.

// ─── Enrollment ───────────────────────────────────────────────────────────────

class CourseChildEnrollment {
  final String courseId;
  final String childId;
  final String childName;
  final String? childImage;
  final int enrolledAt;
  final String? enrolledBy;

  const CourseChildEnrollment({
    required this.courseId,
    required this.childId,
    required this.childName,
    this.childImage,
    required this.enrolledAt,
    this.enrolledBy,
  });

  factory CourseChildEnrollment.fromJson(
    Map<String, dynamic> json, {
    required String courseId,
    required String childId,
  }) {
    return CourseChildEnrollment(
      courseId: courseId,
      childId: childId,
      childName: json['childName']?.toString() ?? '',
      childImage: json['childImage']?.toString(),
      enrolledAt: _parseInt(json['enrolledAt']) ?? 0,
      enrolledBy: json['enrolledBy']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'childName': childName,
      'enrolledAt': enrolledAt,
    };
    if (childImage != null) m['childImage'] = childImage;
    if (enrolledBy != null) m['enrolledBy'] = enrolledBy;
    return m;
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

// ─── Session attendance ───────────────────────────────────────────────────────

enum CourseAttendanceStatus { present, absent }

extension CourseAttendanceStatusX on CourseAttendanceStatus {
  String get key => name;

  static CourseAttendanceStatus fromKey(String? v) =>
      CourseAttendanceStatus.values.firstWhere(
        (e) => e.name == v,
        orElse: () => CourseAttendanceStatus.absent,
      );
}

class CourseSessionAttendance {
  final String courseId;
  final int sessionIndex; // 1-based session number
  final String childId;
  final CourseAttendanceStatus status;
  final int? checkedInAt;
  final int? checkedOutAt;
  final String? markedBy;

  const CourseSessionAttendance({
    required this.courseId,
    required this.sessionIndex,
    required this.childId,
    this.status = CourseAttendanceStatus.present,
    this.checkedInAt,
    this.checkedOutAt,
    this.markedBy,
  });

  // Deterministic key so re-marking overwrites the same record.
  String get storageKey => '${sessionIndex}_$childId';

  bool get isPresent => status == CourseAttendanceStatus.present;
  bool get hasCheckedOut => checkedOutAt != null;

  factory CourseSessionAttendance.fromJson(Map<String, dynamic> json) {
    return CourseSessionAttendance(
      courseId: json['courseId']?.toString() ?? '',
      sessionIndex: _parseInt(json['sessionIndex']) ?? 0,
      childId: json['childId']?.toString() ?? '',
      status: CourseAttendanceStatusX.fromKey(json['status']?.toString()),
      checkedInAt: _parseInt(json['checkedInAt']),
      checkedOutAt: _parseInt(json['checkedOutAt']),
      markedBy: json['markedBy']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'courseId': courseId,
      'sessionIndex': sessionIndex,
      'childId': childId,
      'status': status.key,
    };
    if (checkedInAt != null) m['checkedInAt'] = checkedInAt;
    if (checkedOutAt != null) m['checkedOutAt'] = checkedOutAt;
    if (markedBy != null) m['markedBy'] = markedBy;
    return m;
  }

  CourseSessionAttendance copyWith({
    CourseAttendanceStatus? status,
    int? checkedInAt,
    int? checkedOutAt,
    String? markedBy,
  }) =>
      CourseSessionAttendance(
        courseId: courseId,
        sessionIndex: sessionIndex,
        childId: childId,
        status: status ?? this.status,
        checkedInAt: checkedInAt ?? this.checkedInAt,
        checkedOutAt: checkedOutAt ?? this.checkedOutAt,
        markedBy: markedBy ?? this.markedBy,
      );

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

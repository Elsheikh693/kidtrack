class AssignmentEntry {
  final String classroomId;
  final String subjectId;

  const AssignmentEntry({
    required this.classroomId,
    required this.subjectId,
  });

  factory AssignmentEntry.fromJson(Map<String, dynamic> json) {
    return AssignmentEntry(
      classroomId: json['classroomId']?.toString() ?? '',
      subjectId: json['subjectId']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'classroomId': classroomId,
        'subjectId': subjectId,
      };

  @override
  bool operator ==(Object other) =>
      other is AssignmentEntry &&
      other.classroomId == classroomId &&
      other.subjectId == subjectId;

  @override
  int get hashCode => classroomId.hashCode ^ subjectId.hashCode;
}

class TeacherAssignmentModel {
  final String teacherId;
  final String nurseryId;
  final String branchId;
  final bool isSetupDone;
  final List<AssignmentEntry> assignments;
  final int? updatedAt;

  const TeacherAssignmentModel({
    required this.teacherId,
    required this.nurseryId,
    required this.branchId,
    this.isSetupDone = false,
    this.assignments = const [],
    this.updatedAt,
  });

  List<String> get classroomIds =>
      assignments.map((e) => e.classroomId).toSet().toList();

  List<String> get subjectIds =>
      assignments.map((e) => e.subjectId).toSet().toList();

  List<String> subjectsForClassroom(String classroomId) => assignments
      .where((e) => e.classroomId == classroomId)
      .map((e) => e.subjectId)
      .toList();

  List<String> classroomsForSubject(String subjectId) => assignments
      .where((e) => e.subjectId == subjectId)
      .map((e) => e.classroomId)
      .toList();

  bool teaches(String classroomId, String subjectId) => assignments
      .any((e) => e.classroomId == classroomId && e.subjectId == subjectId);

  factory TeacherAssignmentModel.fromJson(Map<String, dynamic> json) {
    List<AssignmentEntry> toEntries(dynamic v) {
      if (v is List) {
        return v
            .whereType<Map>()
            .map((e) => AssignmentEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      if (v is Map) {
        return v.values
            .whereType<Map>()
            .map((e) => AssignmentEntry.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      return [];
    }

    return TeacherAssignmentModel(
      teacherId: json['teacherId']?.toString() ?? '',
      nurseryId: json['nurseryId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      isSetupDone: _parseBool(json['isSetupDone']),
      assignments: toEntries(json['assignments']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'teacherId': teacherId,
        'nurseryId': nurseryId,
        'branchId': branchId,
        'isSetupDone': isSetupDone,
        'assignments': assignments.map((e) => e.toJson()).toList(),
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      };

  TeacherAssignmentModel copyWith({
    String? teacherId,
    String? nurseryId,
    String? branchId,
    bool? isSetupDone,
    List<AssignmentEntry>? assignments,
    int? updatedAt,
  }) =>
      TeacherAssignmentModel(
        teacherId: teacherId ?? this.teacherId,
        nurseryId: nurseryId ?? this.nurseryId,
        branchId: branchId ?? this.branchId,
        isSetupDone: isSetupDone ?? this.isSetupDone,
        assignments: assignments ?? this.assignments,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) return v == '1' || v.toLowerCase() == 'true';
    return false;
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

import '../core/branch_scoped.dart';

/// Firebase path: platform/{nurseryId}/examResults/{key}
///
/// One child's outcome on a written exam. The key is deterministic
/// (`er_{examId}_{childId}`) so a teacher re-grading simply re-writes it — one
/// result per child per exam. Display fields (subjectName / examTitle /
/// examDate) are denormalised from the parent [ExamModel] so the guardian's
/// exam list + branded share card render without extra lookups.
///
/// The grade is a verbal [ExamGrade] persisted by its key; [paperUrl] is the
/// photo of the child's actual paper (same upload pipeline as activity photos).
class ExamResultModel implements BranchScoped {
  final String? key;
  final String nurseryId;
  final String branchId;

  final String examId;
  final String childId;
  final String childName;
  final String classroomId;

  // Denormalised from the exam for lookup-free guardian rendering.
  final String subjectName;
  final String examTitle;
  final int examDate;

  /// Verbal grade — an [ExamGrade.key] ('excellent' … 'needsImprovement').
  final String grade;

  /// Photo of the child's paper (nullable while grading in progress).
  final String? paperUrl;

  /// Optional teacher comment shown to the guardian.
  final String note;

  final String gradedBy;
  final String gradedByName;

  final int? createdAt;
  final int? updatedAt;

  const ExamResultModel({
    this.key,
    required this.nurseryId,
    required this.branchId,
    required this.examId,
    required this.childId,
    required this.childName,
    required this.classroomId,
    required this.subjectName,
    required this.examTitle,
    required this.examDate,
    required this.grade,
    this.paperUrl,
    required this.note,
    required this.gradedBy,
    required this.gradedByName,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<String> get scopeBranches => branchId.isEmpty ? const [] : [branchId];

  /// Deterministic key giving one editable result per child per exam.
  static String buildKey(String examId, String childId) =>
      'er_${examId}_$childId';

  factory ExamResultModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return ExamResultModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      examId: json['examId']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      childName: json['childName']?.toString() ?? '',
      classroomId: json['classroomId']?.toString() ?? '',
      subjectName: json['subjectName']?.toString() ?? '',
      examTitle: json['examTitle']?.toString() ?? '',
      examDate: _parseInt(json['examDate']) ?? 0,
      grade: json['grade']?.toString() ?? '',
      paperUrl: json['paperUrl']?.toString(),
      note: json['note']?.toString() ?? '',
      gradedBy: json['gradedBy']?.toString() ?? '',
      gradedByName: json['gradedByName']?.toString() ?? '',
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('key', key);
    data['nurseryId'] = nurseryId;
    data['branchId'] = branchId;
    data['examId'] = examId;
    data['childId'] = childId;
    data['childName'] = childName;
    data['classroomId'] = classroomId;
    data['subjectName'] = subjectName;
    data['examTitle'] = examTitle;
    data['examDate'] = examDate;
    data['grade'] = grade;
    put('paperUrl', paperUrl);
    data['note'] = note;
    data['gradedBy'] = gradedBy;
    data['gradedByName'] = gradedByName;
    put('createdAt', createdAt ?? _now());
    data['updatedAt'] = _now();
    return data;
  }

  ExamResultModel copyWith({
    String? grade,
    String? paperUrl,
    String? note,
    int? updatedAt,
  }) {
    return ExamResultModel(
      key: key,
      nurseryId: nurseryId,
      branchId: branchId,
      examId: examId,
      childId: childId,
      childName: childName,
      classroomId: classroomId,
      subjectName: subjectName,
      examTitle: examTitle,
      examDate: examDate,
      grade: grade ?? this.grade,
      paperUrl: paperUrl ?? this.paperUrl,
      note: note ?? this.note,
      gradedBy: gradedBy,
      gradedByName: gradedByName,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _now() => DateTime.now().millisecondsSinceEpoch;

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }
}

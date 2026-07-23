import '../core/branch_scoped.dart';

/// Firebase path: platform/{nurseryId}/exams/{key}
///
/// A written (paper) exam a teacher/manager sets for ONE classroom on a given
/// day (e.g. "امتحان الحروف" in Arabic). It is the class-level container; each
/// child's own outcome lives in a separate [ExamResultModel] keyed by this
/// exam. `BranchScoped` so branch-bound staff only read their own branch's
/// exams (central filter in [BaseService.getData]).
class ExamModel implements BranchScoped {
  final String? key;
  final String nurseryId;
  final String branchId;

  final String classroomId;
  final String classroomName;

  /// The subject/material the exam covers (e.g. "لغة عربية").
  final String subjectName;

  /// Optional friendly name for the exam (e.g. "امتحان الحروف").
  final String title;

  /// Start-of-day ms of the exam day — the day the papers were sat.
  final int examDate;

  /// Author.
  final String createdBy;
  final String createdByName;

  /// 'teacher' | 'manager' — who set it (both are allowed to create).
  final String createdByRole;

  final int? createdAt;
  final int? updatedAt;

  const ExamModel({
    this.key,
    required this.nurseryId,
    required this.branchId,
    required this.classroomId,
    required this.classroomName,
    required this.subjectName,
    required this.title,
    required this.examDate,
    required this.createdBy,
    required this.createdByName,
    required this.createdByRole,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<String> get scopeBranches => branchId.isEmpty ? const [] : [branchId];

  factory ExamModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return ExamModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      classroomId: json['classroomId']?.toString() ?? '',
      classroomName: json['classroomName']?.toString() ?? '',
      subjectName: json['subjectName']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      examDate: _parseInt(json['examDate']) ?? 0,
      createdBy: json['createdBy']?.toString() ?? '',
      createdByName: json['createdByName']?.toString() ?? '',
      createdByRole: json['createdByRole']?.toString() ?? '',
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
    data['classroomId'] = classroomId;
    data['classroomName'] = classroomName;
    data['subjectName'] = subjectName;
    data['title'] = title;
    data['examDate'] = examDate;
    data['createdBy'] = createdBy;
    data['createdByName'] = createdByName;
    data['createdByRole'] = createdByRole;
    put('createdAt', createdAt ?? _now());
    data['updatedAt'] = _now();
    return data;
  }

  ExamModel copyWith({
    String? subjectName,
    String? title,
    int? examDate,
    int? updatedAt,
  }) {
    return ExamModel(
      key: key,
      nurseryId: nurseryId,
      branchId: branchId,
      classroomId: classroomId,
      classroomName: classroomName,
      subjectName: subjectName ?? this.subjectName,
      title: title ?? this.title,
      examDate: examDate ?? this.examDate,
      createdBy: createdBy,
      createdByName: createdByName,
      createdByRole: createdByRole,
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

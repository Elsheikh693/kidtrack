class HomeworkModel {
  final String? key;
  final String nurseryId;
  final String classroomId;
  // Branch that owns this homework — stamped from the teacher's branch so a
  // shared (isAllBranches) classroom's homework doesn't leak across branches.
  final String? branchId;
  final String? subjectId;
  final String? subjectName;
  final String? activityId;
  final String? sessionId;
  final String title;
  final String? description;
  final int? dueDate;
  final String createdBy;
  final int? createdAt;

  const HomeworkModel({
    this.key,
    required this.nurseryId,
    required this.classroomId,
    this.branchId,
    this.subjectId,
    this.subjectName,
    this.activityId,
    this.sessionId,
    required this.title,
    this.description,
    this.dueDate,
    required this.createdBy,
    this.createdAt,
  });

  factory HomeworkModel.fromJson(Map<dynamic, dynamic> json, {String? key}) {
    return HomeworkModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      classroomId: json['classroomId']?.toString() ?? '',
      branchId: json['branchId']?.toString(),
      subjectId: json['subjectId']?.toString(),
      subjectName: json['subjectName']?.toString(),
      activityId: json['activityId']?.toString(),
      sessionId: json['sessionId']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      dueDate: _parseInt(json['dueDate']),
      createdBy: json['createdBy']?.toString() ?? '',
      createdAt: _parseInt(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final d = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v != null) d[k] = v;
    }

    put('key', key);
    d['nurseryId'] = nurseryId;
    d['classroomId'] = classroomId;
    put('branchId', branchId);
    put('subjectId', subjectId);
    put('subjectName', subjectName);
    put('activityId', activityId);
    put('sessionId', sessionId);
    d['title'] = title;
    put('description', description);
    put('dueDate', dueDate);
    d['createdBy'] = createdBy;
    d['createdAt'] = createdAt ?? _now();
    return d;
  }

  HomeworkModel copyWith({
    String? key,
    String? nurseryId,
    String? classroomId,
    String? branchId,
    String? subjectId,
    String? subjectName,
    String? activityId,
    String? sessionId,
    String? title,
    String? description,
    int? dueDate,
    String? createdBy,
    int? createdAt,
  }) =>
      HomeworkModel(
        key: key ?? this.key,
        nurseryId: nurseryId ?? this.nurseryId,
        classroomId: classroomId ?? this.classroomId,
        branchId: branchId ?? this.branchId,
        subjectId: subjectId ?? this.subjectId,
        subjectName: subjectName ?? this.subjectName,
        activityId: activityId ?? this.activityId,
        sessionId: sessionId ?? this.sessionId,
        title: title ?? this.title,
        description: description ?? this.description,
        dueDate: dueDate ?? this.dueDate,
        createdBy: createdBy ?? this.createdBy,
        createdAt: createdAt ?? this.createdAt,
      );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

class AssessmentModel {
  final String? key;
  final String nurseryId;
  final String childId;
  final String? classroomId;
  final String assessedBy;
  final String? subjectId;
  final String title;
  final String? description;
  final String level; // excellent, good, average, needs_improvement
  final int date;
  final int? createdAt;
  final int? updatedAt;

  const AssessmentModel({
    this.key,
    required this.nurseryId,
    required this.childId,
    this.classroomId,
    required this.assessedBy,
    this.subjectId,
    required this.title,
    this.description,
    this.level = 'good',
    required this.date,
    this.createdAt,
    this.updatedAt,
  });

  factory AssessmentModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return AssessmentModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      classroomId: json['classroomId']?.toString(),
      assessedBy: json['assessedBy']?.toString() ?? '',
      subjectId: json['subjectId']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      level: json['level']?.toString() ?? 'good',
      date: _parseInt(json['date']) ?? _now(),
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    put('nurseryId', nurseryId);
    put('childId', childId);
    put('classroomId', classroomId);
    put('assessedBy', assessedBy);
    put('subjectId', subjectId);
    data['title'] = title;
    put('description', description);
    data['level'] = level;
    data['date'] = date;
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  AssessmentModel copyWith({
    String? key, String? nurseryId, String? childId, String? classroomId,
    String? assessedBy, String? subjectId, String? title, String? description,
    String? level, int? date, int? createdAt, int? updatedAt,
  }) => AssessmentModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    childId: childId ?? this.childId, classroomId: classroomId ?? this.classroomId,
    assessedBy: assessedBy ?? this.assessedBy, subjectId: subjectId ?? this.subjectId,
    title: title ?? this.title, description: description ?? this.description,
    level: level ?? this.level, date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

class LessonPlanModel {
  final String? key;
  final String nurseryId;
  final String classroomId;
  final String? subjectId;
  final String createdBy;
  final String title;
  final String? description;
  final String? objectives;
  final String? materials;
  final int weekStart;
  final int? createdAt;
  final int? updatedAt;

  const LessonPlanModel({
    this.key,
    required this.nurseryId,
    required this.classroomId,
    this.subjectId,
    required this.createdBy,
    required this.title,
    this.description,
    this.objectives,
    this.materials,
    required this.weekStart,
    this.createdAt,
    this.updatedAt,
  });

  factory LessonPlanModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return LessonPlanModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      classroomId: json['classroomId']?.toString() ?? '',
      subjectId: json['subjectId']?.toString(),
      createdBy: json['createdBy']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      objectives: json['objectives']?.toString(),
      materials: json['materials']?.toString(),
      weekStart: _parseInt(json['weekStart']) ?? _now(),
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    put('nurseryId', nurseryId);
    put('classroomId', classroomId);
    put('subjectId', subjectId);
    put('createdBy', createdBy);
    data['title'] = title;
    put('description', description);
    put('objectives', objectives);
    put('materials', materials);
    data['weekStart'] = weekStart;
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  LessonPlanModel copyWith({
    String? key, String? nurseryId, String? classroomId, String? subjectId,
    String? createdBy, String? title, String? description, String? objectives,
    String? materials, int? weekStart, int? createdAt, int? updatedAt,
  }) => LessonPlanModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    classroomId: classroomId ?? this.classroomId, subjectId: subjectId ?? this.subjectId,
    createdBy: createdBy ?? this.createdBy, title: title ?? this.title,
    description: description ?? this.description, objectives: objectives ?? this.objectives,
    materials: materials ?? this.materials, weekStart: weekStart ?? this.weekStart,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

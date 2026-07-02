class NoteModel {
  final String? key;
  final String nurseryId;
  final String? childId;
  final String? classroomId;
  final String createdBy;
  final String content;
  final String type; // internal, parent_note
  final String category; // positive | needs_follow | important | info
  final bool isVisibleToGuardian;
  final int? createdAt;
  final int? updatedAt;

  const NoteModel({
    this.key,
    required this.nurseryId,
    this.childId,
    this.classroomId,
    required this.createdBy,
    required this.content,
    this.type = 'internal',
    this.category = 'info',
    this.isVisibleToGuardian = false,
    this.createdAt,
    this.updatedAt,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return NoteModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      childId: json['childId']?.toString(),
      classroomId: json['classroomId']?.toString(),
      createdBy: json['createdBy']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? 'internal',
      category: json['category']?.toString() ?? 'info',
      isVisibleToGuardian: _parseBool(json['isVisibleToGuardian']),
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
    put('createdBy', createdBy);
    data['content'] = content;
    data['type'] = type;
    data['category'] = category;
    data['isVisibleToGuardian'] = isVisibleToGuardian;
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  NoteModel copyWith({
    String? key, String? nurseryId, String? childId, String? classroomId,
    String? createdBy, String? content, String? type, String? category,
    bool? isVisibleToGuardian, int? createdAt, int? updatedAt,
  }) => NoteModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    childId: childId ?? this.childId, classroomId: classroomId ?? this.classroomId,
    createdBy: createdBy ?? this.createdBy, content: content ?? this.content,
    type: type ?? this.type, category: category ?? this.category,
    isVisibleToGuardian: isVisibleToGuardian ?? this.isVisibleToGuardian,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
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

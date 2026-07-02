class AcademicTopicModel {
  final String? key;
  final String nurseryId;
  final String subjectId;
  final String? programId;
  final String title;
  final String? description;
  final int order;
  final bool isActive;
  final int? createdAt;
  final int? updatedAt;

  const AcademicTopicModel({
    this.key,
    required this.nurseryId,
    required this.subjectId,
    this.programId,
    required this.title,
    this.description,
    this.order = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory AcademicTopicModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return AcademicTopicModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      subjectId: json['subjectId']?.toString() ?? '',
      programId: json['programId']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      order: _parseInt(json['order']) ?? 0,
      isActive: _parseBool(json['isActive']),
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    put('nurseryId', nurseryId);
    put('subjectId', subjectId);
    put('programId', programId);
    data['title'] = title;
    put('description', description);
    data['order'] = order;
    data['isActive'] = isActive;
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  AcademicTopicModel copyWith({
    String? key, String? nurseryId, String? subjectId, String? programId,
    String? title, String? description, int? order, bool? isActive,
    int? createdAt, int? updatedAt,
  }) =>
      AcademicTopicModel(
        key: key ?? this.key,
        nurseryId: nurseryId ?? this.nurseryId,
        subjectId: subjectId ?? this.subjectId,
        programId: programId ?? this.programId,
        title: title ?? this.title,
        description: description ?? this.description,
        order: order ?? this.order,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) return v == '1' || v.toLowerCase() == 'true';
    return true;
  }
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

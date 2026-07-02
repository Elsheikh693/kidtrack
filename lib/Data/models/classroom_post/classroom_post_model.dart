class ClassroomPostModel {
  final String? key;
  final String nurseryId;
  final String classroomId;
  final String postedBy;
  final String content;
  final List<String> images;
  final String type; // activity, announcement, photo
  final int? createdAt;
  final int? updatedAt;

  const ClassroomPostModel({
    this.key,
    required this.nurseryId,
    required this.classroomId,
    required this.postedBy,
    required this.content,
    this.images = const [],
    this.type = 'activity',
    this.createdAt,
    this.updatedAt,
  });

  factory ClassroomPostModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return ClassroomPostModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      classroomId: json['classroomId']?.toString() ?? '',
      postedBy: json['postedBy']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      images: _parseList(json['images']),
      type: json['type']?.toString() ?? 'activity',
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
    put('postedBy', postedBy);
    data['content'] = content;
    if (images.isNotEmpty) data['images'] = images;
    data['type'] = type;
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  ClassroomPostModel copyWith({
    String? key, String? nurseryId, String? classroomId, String? postedBy,
    String? content, List<String>? images, String? type,
    int? createdAt, int? updatedAt,
  }) => ClassroomPostModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    classroomId: classroomId ?? this.classroomId, postedBy: postedBy ?? this.postedBy,
    content: content ?? this.content, images: images ?? this.images,
    type: type ?? this.type,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
  static List<String> _parseList(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }
}

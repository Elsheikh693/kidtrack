class ChildReportModel {
  final String? key;
  final String nurseryId;
  final String childId;
  final String? classroomId;
  final String reportedBy;
  final String type; // daily, weekly, monthly, custom
  final String? title;
  final String content;
  final List<String> images;
  final int date;
  final int? createdAt;
  final int? updatedAt;

  const ChildReportModel({
    this.key,
    required this.nurseryId,
    required this.childId,
    this.classroomId,
    required this.reportedBy,
    this.type = 'daily',
    this.title,
    required this.content,
    this.images = const [],
    required this.date,
    this.createdAt,
    this.updatedAt,
  });

  factory ChildReportModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return ChildReportModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      classroomId: json['classroomId']?.toString(),
      reportedBy: json['reportedBy']?.toString() ?? '',
      type: json['type']?.toString() ?? 'daily',
      title: json['title']?.toString(),
      content: json['content']?.toString() ?? '',
      images: _parseList(json['images']),
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
    put('reportedBy', reportedBy);
    data['type'] = type;
    put('title', title);
    data['content'] = content;
    if (images.isNotEmpty) data['images'] = images;
    data['date'] = date;
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  ChildReportModel copyWith({
    String? key, String? nurseryId, String? childId, String? classroomId,
    String? reportedBy, String? type, String? title, String? content,
    List<String>? images, int? date, int? createdAt, int? updatedAt,
  }) => ChildReportModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    childId: childId ?? this.childId, classroomId: classroomId ?? this.classroomId,
    reportedBy: reportedBy ?? this.reportedBy, type: type ?? this.type,
    title: title ?? this.title, content: content ?? this.content,
    images: images ?? this.images, date: date ?? this.date,
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

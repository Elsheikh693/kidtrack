/// Key pattern: {classroomId}_{topicId}
/// One progress entry per classroom per topic.
class TopicProgressModel {
  final String? key;
  final String nurseryId;
  final String classroomId;
  final String teacherId;
  final String topicId;
  final String subjectId;
  final bool isDone;
  final String? note;
  final int? completedAt;
  final int? createdAt;
  final int? updatedAt;

  const TopicProgressModel({
    this.key,
    required this.nurseryId,
    required this.classroomId,
    required this.teacherId,
    required this.topicId,
    required this.subjectId,
    this.isDone = false,
    this.note,
    this.completedAt,
    this.createdAt,
    this.updatedAt,
  });

  static String buildKey(String classroomId, String topicId) =>
      '${classroomId}_$topicId';

  factory TopicProgressModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return TopicProgressModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      classroomId: json['classroomId']?.toString() ?? '',
      teacherId: json['teacherId']?.toString() ?? '',
      topicId: json['topicId']?.toString() ?? '',
      subjectId: json['subjectId']?.toString() ?? '',
      isDone: _parseBool(json['isDone']),
      note: json['note']?.toString(),
      completedAt: _parseInt(json['completedAt']),
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    data['nurseryId'] = nurseryId;
    data['classroomId'] = classroomId;
    data['teacherId'] = teacherId;
    data['topicId'] = topicId;
    data['subjectId'] = subjectId;
    data['isDone'] = isDone;
    put('note', note);
    put('completedAt', completedAt);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  TopicProgressModel copyWith({
    String? key, String? nurseryId, String? classroomId, String? teacherId,
    String? topicId, String? subjectId, bool? isDone, String? note,
    int? completedAt, int? createdAt, int? updatedAt,
  }) =>
      TopicProgressModel(
        key: key ?? this.key,
        nurseryId: nurseryId ?? this.nurseryId,
        classroomId: classroomId ?? this.classroomId,
        teacherId: teacherId ?? this.teacherId,
        topicId: topicId ?? this.topicId,
        subjectId: subjectId ?? this.subjectId,
        isDone: isDone ?? this.isDone,
        note: note ?? this.note,
        completedAt: completedAt ?? this.completedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
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

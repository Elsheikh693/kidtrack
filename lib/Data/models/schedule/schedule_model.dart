class ScheduleModel {
  final String? key;
  final String nurseryId;
  final String classroomId;
  final String day; // monday, tuesday, wednesday, thursday, friday
  final String startTime; // "08:00"
  final String endTime;   // "09:00"
  final String activityType; // lesson, break, outdoor, lunch, nap, other
  final String? subjectId;
  // Teacher the manager assigned to this slot. Null for legacy slots (before the
  // manager-owned timetable) — detection then falls back to the classroom teacher.
  final String? teacherId;
  // Optional lesson title the manager sets in advance ("حرف الكاف"). When empty,
  // the teacher types it at the moment she presses "start".
  final String? topic;
  final String? note;
  final int? createdAt;
  final int? updatedAt;

  const ScheduleModel({
    this.key,
    required this.nurseryId,
    required this.classroomId,
    required this.day,
    required this.startTime,
    required this.endTime,
    this.activityType = 'lesson',
    this.subjectId,
    this.teacherId,
    this.topic,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return ScheduleModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      classroomId: json['classroomId']?.toString() ?? '',
      day: json['day']?.toString() ?? 'monday',
      startTime: json['startTime']?.toString() ?? '08:00',
      endTime: json['endTime']?.toString() ?? '09:00',
      activityType: json['activityType']?.toString() ?? 'lesson',
      subjectId: json['subjectId']?.toString(),
      teacherId: json['teacherId']?.toString(),
      topic: json['topic']?.toString(),
      note: json['note']?.toString(),
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
    data['day'] = day;
    data['startTime'] = startTime;
    data['endTime'] = endTime;
    data['activityType'] = activityType;
    put('subjectId', subjectId);
    put('teacherId', teacherId);
    put('topic', topic);
    put('note', note);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  ScheduleModel copyWith({
    String? key, String? nurseryId, String? classroomId, String? day,
    String? startTime, String? endTime, String? activityType,
    String? subjectId, String? teacherId, String? topic, String? note,
    int? createdAt, int? updatedAt,
  }) => ScheduleModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    classroomId: classroomId ?? this.classroomId, day: day ?? this.day,
    startTime: startTime ?? this.startTime, endTime: endTime ?? this.endTime,
    activityType: activityType ?? this.activityType,
    subjectId: subjectId ?? this.subjectId, teacherId: teacherId ?? this.teacherId,
    topic: topic ?? this.topic, note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

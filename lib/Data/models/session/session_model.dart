class SessionModel {
  final String? key;
  final String nurseryId;
  final String classroomId;
  final String subjectId;
  final String? subjectName;
  final String teacherId;
  final int date; // start-of-day ms — for grouping by date
  final String? activityId;
  final String status; // 'active' | 'completed'
  final int startedAt;
  final int? endedAt;
  final String? homeworkId;

  const SessionModel({
    this.key,
    required this.nurseryId,
    required this.classroomId,
    required this.subjectId,
    this.subjectName,
    required this.teacherId,
    required this.date,
    this.activityId,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.homeworkId,
  });

  factory SessionModel.fromJson(Map<dynamic, dynamic> json, {String? key}) {
    return SessionModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      classroomId: json['classroomId']?.toString() ?? '',
      subjectId: json['subjectId']?.toString() ?? '',
      subjectName: json['subjectName']?.toString(),
      teacherId: json['teacherId']?.toString() ?? '',
      date: _int(json['date']) ?? 0,
      activityId: json['activityId']?.toString(),
      status: json['status']?.toString() ?? 'active',
      startedAt: _int(json['startedAt']) ?? 0,
      endedAt: _int(json['endedAt']),
      homeworkId: json['homeworkId']?.toString(),
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
    d['subjectId'] = subjectId;
    put('subjectName', subjectName);
    d['teacherId'] = teacherId;
    d['date'] = date;
    put('activityId', activityId);
    d['status'] = status;
    d['startedAt'] = startedAt;
    put('endedAt', endedAt);
    put('homeworkId', homeworkId);
    return d;
  }

  SessionModel copyWith({
    String? key,
    String? nurseryId,
    String? classroomId,
    String? subjectId,
    String? subjectName,
    String? teacherId,
    int? date,
    String? activityId,
    String? status,
    int? startedAt,
    int? endedAt,
    String? homeworkId,
  }) =>
      SessionModel(
        key: key ?? this.key,
        nurseryId: nurseryId ?? this.nurseryId,
        classroomId: classroomId ?? this.classroomId,
        subjectId: subjectId ?? this.subjectId,
        subjectName: subjectName ?? this.subjectName,
        teacherId: teacherId ?? this.teacherId,
        date: date ?? this.date,
        activityId: activityId ?? this.activityId,
        status: status ?? this.status,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt ?? this.endedAt,
        homeworkId: homeworkId ?? this.homeworkId,
      );

  static int? _int(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

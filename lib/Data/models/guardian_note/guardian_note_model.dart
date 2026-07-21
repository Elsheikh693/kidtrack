// Firebase path: platform/{nurseryId}/guardianNotes/{key}
//
// A note a GUARDIAN writes back to the nursery about ONE session/activity their
// child attended — the reverse direction of the teacher→parent Link Book notes.
// One editable note per child per activity: the key is deterministic
// (`gn_{activityId}_{childId}`) so the parent editing simply re-writes it.
//
// Display fields (childName / classroomName / subjectName / activityTitle) are
// denormalised so the staff-side inbox renders each note without extra lookups.

class GuardianNoteModel {
  final String? key;
  final String nurseryId;

  // Who / which child the note is about.
  final String childId;
  final String childName;
  final String classroomId;
  final String classroomName;

  // Which session/activity the note is attached to.
  final String activityId;
  final String subjectName;
  final String activityTitle;
  final int activityStartedAt;

  // Author (the guardian).
  final String guardianId;
  final String guardianName;

  final String content;

  /// Start-of-day ms of the session's day — the anchor the staff date filter
  /// and day-grouping use.
  final int dayKey;

  final int? createdAt;
  final int? updatedAt;

  const GuardianNoteModel({
    this.key,
    required this.nurseryId,
    required this.childId,
    required this.childName,
    required this.classroomId,
    required this.classroomName,
    required this.activityId,
    required this.subjectName,
    required this.activityTitle,
    required this.activityStartedAt,
    required this.guardianId,
    required this.guardianName,
    required this.content,
    required this.dayKey,
    this.createdAt,
    this.updatedAt,
  });

  /// Deterministic key giving one editable note per child per activity.
  static String buildKey(String activityId, String childId) =>
      'gn_${activityId}_$childId';

  factory GuardianNoteModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return GuardianNoteModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      childName: json['childName']?.toString() ?? '',
      classroomId: json['classroomId']?.toString() ?? '',
      classroomName: json['classroomName']?.toString() ?? '',
      activityId: json['activityId']?.toString() ?? '',
      subjectName: json['subjectName']?.toString() ?? '',
      activityTitle: json['activityTitle']?.toString() ?? '',
      activityStartedAt: _parseInt(json['activityStartedAt']) ?? 0,
      guardianId: json['guardianId']?.toString() ?? '',
      guardianName: json['guardianName']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      dayKey: _parseInt(json['dayKey']) ?? 0,
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('key', key);
    data['nurseryId'] = nurseryId;
    data['childId'] = childId;
    data['childName'] = childName;
    data['classroomId'] = classroomId;
    data['classroomName'] = classroomName;
    data['activityId'] = activityId;
    data['subjectName'] = subjectName;
    data['activityTitle'] = activityTitle;
    data['activityStartedAt'] = activityStartedAt;
    data['guardianId'] = guardianId;
    data['guardianName'] = guardianName;
    data['content'] = content;
    data['dayKey'] = dayKey;
    put('createdAt', createdAt ?? _now());
    data['updatedAt'] = _now();
    return data;
  }

  GuardianNoteModel copyWith({
    String? content,
    int? updatedAt,
  }) {
    return GuardianNoteModel(
      key: key,
      nurseryId: nurseryId,
      childId: childId,
      childName: childName,
      classroomId: classroomId,
      classroomName: classroomName,
      activityId: activityId,
      subjectName: subjectName,
      activityTitle: activityTitle,
      activityStartedAt: activityStartedAt,
      guardianId: guardianId,
      guardianName: guardianName,
      content: content ?? this.content,
      dayKey: dayKey,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _now() => DateTime.now().millisecondsSinceEpoch;

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }
}

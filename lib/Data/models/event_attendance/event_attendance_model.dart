class EventAttendanceModel {
  final String eventId;
  final String childId;
  final String parentId;
  final String childName;
  final String parentName;
  final int confirmedAt;

  const EventAttendanceModel({
    required this.eventId,
    required this.childId,
    required this.parentId,
    required this.childName,
    required this.parentName,
    required this.confirmedAt,
  });

  factory EventAttendanceModel.fromJson(
    Map<String, dynamic> json, {
    required String eventId,
    required String childId,
  }) {
    return EventAttendanceModel(
      eventId: eventId,
      childId: childId,
      parentId: json['parentId']?.toString() ?? '',
      childName: json['childName']?.toString() ?? '',
      parentName: json['parentName']?.toString() ?? '',
      confirmedAt: _parseInt(json['confirmedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'parentId': parentId,
    'childName': childName,
    'parentName': parentName,
    'confirmedAt': confirmedAt,
  };

  static int _parseInt(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }
}

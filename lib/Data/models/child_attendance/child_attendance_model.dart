class ChildAttendanceModel {
  final String? key;
  final String nurseryId;
  final String childId;
  final String branchId;
  final String? classroomId;
  final String date; // "2024-01-15"
  final String status; // present, absent, late, excused
  final int? checkInTime;
  final int? checkOutTime;
  final String? checkInBy;
  final String? checkOutBy;
  final String? pickedUpByName;
  final String? pickedUpByRelationship;
  final String? note;
  final int? createdAt;
  final int? updatedAt;

  const ChildAttendanceModel({
    this.key,
    required this.nurseryId,
    required this.childId,
    required this.branchId,
    this.classroomId,
    required this.date,
    this.status = 'present',
    this.checkInTime,
    this.checkOutTime,
    this.checkInBy,
    this.checkOutBy,
    this.pickedUpByName,
    this.pickedUpByRelationship,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory ChildAttendanceModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return ChildAttendanceModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      classroomId: json['classroomId']?.toString(),
      date: json['date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'present',
      checkInTime: _parseInt(json['checkInTime']),
      checkOutTime: _parseInt(json['checkOutTime']),
      checkInBy: json['checkInBy']?.toString(),
      checkOutBy: json['checkOutBy']?.toString(),
      pickedUpByName: json['pickedUpByName']?.toString(),
      pickedUpByRelationship: json['pickedUpByRelationship']?.toString(),
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
    put('childId', childId);
    put('branchId', branchId);
    put('classroomId', classroomId);
    data['date'] = date;
    data['status'] = status;
    put('checkInTime', checkInTime);
    put('checkOutTime', checkOutTime);
    put('checkInBy', checkInBy);
    put('checkOutBy', checkOutBy);
    put('pickedUpByName', pickedUpByName);
    put('pickedUpByRelationship', pickedUpByRelationship);
    put('note', note);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  ChildAttendanceModel copyWith({
    String? key, String? nurseryId, String? childId, String? branchId,
    String? classroomId, String? date, String? status,
    int? checkInTime, int? checkOutTime, String? checkInBy, String? checkOutBy,
    String? pickedUpByName, String? pickedUpByRelationship,
    String? note, int? createdAt, int? updatedAt,
  }) => ChildAttendanceModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    childId: childId ?? this.childId, branchId: branchId ?? this.branchId,
    classroomId: classroomId ?? this.classroomId, date: date ?? this.date,
    status: status ?? this.status, checkInTime: checkInTime ?? this.checkInTime,
    checkOutTime: checkOutTime ?? this.checkOutTime,
    checkInBy: checkInBy ?? this.checkInBy, checkOutBy: checkOutBy ?? this.checkOutBy,
    pickedUpByName: pickedUpByName ?? this.pickedUpByName,
    pickedUpByRelationship: pickedUpByRelationship ?? this.pickedUpByRelationship,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

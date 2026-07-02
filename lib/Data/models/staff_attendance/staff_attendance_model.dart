class StaffAttendanceModel {
  final String? key;
  final String nurseryId;
  final String staffId;
  final String branchId;
  final String date;
  final String status; // present, absent, late, on_leave
  final int? checkInTime;
  final int? checkOutTime;
  final String? note;
  final int? createdAt;
  final int? updatedAt;

  const StaffAttendanceModel({
    this.key,
    required this.nurseryId,
    required this.staffId,
    required this.branchId,
    required this.date,
    this.status = 'present',
    this.checkInTime,
    this.checkOutTime,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory StaffAttendanceModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return StaffAttendanceModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      staffId: json['staffId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'present',
      checkInTime: _parseInt(json['checkInTime']),
      checkOutTime: _parseInt(json['checkOutTime']),
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
    put('staffId', staffId);
    put('branchId', branchId);
    data['date'] = date;
    data['status'] = status;
    put('checkInTime', checkInTime);
    put('checkOutTime', checkOutTime);
    put('note', note);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  StaffAttendanceModel copyWith({
    String? key, String? nurseryId, String? staffId, String? branchId,
    String? date, String? status, int? checkInTime, int? checkOutTime,
    String? note, int? createdAt, int? updatedAt,
  }) => StaffAttendanceModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    staffId: staffId ?? this.staffId, branchId: branchId ?? this.branchId,
    date: date ?? this.date, status: status ?? this.status,
    checkInTime: checkInTime ?? this.checkInTime,
    checkOutTime: checkOutTime ?? this.checkOutTime,
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

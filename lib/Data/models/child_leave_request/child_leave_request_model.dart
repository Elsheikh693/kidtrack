class ChildLeaveRequestModel {
  final String? key;
  final String nurseryId;
  final String childId;
  final String requestedBy;
  final int startDate;
  final int endDate;
  final String reason;
  final String status; // pending, approved, rejected
  final int? createdAt;
  final int? updatedAt;

  const ChildLeaveRequestModel({
    this.key,
    required this.nurseryId,
    required this.childId,
    required this.requestedBy,
    required this.startDate,
    required this.endDate,
    required this.reason,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  factory ChildLeaveRequestModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return ChildLeaveRequestModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      requestedBy: json['requestedBy']?.toString() ?? '',
      startDate: _parseInt(json['startDate']) ?? 0,
      endDate: _parseInt(json['endDate']) ?? 0,
      reason: json['reason']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
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
    put('requestedBy', requestedBy);
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    data['reason'] = reason;
    data['status'] = status;
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  ChildLeaveRequestModel copyWith({
    String? key, String? nurseryId, String? childId, String? requestedBy,
    int? startDate, int? endDate, String? reason, String? status,
    int? createdAt, int? updatedAt,
  }) => ChildLeaveRequestModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    childId: childId ?? this.childId, requestedBy: requestedBy ?? this.requestedBy,
    startDate: startDate ?? this.startDate, endDate: endDate ?? this.endDate,
    reason: reason ?? this.reason, status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

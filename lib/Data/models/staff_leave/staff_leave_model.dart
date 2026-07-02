class StaffLeaveModel {
  final String? key;
  final String nurseryId;
  final String staffId;
  final String type; // annual, sick, emergency, unpaid
  final int startDate;
  final int endDate;
  final String? reason;
  final String status; // pending, approved, rejected
  final String? reviewedBy;
  final int? reviewedAt;
  final int? createdAt;
  final int? updatedAt;

  const StaffLeaveModel({
    this.key,
    required this.nurseryId,
    required this.staffId,
    this.type = 'annual',
    required this.startDate,
    required this.endDate,
    this.reason,
    this.status = 'pending',
    this.reviewedBy,
    this.reviewedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory StaffLeaveModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return StaffLeaveModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      staffId: json['staffId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'annual',
      startDate: _parseInt(json['startDate']) ?? 0,
      endDate: _parseInt(json['endDate']) ?? 0,
      reason: json['reason']?.toString(),
      status: json['status']?.toString() ?? 'pending',
      reviewedBy: json['reviewedBy']?.toString(),
      reviewedAt: _parseInt(json['reviewedAt']),
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
    data['type'] = type;
    data['startDate'] = startDate;
    data['endDate'] = endDate;
    put('reason', reason);
    data['status'] = status;
    put('reviewedBy', reviewedBy);
    put('reviewedAt', reviewedAt);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  StaffLeaveModel copyWith({
    String? key, String? nurseryId, String? staffId, String? type,
    int? startDate, int? endDate, String? reason, String? status,
    String? reviewedBy, int? reviewedAt, int? createdAt, int? updatedAt,
  }) => StaffLeaveModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    staffId: staffId ?? this.staffId, type: type ?? this.type,
    startDate: startDate ?? this.startDate, endDate: endDate ?? this.endDate,
    reason: reason ?? this.reason, status: status ?? this.status,
    reviewedBy: reviewedBy ?? this.reviewedBy, reviewedAt: reviewedAt ?? this.reviewedAt,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

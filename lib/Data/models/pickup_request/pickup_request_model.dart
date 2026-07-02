class PickupRequestModel {
  final String? key;
  final String nurseryId;
  final String branchId;
  final String childId;
  final String parentId;
  final int? requestedPickupTime;
  // requested → approved → child_preparing → ready → checked_out | rejected
  final String status;
  final String? approvedBy;
  final int? approvedAt;
  final String? parentNotes;
  final String? staffNotes;
  final int? createdAt;
  final int? updatedAt;

  const PickupRequestModel({
    this.key,
    required this.nurseryId,
    required this.branchId,
    required this.childId,
    required this.parentId,
    this.requestedPickupTime,
    this.status = 'requested',
    this.approvedBy,
    this.approvedAt,
    this.parentNotes,
    this.staffNotes,
    this.createdAt,
    this.updatedAt,
  });

  factory PickupRequestModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return PickupRequestModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      parentId: json['parentId']?.toString() ?? '',
      requestedPickupTime: _parseInt(json['requestedPickupTime']),
      status: json['status']?.toString() ?? 'requested',
      approvedBy: json['approvedBy']?.toString(),
      approvedAt: _parseInt(json['approvedAt']),
      parentNotes: json['parentNotes']?.toString(),
      staffNotes: json['staffNotes']?.toString(),
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
    put('nurseryId', nurseryId);
    put('branchId', branchId);
    put('childId', childId);
    put('parentId', parentId);
    put('requestedPickupTime', requestedPickupTime);
    data['status'] = status;
    put('approvedBy', approvedBy);
    put('approvedAt', approvedAt);
    put('parentNotes', parentNotes);
    put('staffNotes', staffNotes);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  PickupRequestModel copyWith({
    String? key,
    String? nurseryId,
    String? branchId,
    String? childId,
    String? parentId,
    int? requestedPickupTime,
    String? status,
    String? approvedBy,
    int? approvedAt,
    String? parentNotes,
    String? staffNotes,
    int? createdAt,
    int? updatedAt,
  }) =>
      PickupRequestModel(
        key: key ?? this.key,
        nurseryId: nurseryId ?? this.nurseryId,
        branchId: branchId ?? this.branchId,
        childId: childId ?? this.childId,
        parentId: parentId ?? this.parentId,
        requestedPickupTime: requestedPickupTime ?? this.requestedPickupTime,
        status: status ?? this.status,
        approvedBy: approvedBy ?? this.approvedBy,
        approvedAt: approvedAt ?? this.approvedAt,
        parentNotes: parentNotes ?? this.parentNotes,
        staffNotes: staffNotes ?? this.staffNotes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

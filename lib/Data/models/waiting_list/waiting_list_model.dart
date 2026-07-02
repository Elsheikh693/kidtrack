class WaitingListModel {
  final String? key;
  final String nurseryId;
  final String? branchId;
  final String childName;
  final String parentName;
  final String parentPhone;
  final int? childDob;
  final String? notes;
  final String status; // pending, contacted, enrolled, cancelled
  final int? createdAt;
  final int? updatedAt;

  const WaitingListModel({
    this.key,
    required this.nurseryId,
    this.branchId,
    required this.childName,
    required this.parentName,
    required this.parentPhone,
    this.childDob,
    this.notes,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  factory WaitingListModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return WaitingListModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      branchId: json['branchId']?.toString(),
      childName: json['childName']?.toString() ?? '',
      parentName: json['parentName']?.toString() ?? '',
      parentPhone: json['parentPhone']?.toString() ?? '',
      childDob: _parseInt(json['childDob']),
      notes: json['notes']?.toString(),
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
    put('branchId', branchId);
    put('childName', childName);
    put('parentName', parentName);
    put('parentPhone', parentPhone);
    put('childDob', childDob);
    put('notes', notes);
    data['status'] = status;
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  WaitingListModel copyWith({
    String? key, String? nurseryId, String? branchId, String? childName,
    String? parentName, String? parentPhone, int? childDob,
    String? notes, String? status, int? createdAt, int? updatedAt,
  }) => WaitingListModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    branchId: branchId ?? this.branchId, childName: childName ?? this.childName,
    parentName: parentName ?? this.parentName,
    parentPhone: parentPhone ?? this.parentPhone,
    childDob: childDob ?? this.childDob, notes: notes ?? this.notes,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

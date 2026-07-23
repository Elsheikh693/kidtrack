/// A compact record written by the `withdrawChild` Cloud Function BEFORE a child
/// is hard-deleted, so the "left this month" movement stat and the withdrawn
/// list survive the wipe. Lives under `platform/{nid}/withdrawals/{id}`.
class WithdrawalLogModel {
  final String? key;
  final String childId;
  final String childName;
  final String branchId;
  final String? classroomId;
  final String? reason; // preset label + optional note, e.g. "سبب — ملاحظة"
  final String? withdrawnBy;
  final int? withdrawnAt; // ms since epoch
  final List<String> parentIds;

  const WithdrawalLogModel({
    this.key,
    required this.childId,
    required this.childName,
    required this.branchId,
    this.classroomId,
    this.reason,
    this.withdrawnBy,
    this.withdrawnAt,
    this.parentIds = const [],
  });

  bool get hasReason => reason != null && reason!.trim().isNotEmpty;

  /// The preset label part of [reason] ("label — note" → "label").
  String get reasonLabel {
    if (!hasReason) return '';
    final r = reason!.trim();
    final i = r.indexOf(' — ');
    return i == -1 ? r : r.substring(0, i).trim();
  }

  /// The optional free-text note part of [reason] ("label — note" → "note").
  String get reasonNote {
    if (!hasReason) return '';
    final r = reason!.trim();
    final i = r.indexOf(' — ');
    return i == -1 ? '' : r.substring(i + 3).trim();
  }

  DateTime? get withdrawnDate => withdrawnAt == null
      ? null
      : DateTime.fromMillisecondsSinceEpoch(withdrawnAt!);

  factory WithdrawalLogModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return WithdrawalLogModel(
      key: key ?? json['key']?.toString(),
      childId: json['childId']?.toString() ?? '',
      childName: json['childName']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      classroomId: json['classroomId']?.toString(),
      reason: json['reason']?.toString(),
      withdrawnBy: json['withdrawnBy']?.toString(),
      withdrawnAt: _parseInt(json['withdrawnAt']),
      parentIds: _parseParentIds(json['parentIds']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('key', key);
    data['childId'] = childId;
    data['childName'] = childName;
    data['branchId'] = branchId;
    put('classroomId', classroomId);
    put('reason', reason);
    put('withdrawnBy', withdrawnBy);
    put('withdrawnAt', withdrawnAt);
    if (parentIds.isNotEmpty) data['parentIds'] = parentIds;
    return data;
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }

  static List<String> _parseParentIds(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    if (v is Map) return v.values.map((e) => e.toString()).toList();
    return const [];
  }
}

/// Fixed platform subscription price charged per active child, per month (EGP).
/// Business constant — the SuperAdmin bills every nursery `count × this`.
const double kPlatformPricePerChild = 50;

/// The platform's monthly subscription bill for ONE nursery.
///
/// Stored at `platformBilling/{nurseryId}/{YYYYMM}`. A record only exists once
/// the SuperAdmin has acted on that month (collected it); before that the UI
/// projects an unpaid bill live from the nursery's current child count. On
/// collection the child count + price + per-branch split are SNAPSHOT into the
/// record so historical months never drift as children come and go.
class PlatformBillModel {
  final String? key; // == month string (YYYYMM)
  final String nurseryId;
  final int month; // YYYYMM, e.g. 202607
  final double pricePerChild;
  final int totalChildCount;
  final double totalAmount;
  final List<PlatformBillBranch> branches;
  final String status; // paid | unpaid
  final int? paidAt;
  final String? collectedBy; // super admin uid
  final String? collectedByName;
  final String? note;
  final int? createdAt;
  final int? updatedAt;

  const PlatformBillModel({
    this.key,
    required this.nurseryId,
    required this.month,
    this.pricePerChild = kPlatformPricePerChild,
    required this.totalChildCount,
    required this.totalAmount,
    this.branches = const [],
    this.status = 'unpaid',
    this.paidAt,
    this.collectedBy,
    this.collectedByName,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPaid => status == 'paid';

  factory PlatformBillModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return PlatformBillModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      month: _parseInt(json['month']) ?? 0,
      pricePerChild: _parseDouble(json['pricePerChild']) ?? kPlatformPricePerChild,
      totalChildCount: _parseInt(json['totalChildCount']) ?? 0,
      totalAmount: _parseDouble(json['totalAmount']) ?? 0,
      branches: PlatformBillBranch.parseList(json['branches']),
      status: json['status']?.toString() ?? 'unpaid',
      paidAt: _parseInt(json['paidAt']),
      collectedBy: json['collectedBy']?.toString(),
      collectedByName: json['collectedByName']?.toString(),
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
    data['month'] = month;
    data['pricePerChild'] = pricePerChild;
    data['totalChildCount'] = totalChildCount;
    data['totalAmount'] = totalAmount;
    if (branches.isNotEmpty) {
      data['branches'] = branches.map((b) => b.toJson()).toList();
    }
    data['status'] = status;
    put('paidAt', paidAt);
    put('collectedBy', collectedBy);
    put('collectedByName', collectedByName);
    put('note', note);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  PlatformBillModel copyWith({
    String? key, String? nurseryId, int? month, double? pricePerChild,
    int? totalChildCount, double? totalAmount, List<PlatformBillBranch>? branches,
    String? status, int? paidAt, String? collectedBy, String? collectedByName,
    String? note, int? createdAt, int? updatedAt,
  }) => PlatformBillModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    month: month ?? this.month, pricePerChild: pricePerChild ?? this.pricePerChild,
    totalChildCount: totalChildCount ?? this.totalChildCount,
    totalAmount: totalAmount ?? this.totalAmount,
    branches: branches ?? this.branches, status: status ?? this.status,
    paidAt: paidAt ?? this.paidAt, collectedBy: collectedBy ?? this.collectedBy,
    collectedByName: collectedByName ?? this.collectedByName,
    note: note ?? this.note,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

/// One branch's slice of a nursery's monthly platform bill.
class PlatformBillBranch {
  final String branchId;
  final String branchName;
  final int childCount;
  final double amount;

  const PlatformBillBranch({
    required this.branchId,
    required this.branchName,
    required this.childCount,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'branchId': branchId,
        'branchName': branchName,
        'childCount': childCount,
        'amount': amount,
      };

  factory PlatformBillBranch.fromJson(Map<String, dynamic> json) {
    return PlatformBillBranch(
      branchId: json['branchId']?.toString() ?? '',
      branchName: json['branchName']?.toString() ?? '',
      childCount: PlatformBillModel._parseInt(json['childCount']) ?? 0,
      amount: PlatformBillModel._parseDouble(json['amount']) ?? 0,
    );
  }

  static List<PlatformBillBranch> parseList(dynamic v) {
    if (v == null) return const [];
    Iterable<dynamic> raw;
    if (v is List) {
      raw = v;
    } else if (v is Map) {
      raw = v.values;
    } else {
      return const [];
    }
    return raw
        .whereType<Map>()
        .map((e) => PlatformBillBranch.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }
}

/// A single finance event in the nursery's revenue log.
///
/// In the MVP this is always a cash **collection** the receptionist recorded
/// (money already received). [type] exists so the same entity can later hold
/// `refund` / `adjustment` without a schema change. Every transaction carries
/// its own [branchId] (denormalized) so reports never need a child→branch join,
/// and [categoryName] is snapshotted so a later category rename can't rewrite
/// history.
class FinancialTransactionModel {
  final String? key;
  final String nurseryId;
  final String branchId;
  final String childId;

  /// Snapshot of the child's name at collection time — denormalized so reports
  /// (owner/manager dashboards) render collection rows without a child join.
  final String childName;

  /// 'collection' only in the MVP. Future: 'refund', 'adjustment'.
  final String type;

  final String categoryId;

  /// Snapshot of the category name at collection time (survives renames).
  final String categoryName;

  final double amount;

  /// When the money was received (ms since epoch).
  final int date;

  /// Staff member who received the money.
  final String? collectedBy;
  final String? collectedByName;

  /// Optional link to a course, so course revenue can be reported directly.
  final String? courseId;

  final String? notes;
  final int? createdAt;

  const FinancialTransactionModel({
    this.key,
    required this.nurseryId,
    required this.branchId,
    required this.childId,
    this.childName = '',
    this.type = TransactionType.collection,
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.date,
    this.collectedBy,
    this.collectedByName,
    this.courseId,
    this.notes,
    this.createdAt,
  });

  factory FinancialTransactionModel.fromJson(
    Map<String, dynamic> json, {
    String? key,
  }) {
    return FinancialTransactionModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      childName: json['childName']?.toString() ?? '',
      type: json['type']?.toString() ?? TransactionType.collection,
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      amount: _parseDouble(json['amount']) ?? 0,
      date: _parseInt(json['date']) ?? _now(),
      collectedBy: json['collectedBy']?.toString(),
      collectedByName: json['collectedByName']?.toString(),
      courseId: json['courseId']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: _parseInt(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('key', key);
    put('nurseryId', nurseryId);
    data['branchId'] = branchId;
    data['childId'] = childId;
    data['childName'] = childName;
    data['type'] = type;
    data['categoryId'] = categoryId;
    data['categoryName'] = categoryName;
    data['amount'] = amount;
    data['date'] = date;
    put('collectedBy', collectedBy);
    put('collectedByName', collectedByName);
    put('courseId', courseId);
    put('notes', notes);
    put('createdAt', createdAt ?? _now());
    return data;
  }

  FinancialTransactionModel copyWith({
    String? key,
    String? nurseryId,
    String? branchId,
    String? childId,
    String? childName,
    String? type,
    String? categoryId,
    String? categoryName,
    double? amount,
    int? date,
    String? collectedBy,
    String? collectedByName,
    String? courseId,
    String? notes,
    int? createdAt,
  }) =>
      FinancialTransactionModel(
        key: key ?? this.key,
        nurseryId: nurseryId ?? this.nurseryId,
        branchId: branchId ?? this.branchId,
        childId: childId ?? this.childId,
        childName: childName ?? this.childName,
        type: type ?? this.type,
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        collectedBy: collectedBy ?? this.collectedBy,
        collectedByName: collectedByName ?? this.collectedByName,
        courseId: courseId ?? this.courseId,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
      );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

/// Transaction kinds. Only `collection` is used in the MVP.
class TransactionType {
  TransactionType._();
  static const String collection = 'collection';
  static const String refund = 'refund';
  static const String adjustment = 'adjustment';
}

/// A nursery expense / obligation owed to a vendor or party
/// (e.g. bus subscription, course, rent, bills, salaries, maintenance).
///
/// Distinct from [InvoiceModel] which represents money owed BY parents
/// (accounts receivable). This represents money the nursery owes
/// (accounts payable).
class ExpenseModel {
  final String? key;
  final String nurseryId;

  /// Which branch this expense belongs to. `null` = a NETWORK OVERHEAD cost
  /// (marketing, accounting, central software) not attributable to one branch.
  /// A non-null value is a branch-direct cost (rent, electricity, salaries) and
  /// is what lets the owner see honest per-branch "Direct Profit".
  final String? branchId;

  /// The vendor / party the expense is owed to (e.g. "فان داي").
  final String party;

  /// Optional description of what the expense is for.
  final String? item;

  final String? categoryId;
  final String? categoryName;

  final double amount;

  /// Due date in milliseconds since epoch.
  final int? dueDate;

  /// 'pending' | 'paid'. Overdue/upcoming is derived from [dueDate].
  final String status;

  final int? paidAt;
  final String? paidBy;
  final int? createdAt;
  final int? updatedAt;

  const ExpenseModel({
    this.key,
    required this.nurseryId,
    this.branchId,
    required this.party,
    this.item,
    this.categoryId,
    this.categoryName,
    required this.amount,
    this.dueDate,
    this.status = 'pending',
    this.paidAt,
    this.paidBy,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPaid => status == 'paid';

  factory ExpenseModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return ExpenseModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      branchId: json['branchId']?.toString(),
      party: json['party']?.toString() ?? '',
      item: json['item']?.toString(),
      categoryId: json['categoryId']?.toString(),
      categoryName: json['categoryName']?.toString(),
      amount: _parseDouble(json['amount']) ?? 0,
      dueDate: _parseInt(json['dueDate']),
      status: json['status']?.toString() ?? 'pending',
      paidAt: _parseInt(json['paidAt']),
      paidBy: json['paidBy']?.toString(),
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
    data['party'] = party;
    put('item', item);
    put('categoryId', categoryId);
    put('categoryName', categoryName);
    data['amount'] = amount;
    put('dueDate', dueDate);
    data['status'] = status;
    put('paidAt', paidAt);
    put('paidBy', paidBy);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', updatedAt);
    return data;
  }

  ExpenseModel copyWith({
    String? key,
    String? nurseryId,
    String? branchId,
    String? party,
    String? item,
    String? categoryId,
    String? categoryName,
    double? amount,
    int? dueDate,
    String? status,
    int? paidAt,
    String? paidBy,
    int? createdAt,
    int? updatedAt,
  }) =>
      ExpenseModel(
        key: key ?? this.key,
        nurseryId: nurseryId ?? this.nurseryId,
        branchId: branchId ?? this.branchId,
        party: party ?? this.party,
        item: item ?? this.item,
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
        amount: amount ?? this.amount,
        dueDate: dueDate ?? this.dueDate,
        status: status ?? this.status,
        paidAt: paidAt ?? this.paidAt,
        paidBy: paidBy ?? this.paidBy,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
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

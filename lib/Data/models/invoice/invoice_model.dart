class InvoiceModel {
  final String? key;
  final String nurseryId;
  final String childId;
  final String? parentId;
  final String? packageId;
  final String? enrollmentId;
  final String? categoryId;
  final String? categoryName;
  final String? title;
  final double amount;
  final double discount;
  final double totalAmount;
  final String status; // pending, paid, overdue, cancelled
  final int? dueDate;
  final int? paidAt;
  final String? paidBy;
  final String? paymentMethod;
  final String? notes;
  final int? createdAt;
  final int? updatedAt;

  const InvoiceModel({
    this.key,
    required this.nurseryId,
    required this.childId,
    this.parentId,
    this.packageId,
    this.enrollmentId,
    this.categoryId,
    this.categoryName,
    this.title,
    required this.amount,
    this.discount = 0,
    required this.totalAmount,
    this.status = 'pending',
    this.dueDate,
    this.paidAt,
    this.paidBy,
    this.paymentMethod,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return InvoiceModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      parentId: json['parentId']?.toString(),
      packageId: json['packageId']?.toString(),
      enrollmentId: json['enrollmentId']?.toString(),
      categoryId: json['categoryId']?.toString(),
      categoryName: json['categoryName']?.toString(),
      title: json['title']?.toString(),
      amount: _parseDouble(json['amount']),
      discount: _parseDouble(json['discount']),
      totalAmount: _parseDouble(json['totalAmount']),
      status: json['status']?.toString() ?? 'pending',
      dueDate: _parseInt(json['dueDate']),
      paidAt: _parseInt(json['paidAt']),
      paidBy: json['paidBy']?.toString(),
      paymentMethod: json['paymentMethod']?.toString(),
      notes: json['notes']?.toString(),
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
    put('parentId', parentId);
    put('packageId', packageId);
    put('enrollmentId', enrollmentId);
    put('categoryId', categoryId);
    put('categoryName', categoryName);
    put('title', title);
    data['amount'] = amount;
    data['discount'] = discount;
    data['totalAmount'] = totalAmount;
    data['status'] = status;
    put('dueDate', dueDate);
    put('paidAt', paidAt);
    put('paidBy', paidBy);
    put('paymentMethod', paymentMethod);
    put('notes', notes);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  InvoiceModel copyWith({
    String? key, String? nurseryId, String? childId, String? parentId,
    String? packageId, String? enrollmentId,
    String? categoryId, String? categoryName, String? title,
    double? amount, double? discount,
    double? totalAmount, String? status, int? dueDate, int? paidAt,
    String? paidBy, String? paymentMethod,
    String? notes, int? createdAt, int? updatedAt,
  }) => InvoiceModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    childId: childId ?? this.childId, parentId: parentId ?? this.parentId,
    packageId: packageId ?? this.packageId, enrollmentId: enrollmentId ?? this.enrollmentId,
    categoryId: categoryId ?? this.categoryId,
    categoryName: categoryName ?? this.categoryName,
    title: title ?? this.title,
    amount: amount ?? this.amount, discount: discount ?? this.discount,
    totalAmount: totalAmount ?? this.totalAmount, status: status ?? this.status,
    dueDate: dueDate ?? this.dueDate, paidAt: paidAt ?? this.paidAt,
    paidBy: paidBy ?? this.paidBy, paymentMethod: paymentMethod ?? this.paymentMethod,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static double _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

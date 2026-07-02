class PaymentModel {
  final String? key;
  final String nurseryId;
  final String invoiceId;
  final String childId;
  final String? parentId;
  final String? categoryId;
  final String? categoryName;
  final double amount;
  final String method; // cash, card, bank_transfer, online
  final String? reference;
  final String? receivedBy;
  final int paidAt;
  final int? createdAt;

  const PaymentModel({
    this.key,
    required this.nurseryId,
    required this.invoiceId,
    required this.childId,
    this.parentId,
    this.categoryId,
    this.categoryName,
    required this.amount,
    this.method = 'cash',
    this.reference,
    this.receivedBy,
    required this.paidAt,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return PaymentModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      invoiceId: json['invoiceId']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      parentId: json['parentId']?.toString(),
      categoryId: json['categoryId']?.toString(),
      categoryName: json['categoryName']?.toString(),
      amount: _parseDouble(json['amount']),
      method: json['method']?.toString() ?? 'cash',
      reference: json['reference']?.toString(),
      receivedBy: json['receivedBy']?.toString(),
      paidAt: _parseInt(json['paidAt']) ?? _now(),
      createdAt: _parseInt(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    put('nurseryId', nurseryId);
    put('invoiceId', invoiceId);
    put('childId', childId);
    put('parentId', parentId);
    put('categoryId', categoryId);
    put('categoryName', categoryName);
    data['amount'] = amount;
    data['method'] = method;
    put('reference', reference);
    put('receivedBy', receivedBy);
    data['paidAt'] = paidAt;
    put('createdAt', createdAt ?? _now());
    return data;
  }

  PaymentModel copyWith({
    String? key, String? nurseryId, String? invoiceId, String? childId,
    String? parentId, String? categoryId, String? categoryName,
    double? amount, String? method, String? reference,
    String? receivedBy, int? paidAt, int? createdAt,
  }) => PaymentModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    invoiceId: invoiceId ?? this.invoiceId, childId: childId ?? this.childId,
    parentId: parentId ?? this.parentId,
    categoryId: categoryId ?? this.categoryId,
    categoryName: categoryName ?? this.categoryName,
    amount: amount ?? this.amount,
    method: method ?? this.method, reference: reference ?? this.reference,
    receivedBy: receivedBy ?? this.receivedBy, paidAt: paidAt ?? this.paidAt,
    createdAt: createdAt ?? this.createdAt,
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

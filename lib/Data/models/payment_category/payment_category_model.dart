class PaymentCategoryModel {
  final String? key;
  final String nurseryId;
  final String name;
  final int colorValue;
  final bool isActive;
  final int? createdAt;

  const PaymentCategoryModel({
    this.key,
    required this.nurseryId,
    required this.name,
    required this.colorValue,
    this.isActive = true,
    this.createdAt,
  });

  factory PaymentCategoryModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return PaymentCategoryModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      colorValue: _parseInt(json['colorValue']) ?? 0xFF0D9488,
      isActive: json['isActive'] == true || json['isActive'] == null,
      createdAt: _parseInt(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    put('nurseryId', nurseryId);
    data['name'] = name;
    data['colorValue'] = colorValue;
    data['isActive'] = isActive;
    put('createdAt', createdAt ?? _now());
    return data;
  }

  PaymentCategoryModel copyWith({
    String? key,
    String? nurseryId,
    String? name,
    int? colorValue,
    bool? isActive,
    int? createdAt,
  }) =>
      PaymentCategoryModel(
        key: key ?? this.key,
        nurseryId: nurseryId ?? this.nurseryId,
        name: name ?? this.name,
        colorValue: colorValue ?? this.colorValue,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

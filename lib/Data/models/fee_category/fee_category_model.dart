/// A type of fee a nursery can collect (اشتراك شهري، يونيفورم، كتب…).
///
/// Categories are the fixed list the receptionist picks from when collecting
/// money. Each has an optional [defaultAmount] that pre-fills the collection
/// screen (still editable). [type] (recurring vs one-time) is STORED but not
/// surfaced in the MVP — it's the hook for future auto-renewal of monthly fees.
class FeeCategoryModel {
  final String? key;
  final String nurseryId;
  final String name;

  /// Pre-fills the amount when the receptionist picks this category. Null = no
  /// default (receptionist types the amount).
  final double? defaultAmount;

  /// 'recurring' | 'oneTime'. Stored now, hidden in the MVP UI.
  final String type;

  final bool isActive;
  final int sortOrder;
  final int? createdAt;

  const FeeCategoryModel({
    this.key,
    required this.nurseryId,
    required this.name,
    this.defaultAmount,
    this.type = FeeCategoryType.oneTime,
    this.isActive = true,
    this.sortOrder = 0,
    this.createdAt,
  });

  bool get isRecurring => type == FeeCategoryType.recurring;

  factory FeeCategoryModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return FeeCategoryModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      defaultAmount: _parseDouble(json['defaultAmount']),
      type: json['type']?.toString() ?? FeeCategoryType.oneTime,
      isActive: json['isActive'] == true || json['isActive'] == null,
      sortOrder: _parseInt(json['sortOrder']) ?? 0,
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
    data['name'] = name;
    put('defaultAmount', defaultAmount);
    data['type'] = type;
    data['isActive'] = isActive;
    data['sortOrder'] = sortOrder;
    put('createdAt', createdAt ?? _now());
    return data;
  }

  FeeCategoryModel copyWith({
    String? key,
    String? nurseryId,
    String? name,
    double? defaultAmount,
    String? type,
    bool? isActive,
    int? sortOrder,
    int? createdAt,
  }) =>
      FeeCategoryModel(
        key: key ?? this.key,
        nurseryId: nurseryId ?? this.nurseryId,
        name: name ?? this.name,
        defaultAmount: defaultAmount ?? this.defaultAmount,
        type: type ?? this.type,
        isActive: isActive ?? this.isActive,
        sortOrder: sortOrder ?? this.sortOrder,
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

/// Fee category kinds. Only stored for now; the MVP UI does not show it.
class FeeCategoryType {
  FeeCategoryType._();
  static const String recurring = 'recurring';
  static const String oneTime = 'oneTime';
}

/// The starter categories seeded for a nursery the first time finance settings
/// are opened. Amounts are left null so the owner sets them per nursery.
class FeeCategoryDefaults {
  FeeCategoryDefaults._();

  static const List<({String name, String type})> seed = [
    (name: 'اشتراك شهري', type: FeeCategoryType.recurring),
    (name: 'استمارة', type: FeeCategoryType.oneTime),
    (name: 'يونيفورم', type: FeeCategoryType.oneTime),
    (name: 'كتب', type: FeeCategoryType.oneTime),
    (name: 'كورسات', type: FeeCategoryType.oneTime),
    (name: 'أنشطة', type: FeeCategoryType.oneTime),
    (name: 'رحلات', type: FeeCategoryType.oneTime),
  ];
}

class ParentChildModel {
  final String? key;
  final String parentId;
  final String childId;
  final String nurseryId;
  final String relationship; // father, mother, other
  final bool isPrimary;
  final int? createdAt;

  const ParentChildModel({
    this.key,
    required this.parentId,
    required this.childId,
    required this.nurseryId,
    this.relationship = 'other',
    this.isPrimary = false,
    this.createdAt,
  });

  factory ParentChildModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return ParentChildModel(
      key: key ?? json['key']?.toString(),
      parentId: json['parentId']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      nurseryId: json['nurseryId']?.toString() ?? '',
      relationship: json['relationship']?.toString() ?? 'other',
      isPrimary: _parseBool(json['isPrimary']),
      createdAt: _parseInt(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    put('parentId', parentId);
    put('childId', childId);
    put('nurseryId', nurseryId);
    data['relationship'] = relationship;
    data['isPrimary'] = isPrimary;
    put('createdAt', createdAt ?? _now());
    return data;
  }

  ParentChildModel copyWith({
    String? key, String? parentId, String? childId, String? nurseryId,
    String? relationship, bool? isPrimary, int? createdAt,
  }) => ParentChildModel(
    key: key ?? this.key, parentId: parentId ?? this.parentId,
    childId: childId ?? this.childId, nurseryId: nurseryId ?? this.nurseryId,
    relationship: relationship ?? this.relationship,
    isPrimary: isPrimary ?? this.isPrimary, createdAt: createdAt ?? this.createdAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) return v == '1' || v.toLowerCase() == 'true';
    return false;
  }
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

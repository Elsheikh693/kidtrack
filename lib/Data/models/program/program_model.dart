class ProgramModel {
  final String? key;
  final String nurseryId;
  final String name;
  final String? description;
  final String? ageGroup;
  // Empty list = available in all branches; otherwise restricted to these branch ids.
  final List<String> branchIds;
  final bool isActive;
  final int? createdAt;
  final int? updatedAt;

  const ProgramModel({
    this.key,
    required this.nurseryId,
    required this.name,
    this.description,
    this.ageGroup,
    this.branchIds = const [],
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  bool get isAllBranches => branchIds.isEmpty;

  factory ProgramModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return ProgramModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      ageGroup: json['ageGroup']?.toString(),
      branchIds: _parseStringList(json['branchIds']),
      isActive: _parseBool(json['isActive']),
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    put('nurseryId', nurseryId);
    put('name', name);
    put('description', description);
    put('ageGroup', ageGroup);
    put('branchIds', branchIds);
    data['isActive'] = isActive;
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  ProgramModel copyWith({
    String? key, String? nurseryId, String? name, String? description,
    String? ageGroup, List<String>? branchIds, bool? isActive,
    int? createdAt, int? updatedAt,
  }) => ProgramModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    name: name ?? this.name, description: description ?? this.description,
    ageGroup: ageGroup ?? this.ageGroup, branchIds: branchIds ?? this.branchIds,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) return v == '1' || v.toLowerCase() == 'true';
    return true;
  }
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static List<String> _parseStringList(dynamic v) {
    if (v is List) {
      return v.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    if (v is Map) {
      return v.values.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }
}

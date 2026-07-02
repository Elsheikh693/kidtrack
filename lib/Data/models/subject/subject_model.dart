class SubjectModel {
  final String? key;
  final String nurseryId;
  final String programId;
  final String name;
  final String? description;
  final String? icon;
  // Empty list = available in all branches; otherwise restricted to these branch ids.
  final List<String> branchIds;
  final int? createdAt;
  final int? updatedAt;

  const SubjectModel({
    this.key,
    required this.nurseryId,
    required this.programId,
    required this.name,
    this.description,
    this.icon,
    this.branchIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  bool get isAllBranches => branchIds.isEmpty;

  factory SubjectModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return SubjectModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      programId: json['programId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      icon: json['icon']?.toString(),
      branchIds: _parseStringList(json['branchIds']),
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    put('nurseryId', nurseryId);
    put('programId', programId);
    put('name', name);
    put('description', description);
    put('icon', icon);
    put('branchIds', branchIds);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  SubjectModel copyWith({
    String? key, String? nurseryId, String? programId, String? name,
    String? description, String? icon, List<String>? branchIds,
    int? createdAt, int? updatedAt,
  }) => SubjectModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    programId: programId ?? this.programId, name: name ?? this.name,
    description: description ?? this.description, icon: icon ?? this.icon,
    branchIds: branchIds ?? this.branchIds,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
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

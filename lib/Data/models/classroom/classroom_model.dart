class ClassroomModel {
  final String? key;
  final String nurseryId;
  // Empty list = available in all branches; otherwise restricted to these branch ids.
  final List<String> branchIds;
  // Program/stage(s) this classroom belongs to (KG1, KG2, Pre, ...).
  // Empty list = generic classroom available under any program.
  final List<String> programIds;
  final String name;
  final String? shift; // 'morning' / 'evening' / 'both'
  final String? teacherId;
  final int? capacity;
  final int? ageGroupMin; // months
  final int? ageGroupMax; // months
  final bool isActive;
  final int? createdAt;
  final int? updatedAt;

  const ClassroomModel({
    this.key,
    required this.nurseryId,
    this.branchIds = const [],
    this.programIds = const [],
    required this.name,
    this.shift,
    this.teacherId,
    this.capacity,
    this.ageGroupMin,
    this.ageGroupMax,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  bool get isAllBranches => branchIds.isEmpty;

  factory ClassroomModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return ClassroomModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      branchIds: _parseBranchIds(json),
      programIds: _parseProgramIds(json),
      name: json['name']?.toString() ?? '',
      shift: json['shift']?.toString(),
      teacherId: json['teacherId']?.toString(),
      capacity: _parseInt(json['capacity']),
      ageGroupMin: _parseInt(json['ageGroupMin']),
      ageGroupMax: _parseInt(json['ageGroupMax']),
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
    put('branchIds', branchIds);
    put('programIds', programIds);
    put('name', name);
    put('shift', shift);
    put('teacherId', teacherId);
    put('capacity', capacity);
    put('ageGroupMin', ageGroupMin);
    put('ageGroupMax', ageGroupMax);
    data['isActive'] = isActive;
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  ClassroomModel copyWith({
    String? key, String? nurseryId, List<String>? branchIds,
    List<String>? programIds,
    String? name, String? shift,
    String? teacherId, int? capacity, int? ageGroupMin, int? ageGroupMax,
    bool? isActive, int? createdAt, int? updatedAt,
  }) => ClassroomModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    branchIds: branchIds ?? this.branchIds,
    programIds: programIds ?? this.programIds,
    name: name ?? this.name,
    shift: shift ?? this.shift,
    teacherId: teacherId ?? this.teacherId, capacity: capacity ?? this.capacity,
    ageGroupMin: ageGroupMin ?? this.ageGroupMin,
    ageGroupMax: ageGroupMax ?? this.ageGroupMax,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  // Reads new `branchIds` list; falls back to legacy single `branchId` so old
  // records (saved before multi-branch support) keep working.
  static List<String> _parseBranchIds(Map<String, dynamic> json) {
    if (json.containsKey('branchIds')) return _parseStringList(json['branchIds']);
    final legacy = json['branchId']?.toString() ?? '';
    return legacy.isEmpty ? const [] : [legacy];
  }

  // Reads new `programIds` list; falls back to legacy single `programId` so old
  // records (saved before multi-program support) keep working.
  static List<String> _parseProgramIds(Map<String, dynamic> json) {
    if (json.containsKey('programIds')) return _parseStringList(json['programIds']);
    final legacy = json['programId']?.toString() ?? '';
    return legacy.isEmpty ? const [] : [legacy];
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
}

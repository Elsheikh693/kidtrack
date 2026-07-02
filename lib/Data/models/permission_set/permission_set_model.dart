class PermissionSetModel {
  final String? key;
  final String employeeId;
  final Map<String, bool> permissions;
  final int? createdAt;
  final int? updatedAt;

  const PermissionSetModel({
    this.key,
    required this.employeeId,
    this.permissions = const {},
    this.createdAt,
    this.updatedAt,
  });

  bool can(String action) => permissions[action] ?? false;

  factory PermissionSetModel.fromJson(Map<String, dynamic> json, {String? key}) {
    final permsRaw = json['permissions'];
    final perms = <String, bool>{};
    if (permsRaw is Map) {
      permsRaw.forEach((k, v) {
        if (v is bool) {
          perms[k.toString()] = v;
        } else if (v is int) {
          perms[k.toString()] = v == 1;
        }
      });
    }
    return PermissionSetModel(
      key: key ?? json['key']?.toString(),
      employeeId: json['employeeId']?.toString() ?? '',
      permissions: perms,
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    data['employeeId'] = employeeId;
    data['permissions'] = permissions;
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  PermissionSetModel copyWith({
    String? key,
    String? employeeId,
    Map<String, bool>? permissions,
    int? createdAt,
    int? updatedAt,
  }) => PermissionSetModel(
    key: key ?? this.key,
    employeeId: employeeId ?? this.employeeId,
    permissions: permissions ?? this.permissions,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

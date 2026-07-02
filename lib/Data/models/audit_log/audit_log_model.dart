class AuditLogModel {
  final String? key;
  final String nurseryId;
  final String actorId;
  final String actorName;
  final String action; // create, update, delete
  final String entity; // child, staff, classroom, etc.
  final String entityId;
  final String? description;
  final int timestamp;

  const AuditLogModel({
    this.key,
    required this.nurseryId,
    required this.actorId,
    required this.actorName,
    required this.action,
    required this.entity,
    required this.entityId,
    this.description,
    required this.timestamp,
  });

  factory AuditLogModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return AuditLogModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      actorId: json['actorId']?.toString() ?? '',
      actorName: json['actorName']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      entity: json['entity']?.toString() ?? '',
      entityId: json['entityId']?.toString() ?? '',
      description: json['description']?.toString(),
      timestamp: _parseInt(json['timestamp']) ?? _now(),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    put('nurseryId', nurseryId);
    put('actorId', actorId);
    put('actorName', actorName);
    put('action', action);
    put('entity', entity);
    put('entityId', entityId);
    put('description', description);
    data['timestamp'] = timestamp;
    return data;
  }

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

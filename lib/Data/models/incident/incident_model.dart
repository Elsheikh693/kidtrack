class IncidentModel {
  final String? key;
  final String nurseryId;
  final String? childId;
  final String branchId;
  final String reportedBy;
  final String type; // injury, behavior, health, other
  final String title;
  final String description;
  final String severity; // low, medium, high
  final int occurredAt;
  final bool parentNotified;
  final String? actionTaken;
  final List<String> images;
  final int? createdAt;
  final int? updatedAt;

  const IncidentModel({
    this.key,
    required this.nurseryId,
    this.childId,
    required this.branchId,
    required this.reportedBy,
    this.type = 'other',
    required this.title,
    required this.description,
    this.severity = 'low',
    required this.occurredAt,
    this.parentNotified = false,
    this.actionTaken,
    this.images = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory IncidentModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return IncidentModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      childId: json['childId']?.toString(),
      branchId: json['branchId']?.toString() ?? '',
      reportedBy: json['reportedBy']?.toString() ?? '',
      type: json['type']?.toString() ?? 'other',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      severity: json['severity']?.toString() ?? 'low',
      occurredAt: _parseInt(json['occurredAt']) ?? _now(),
      parentNotified: _parseBool(json['parentNotified']),
      actionTaken: json['actionTaken']?.toString(),
      images: _parseList(json['images']),
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
    put('branchId', branchId);
    put('reportedBy', reportedBy);
    data['type'] = type;
    data['title'] = title;
    data['description'] = description;
    data['severity'] = severity;
    data['occurredAt'] = occurredAt;
    data['parentNotified'] = parentNotified;
    put('actionTaken', actionTaken);
    if (images.isNotEmpty) data['images'] = images;
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  IncidentModel copyWith({
    String? key, String? nurseryId, String? childId, String? branchId,
    String? reportedBy, String? type, String? title, String? description,
    String? severity, int? occurredAt, bool? parentNotified,
    String? actionTaken, List<String>? images, int? createdAt, int? updatedAt,
  }) => IncidentModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    childId: childId ?? this.childId, branchId: branchId ?? this.branchId,
    reportedBy: reportedBy ?? this.reportedBy, type: type ?? this.type,
    title: title ?? this.title, description: description ?? this.description,
    severity: severity ?? this.severity, occurredAt: occurredAt ?? this.occurredAt,
    parentNotified: parentNotified ?? this.parentNotified,
    actionTaken: actionTaken ?? this.actionTaken,
    images: images ?? this.images,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
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
  static List<String> _parseList(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }
}

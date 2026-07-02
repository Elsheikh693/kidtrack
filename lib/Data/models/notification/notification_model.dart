class NotificationModel {
  final String? key;
  final String userId;
  final String nurseryId;
  final String title;
  final String body;
  final String type; // attendance, announcement, incident, report, finance, general
  final String? entityId;
  final bool isRead;
  final int? createdAt;

  const NotificationModel({
    this.key,
    required this.userId,
    required this.nurseryId,
    required this.title,
    required this.body,
    this.type = 'general',
    this.entityId,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return NotificationModel(
      key: key ?? json['key']?.toString(),
      userId: json['userId']?.toString() ?? '',
      nurseryId: json['nurseryId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      type: json['type']?.toString() ?? 'general',
      entityId: json['entityId']?.toString(),
      isRead: _parseBool(json['isRead']),
      createdAt: _parseInt(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    put('userId', userId);
    put('nurseryId', nurseryId);
    data['title'] = title;
    data['body'] = body;
    data['type'] = type;
    put('entityId', entityId);
    data['isRead'] = isRead;
    put('createdAt', createdAt ?? _now());
    return data;
  }

  NotificationModel copyWith({
    String? key, String? userId, String? nurseryId, String? title,
    String? body, String? type, String? entityId, bool? isRead, int? createdAt,
  }) => NotificationModel(
    key: key ?? this.key, userId: userId ?? this.userId,
    nurseryId: nurseryId ?? this.nurseryId, title: title ?? this.title,
    body: body ?? this.body, type: type ?? this.type,
    entityId: entityId ?? this.entityId, isRead: isRead ?? this.isRead,
    createdAt: createdAt ?? this.createdAt,
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

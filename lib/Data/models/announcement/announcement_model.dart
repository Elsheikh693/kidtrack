class AnnouncementModel {
  final String? key;
  final String nurseryId;
  final String? branchId; // null = all branches
  final String postedBy;
  final String title;
  final String content;
  final String targetRole; // all, guardians, staff, teachers
  final String? imageUrl;
  final int? expiresAt;
  final int? createdAt;
  final int? updatedAt;

  const AnnouncementModel({
    this.key,
    required this.nurseryId,
    this.branchId,
    required this.postedBy,
    required this.title,
    required this.content,
    this.targetRole = 'all',
    this.imageUrl,
    this.expiresAt,
    this.createdAt,
    this.updatedAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return AnnouncementModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      branchId: json['branchId']?.toString(),
      postedBy: json['postedBy']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      targetRole: json['targetRole']?.toString() ?? 'all',
      imageUrl: json['imageUrl']?.toString(),
      expiresAt: _parseInt(json['expiresAt']),
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    put('nurseryId', nurseryId);
    put('branchId', branchId);
    put('postedBy', postedBy);
    data['title'] = title;
    data['content'] = content;
    data['targetRole'] = targetRole;
    put('imageUrl', imageUrl);
    put('expiresAt', expiresAt);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  AnnouncementModel copyWith({
    String? key, String? nurseryId, String? branchId, String? postedBy,
    String? title, String? content, String? targetRole, String? imageUrl,
    int? expiresAt, int? createdAt, int? updatedAt,
  }) => AnnouncementModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    branchId: branchId ?? this.branchId, postedBy: postedBy ?? this.postedBy,
    title: title ?? this.title, content: content ?? this.content,
    targetRole: targetRole ?? this.targetRole, imageUrl: imageUrl ?? this.imageUrl,
    expiresAt: expiresAt ?? this.expiresAt,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

class ParentModel {
  final String? key;
  final String uid;
  final String name;
  final String? phone;
  final String? email;
  final String? profileImage;
  final String? fcmToken;
  final bool isActive;

  // ── Engagement telemetry (seeded now, surfaced in a later phase) ───────────
  // Planted in Phase 1 with NO UI on purpose: engagement history can't be
  // backfilled, so we start logging from day one. lastActiveAt/loginCount are
  // written on login; activityViews/feedViews increment when the parent opens
  // their child's activities / the feed.
  final int? lastActiveAt;
  final int loginCount;
  final int activityViews;
  final int feedViews;

  final int? createdAt;
  final int? updatedAt;

  const ParentModel({
    this.key,
    required this.uid,
    required this.name,
    this.phone,
    this.email,
    this.profileImage,
    this.fcmToken,
    this.isActive = true,
    this.lastActiveAt,
    this.loginCount = 0,
    this.activityViews = 0,
    this.feedViews = 0,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasImage => profileImage != null && profileImage!.isNotEmpty;

  factory ParentModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return ParentModel(
      key: key ?? json['key']?.toString(),
      uid: json['uid']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      profileImage: json['profileImage']?.toString(),
      fcmToken: json['fcmToken']?.toString(),
      isActive: _parseBool(json['isActive']),
      lastActiveAt: _parseInt(json['lastActiveAt']),
      loginCount: _parseInt(json['loginCount']) ?? 0,
      activityViews: _parseInt(json['activityViews']) ?? 0,
      feedViews: _parseInt(json['feedViews']) ?? 0,
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    put('uid', uid);
    put('name', name);
    put('phone', phone);
    put('email', email);
    put('profileImage', profileImage);
    put('fcmToken', fcmToken);
    data['isActive'] = isActive;
    put('lastActiveAt', lastActiveAt);
    data['loginCount'] = loginCount;
    data['activityViews'] = activityViews;
    data['feedViews'] = feedViews;
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  ParentModel copyWith({
    String? key, String? uid, String? name, String? phone, String? email,
    String? profileImage, String? fcmToken, bool? isActive,
    int? lastActiveAt, int? loginCount, int? activityViews, int? feedViews,
    int? createdAt, int? updatedAt,
  }) => ParentModel(
    key: key ?? this.key, uid: uid ?? this.uid, name: name ?? this.name,
    phone: phone ?? this.phone, email: email ?? this.email,
    profileImage: profileImage ?? this.profileImage,
    fcmToken: fcmToken ?? this.fcmToken, isActive: isActive ?? this.isActive,
    lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    loginCount: loginCount ?? this.loginCount,
    activityViews: activityViews ?? this.activityViews,
    feedViews: feedViews ?? this.feedViews,
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
}

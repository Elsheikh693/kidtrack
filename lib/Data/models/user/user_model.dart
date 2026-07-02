import 'user_type.dart';

class UserModel {
  final String? uid;
  final String? guestId; // UUID local — for guest users
  final bool isGuest;
  final String? name;
  final String? phone;
  final String? email;
  final String? fcmToken; // guest + logged in
  final String? authToken; // Firebase Auth token
  final int? createdAt;
  final int? updatedAt;

  // kept for backward compat — not in new spec but used internally
  final String? profileImage;
  final UserType? userType;

  final double? lat;
  final double? lng;

  const UserModel({
    this.uid,
    this.guestId,
    this.isGuest = false,
    this.name,
    this.phone,
    this.email,
    this.fcmToken,
    this.authToken,
    this.createdAt,
    this.updatedAt,
    this.profileImage,
    this.userType,
    this.lat,
    this.lng,
  });

  // ─── Helpers ──────────────────────────────────────────────────────────────

  static int nowMillis() => DateTime.now().millisecondsSinceEpoch;

  bool get isLoggedIn => !isGuest && uid != null;

  bool get hasImage => profileImage != null && profileImage!.isNotEmpty;

  bool get hasPhone => phone != null && phone!.isNotEmpty;

  bool get hasName => name != null && name!.isNotEmpty;

  bool get isParentRole => userType == UserType.parent;
  bool get isSuperAdmin => userType == UserType.superAdmin;
  bool get isOwner => userType == UserType.owner;
  bool get isStaffRole => userType?.isStaffRole ?? false;

  String get displayName => name ?? 'Guest';

  String get identifier => uid ?? guestId ?? '';

  // ─── From JSON ────────────────────────────────────────────────────────────

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid']?.toString(),
      guestId: json['guestId']?.toString(),
      isGuest: _parseBool(json['isGuest']),
      name: json['name']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      fcmToken: json['fcmToken']?.toString() ?? json['fcm_token']?.toString(),
      authToken: json['authToken']?.toString(),

      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
      profileImage:
          json['profileImage']?.toString() ?? json['profile_image']?.toString(),
      userType: UserTypeExtension.fromString(json['userType']?.toString()),
      lat: _parseDouble(json['lat']),
      lng: _parseDouble(json['lng']),
    );
  }

  // ─── To JSON ──────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson({bool isUpdate = false}) {
    final data = <String, dynamic>{};

    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('uid', uid);
    put('guestId', guestId);
    put('isGuest', isGuest);
    put('name', name);
    put('phone', phone);
    put('email', email);
    put('fcmToken', fcmToken);
    put('profileImage', profileImage);
    put('userType', userType?.name);
    put('lat', lat);
    put('lng', lng);

    if (!isUpdate) {
      put('createdAt', createdAt ?? nowMillis());
    } else {
      put('createdAt', createdAt);
    }
    put('updatedAt', nowMillis());

    return data;
  }

  // ─── Copy With ────────────────────────────────────────────────────────────

  UserModel copyWith({
    String? uid,
    String? guestId,
    bool? isGuest,
    String? name,
    String? phone,
    String? email,
    String? fcmToken,
    String? authToken,
    int? createdAt,
    int? updatedAt,
    String? profileImage,
    UserType? userType,
    double? lat,
    double? lng,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      guestId: guestId ?? this.guestId,
      isGuest: isGuest ?? this.isGuest,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      fcmToken: fcmToken ?? this.fcmToken,
      authToken: authToken ?? this.authToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImage: profileImage ?? this.profileImage,
      userType: userType ?? this.userType,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  // ─── Private Parsers ──────────────────────────────────────────────────────

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

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

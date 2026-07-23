import 'staff_template.dart';
import '../user/user_type.dart';

class StaffModel {
  final String? key;
  final String uid;
  final String nurseryId;
  final String? branchId;
  final List<String> shiftIds; // ShiftModel keys — empty = works all shifts
  final String? classroomId;
  final List<String> subjectIds;
  final String name;
  final String? phone;
  final String? email;
  final String? profileImage;
  final UserType role;
  final StaffTemplate template;
  final bool isActive;
  final String? fcmToken;
  // ── Workforce / HR-lite fields ──────────────────────────────────────────────
  final double? salary;
  final int? hireDate; // epoch ms
  final String? nationalId;
  final String? address;
  final String? emergencyPhone;
  final int? createdAt;
  final int? updatedAt;

  const StaffModel({
    this.key,
    required this.uid,
    required this.nurseryId,
    this.branchId,
    this.shiftIds = const [],
    this.classroomId,
    this.subjectIds = const [],
    required this.name,
    this.phone,
    this.email,
    this.profileImage,
    this.role = UserType.teacher,
    this.template = StaffTemplate.teacher,
    this.isActive = true,
    this.fcmToken,
    this.salary,
    this.hireDate,
    this.nationalId,
    this.address,
    this.emergencyPhone,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasImage => profileImage != null && profileImage!.isNotEmpty;

  factory StaffModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return StaffModel(
      key: key ?? json['key']?.toString(),
      uid: json['uid']?.toString() ?? '',
      nurseryId: json['nurseryId']?.toString() ?? '',
      branchId: json['branchId']?.toString(),
      shiftIds: _parseShiftIds(json),
      classroomId: json['classroomId']?.toString(),
      subjectIds: _parseStringList(json['subjectIds']),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      profileImage: json['profileImage']?.toString(),
      role: UserTypeExtension.fromString(json['role']?.toString()),
      template: StaffTemplateExtension.fromString(json['template']?.toString()),
      isActive: _parseBool(json['isActive']),
      fcmToken: json['fcmToken']?.toString(),
      salary: _parseDouble(json['salary']),
      hireDate: _parseInt(json['hireDate']),
      nationalId: json['nationalId']?.toString(),
      address: json['address']?.toString(),
      emergencyPhone: json['emergencyPhone']?.toString(),
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    put('uid', uid);
    put('nurseryId', nurseryId);
    put('branchId', branchId);
    data['shiftIds'] = shiftIds;
    put('classroomId', classroomId);
    if (subjectIds.isNotEmpty) data['subjectIds'] = subjectIds;
    put('name', name);
    put('phone', phone);
    put('email', email);
    put('profileImage', profileImage);
    data['role'] = role.name;
    data['template'] = template.name;
    data['isActive'] = isActive;
    put('fcmToken', fcmToken);
    put('salary', salary);
    put('hireDate', hireDate);
    put('nationalId', nationalId);
    put('address', address);
    put('emergencyPhone', emergencyPhone);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  StaffModel copyWith({
    String? key, String? uid, String? nurseryId, String? branchId,
    List<String>? shiftIds,
    String? classroomId, List<String>? subjectIds, String? name, String? phone,
    String? email, String? profileImage, UserType? role, StaffTemplate? template,
    bool? isActive, String? fcmToken, double? salary, int? hireDate,
    String? nationalId, String? address, String? emergencyPhone,
    int? createdAt, int? updatedAt,
  }) => StaffModel(
    key: key ?? this.key, uid: uid ?? this.uid,
    nurseryId: nurseryId ?? this.nurseryId, branchId: branchId ?? this.branchId,
    shiftIds: shiftIds ?? this.shiftIds,
    classroomId: classroomId ?? this.classroomId,
    subjectIds: subjectIds ?? this.subjectIds,
    name: name ?? this.name,
    phone: phone ?? this.phone, email: email ?? this.email,
    profileImage: profileImage ?? this.profileImage,
    role: role ?? this.role, template: template ?? this.template,
    isActive: isActive ?? this.isActive, fcmToken: fcmToken ?? this.fcmToken,
    salary: salary ?? this.salary, hireDate: hireDate ?? this.hireDate,
    nationalId: nationalId ?? this.nationalId, address: address ?? this.address,
    emergencyPhone: emergencyPhone ?? this.emergencyPhone,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static List<String> _parseStringList(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    if (v is Map) return v.values.map((e) => e.toString()).toList();
    return [];
  }

  /// Reads the multi-shift list, migrating legacy single-string `shift` records
  /// ('morning'/'evening'/'between' → one-element list; 'both'/null → empty =
  /// works every shift) so old staff keep resolving.
  static List<String> _parseShiftIds(Map<String, dynamic> json) {
    final ids = _parseStringList(json['shiftIds']);
    if (ids.isNotEmpty) return ids;
    final legacy = json['shift']?.toString();
    if (legacy == null || legacy.isEmpty || legacy == 'both') return const [];
    return [legacy];
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
  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

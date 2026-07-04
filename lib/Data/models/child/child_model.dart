class ChildModel {
  final String? key;
  final String nurseryId;
  final String branchId;
  final String? classroomId;
  final String firstName;
  final String lastName;
  final String? profileImage;
  final String? gender; // male, female
  final int? dateOfBirth;
  final String? bloodType;
  final String? nationality;
  final String status; // active, inactive, withdrawn
  final String? shift; // morning, evening
  final String? parentId;
  final String? programId; // enrolled program/stage (KG1, KG2, Pre, ...)
  final String? packageId; // subscribed fee package; drives monthly billing
  final double? homeLat;
  final double? homeLng;
  final String? homeAddress;
  final String? busChaperoneId; // staff uid of the assigned bus chaperone
  final String? withdrawnReason; // why the child left (preset label + optional note)
  final int? withdrawnAt; // when the child was marked withdrawn (ms since epoch)
  final int? createdAt;
  final int? updatedAt;

  const ChildModel({
    this.key,
    required this.nurseryId,
    required this.branchId,
    this.classroomId,
    required this.firstName,
    required this.lastName,
    this.profileImage,
    this.gender,
    this.dateOfBirth,
    this.bloodType,
    this.nationality,
    this.status = 'active',
    this.shift,
    this.parentId,
    this.programId,
    this.packageId,
    this.homeLat,
    this.homeLng,
    this.homeAddress,
    this.busChaperoneId,
    this.withdrawnReason,
    this.withdrawnAt,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasHomeLocation => homeLat != null && homeLng != null;

  String get fullName => '$firstName $lastName';
  bool get hasImage => profileImage != null && profileImage!.isNotEmpty;
  bool get isWithdrawn => status == 'withdrawn';

  factory ChildModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return ChildModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      classroomId: json['classroomId']?.toString(),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      profileImage: json['profileImage']?.toString(),
      gender: json['gender']?.toString(),
      dateOfBirth: _parseInt(json['dateOfBirth']),
      bloodType: json['bloodType']?.toString(),
      nationality: json['nationality']?.toString(),
      status: json['status']?.toString() ?? 'active',
      shift: json['shift']?.toString(),
      parentId: json['parentId']?.toString(),
      programId: json['programId']?.toString(),
      packageId: json['packageId']?.toString(),
      homeLat: _parseDouble(json['homeLat']),
      homeLng: _parseDouble(json['homeLng']),
      homeAddress: json['homeAddress']?.toString(),
      busChaperoneId: json['busChaperoneId']?.toString(),
      withdrawnReason: json['withdrawnReason']?.toString(),
      withdrawnAt: _parseInt(json['withdrawnAt']),
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
    put('classroomId', classroomId);
    put('firstName', firstName);
    put('lastName', lastName);
    put('profileImage', profileImage);
    put('gender', gender);
    put('dateOfBirth', dateOfBirth);
    put('bloodType', bloodType);
    put('nationality', nationality);
    data['status'] = status;
    put('shift', shift);
    put('parentId', parentId);
    put('programId', programId);
    put('packageId', packageId);
    put('homeLat', homeLat);
    put('homeLng', homeLng);
    put('homeAddress', homeAddress);
    put('busChaperoneId', busChaperoneId);
    put('withdrawnReason', withdrawnReason);
    put('withdrawnAt', withdrawnAt);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  ChildModel copyWith({
    String? key, String? nurseryId, String? branchId, String? classroomId,
    String? firstName, String? lastName, String? profileImage, String? gender,
    int? dateOfBirth, String? bloodType, String? nationality, String? status,
    String? shift, String? parentId, String? programId, bool clearProgram = false,
    String? packageId, bool clearPackage = false,
    double? homeLat, double? homeLng, String? homeAddress,
    String? busChaperoneId, bool clearBusChaperone = false,
    String? withdrawnReason, int? withdrawnAt, bool clearWithdrawal = false,
    int? createdAt, int? updatedAt,
  }) => ChildModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    branchId: branchId ?? this.branchId, classroomId: classroomId ?? this.classroomId,
    firstName: firstName ?? this.firstName, lastName: lastName ?? this.lastName,
    profileImage: profileImage ?? this.profileImage, gender: gender ?? this.gender,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth, bloodType: bloodType ?? this.bloodType,
    nationality: nationality ?? this.nationality, status: status ?? this.status,
    shift: shift ?? this.shift,
    parentId: parentId ?? this.parentId,
    programId: clearProgram ? null : (programId ?? this.programId),
    packageId: clearPackage ? null : (packageId ?? this.packageId),
    homeLat: homeLat ?? this.homeLat, homeLng: homeLng ?? this.homeLng,
    homeAddress: homeAddress ?? this.homeAddress,
    busChaperoneId: clearBusChaperone ? null : (busChaperoneId ?? this.busChaperoneId),
    withdrawnReason: clearWithdrawal ? null : (withdrawnReason ?? this.withdrawnReason),
    withdrawnAt: clearWithdrawal ? null : (withdrawnAt ?? this.withdrawnAt),
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
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

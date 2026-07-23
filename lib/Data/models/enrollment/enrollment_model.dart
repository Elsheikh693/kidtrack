import '../core/branch_scoped.dart';

class EnrollmentModel implements BranchScoped {
  @override
  List<String> get scopeBranches => branchId.isEmpty ? const [] : [branchId];

  final String? key;
  final String nurseryId;
  final String childId;
  final String branchId;
  final String? classroomId;
  final String? programId;
  final String? packageId;
  final int? enrollmentDate;
  final int? startDate;
  final int? endDate;
  final String status; // enrolled, withdrawn, graduated, pending
  final int? createdAt;
  final int? updatedAt;

  const EnrollmentModel({
    this.key,
    required this.nurseryId,
    required this.childId,
    required this.branchId,
    this.classroomId,
    this.programId,
    this.packageId,
    this.enrollmentDate,
    this.startDate,
    this.endDate,
    this.status = 'enrolled',
    this.createdAt,
    this.updatedAt,
  });

  factory EnrollmentModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return EnrollmentModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      classroomId: json['classroomId']?.toString(),
      programId: json['programId']?.toString(),
      packageId: json['packageId']?.toString(),
      enrollmentDate: _parseInt(json['enrollmentDate']),
      startDate: _parseInt(json['startDate']),
      endDate: _parseInt(json['endDate']),
      status: json['status']?.toString() ?? 'enrolled',
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
    put('classroomId', classroomId);
    put('programId', programId);
    put('packageId', packageId);
    put('enrollmentDate', enrollmentDate);
    put('startDate', startDate);
    put('endDate', endDate);
    data['status'] = status;
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  EnrollmentModel copyWith({
    String? key, String? nurseryId, String? childId, String? branchId,
    String? classroomId, String? programId, String? packageId,
    int? enrollmentDate, int? startDate, int? endDate,
    String? status, int? createdAt, int? updatedAt,
  }) => EnrollmentModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    childId: childId ?? this.childId, branchId: branchId ?? this.branchId,
    classroomId: classroomId ?? this.classroomId, programId: programId ?? this.programId,
    packageId: packageId ?? this.packageId,
    enrollmentDate: enrollmentDate ?? this.enrollmentDate,
    startDate: startDate ?? this.startDate, endDate: endDate ?? this.endDate,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

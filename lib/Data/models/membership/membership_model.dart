import '../user/user_type.dart';

/// One (role × nursery × branch) that a single identity (uid) holds.
///
/// The platform models identity as ONE account per phone, but a person can wear
/// several hats: a teacher who is also a mum (teacher + parent in the same
/// nursery), or a teacher working shifts at two nurseries (teacher at A + teacher
/// at B). Each hat is a membership, stored at
/// `users/{uid}/memberships/{nurseryId}_{role}` and read at login to decide which
/// membership the session wears (see the membership picker).
class MembershipModel {
  /// [UserType.name] — parent | teacher | branchManager | receptionist | ...
  final String role;
  final String nurseryId;
  final String? branchId;
  final int? createdAt;

  const MembershipModel({
    required this.role,
    required this.nurseryId,
    this.branchId,
    this.createdAt,
  });

  /// Stable, idempotent key: re-adding the same role at the same nursery
  /// overwrites the entry instead of duplicating it.
  String get id => '${nurseryId}_$role';

  UserType? get userType => UserTypeExtension.fromString(role);

  factory MembershipModel.fromJson(Map<String, dynamic> json) => MembershipModel(
        role: json['role']?.toString() ?? '',
        nurseryId: json['nurseryId']?.toString() ?? '',
        branchId: json['branchId']?.toString(),
        createdAt: _parseInt(json['createdAt']),
      );

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'role': role,
      'nurseryId': nurseryId,
      'createdAt': createdAt ?? DateTime.now().millisecondsSinceEpoch,
    };
    if (branchId != null && branchId!.isNotEmpty) data['branchId'] = branchId;
    return data;
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

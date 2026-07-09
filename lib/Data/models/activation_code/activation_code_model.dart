/// A role-agnostic account-activation credential — the single primitive that
/// provisions EVERY account in the platform (parent, reception, teacher,
/// manager, owner). One code activates one account and stays valid as a durable
/// login key until the creator regenerates it.
///
/// Stored at a GLOBAL root path (`activationCodes/{code}`, the code IS the key)
/// because it is resolved BEFORE login — before the nursery/session is known.
///
/// Deliberately minimal: no `expiresAt` / `deviceLimit` / policy fields. Those
/// are per-role business rules layered on later, NOT part of the engine.
class ActivationCodeModel {
  final String? key;
  final String code;

  /// parent | reception | teacher | manager | owner — drives the activation
  /// bundle and the session scope granted on activation.
  final String role;

  /// uid of the account this code activates.
  final String targetId;

  final String nurseryId;

  /// uid of whoever generated the code (SuperAdmin, Owner, Reception, ...).
  final String createdBy;

  final int? createdAt;

  /// Telemetry only ("has been used at least once", for the onboarding funnel).
  /// Does NOT disable the code — the code stays usable until [regenerate].
  final bool isActivated;

  const ActivationCodeModel({
    this.key,
    required this.code,
    required this.role,
    required this.targetId,
    required this.nurseryId,
    required this.createdBy,
    this.createdAt,
    this.isActivated = false,
  });

  factory ActivationCodeModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return ActivationCodeModel(
      key: key ?? json['key']?.toString() ?? json['code']?.toString(),
      code: json['code']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      targetId: json['targetId']?.toString() ?? '',
      nurseryId: json['nurseryId']?.toString() ?? '',
      createdBy: json['createdBy']?.toString() ?? '',
      createdAt: _parseInt(json['createdAt']),
      isActivated: _parseBool(json['isActivated']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('code', code);
    put('role', role);
    put('targetId', targetId);
    put('nurseryId', nurseryId);
    put('createdBy', createdBy);
    put('createdAt', createdAt ?? _now());
    data['isActivated'] = isActivated;
    return data;
  }

  ActivationCodeModel copyWith({
    String? key, String? code, String? role, String? targetId,
    String? nurseryId, String? createdBy, int? createdAt, bool? isActivated,
  }) => ActivationCodeModel(
    key: key ?? this.key,
    code: code ?? this.code,
    role: role ?? this.role,
    targetId: targetId ?? this.targetId,
    nurseryId: nurseryId ?? this.nurseryId,
    createdBy: createdBy ?? this.createdBy,
    createdAt: createdAt ?? this.createdAt,
    isActivated: isActivated ?? this.isActivated,
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

import 'package:flutter/material.dart';

/// A direct-contact number the nursery exposes to parents (reception, the
/// manager, finance, …). Managed by the owner/manager, shown to parents behind
/// the WhatsApp icon in the parent app bar.
///
/// Firebase: `platform/{nurseryId}/nurseryContacts/{key}`
class NurseryContactModel {
  final String? key;
  final String nurseryId;

  /// Display label, e.g. "الاستقبال" or "أ. منى - المديرة".
  final String name;

  /// Phone number (any format — cleaned before launching wa.me).
  final String phone;

  /// One of [roleKeys] — drives the icon/color and a default subtitle label.
  final String roleKey;

  /// Manual sort order (lower first).
  final int order;

  final int? createdAt;

  const NurseryContactModel({
    this.key,
    required this.nurseryId,
    required this.name,
    required this.phone,
    this.roleKey = 'general',
    this.order = 0,
    this.createdAt,
  });

  factory NurseryContactModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return NurseryContactModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      roleKey: json['roleKey']?.toString() ?? 'general',
      order: _parseInt(json['order']) ?? 0,
      createdAt: _parseInt(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('key', key);
    put('nurseryId', nurseryId);
    data['name'] = name;
    data['phone'] = phone;
    data['roleKey'] = roleKey;
    data['order'] = order;
    put('createdAt', createdAt ?? _now());
    return data;
  }

  NurseryContactModel copyWith({
    String? key,
    String? nurseryId,
    String? name,
    String? phone,
    String? roleKey,
    int? order,
    int? createdAt,
  }) =>
      NurseryContactModel(
        key: key ?? this.key,
        nurseryId: nurseryId ?? this.nurseryId,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        roleKey: roleKey ?? this.roleKey,
        order: order ?? this.order,
        createdAt: createdAt ?? this.createdAt,
      );

  // ─── Role meta (shared by owner CRUD + parent sheet) ──────────────────────
  static const List<String> roleKeys = [
    'emergency',
    'reception',
    'management',
    'finance',
    'support',
    'general',
  ];

  /// Localization key for the role label, e.g. `nursery_contact_role_reception`.
  static String roleLabelKey(String roleKey) => 'nursery_contact_role_$roleKey';

  String get roleLabelTrKey => roleLabelKey(roleKey);

  IconData get icon => roleIcon(roleKey);
  int get colorValue => roleColor(roleKey);

  static IconData roleIcon(String roleKey) => switch (roleKey) {
        'emergency' => Icons.emergency_rounded,
        'reception' => Icons.support_agent_rounded,
        'management' => Icons.workspace_premium_rounded,
        'finance' => Icons.account_balance_wallet_rounded,
        'support' => Icons.headset_mic_rounded,
        _ => Icons.phone_in_talk_rounded,
      };

  static int roleColor(String roleKey) => switch (roleKey) {
        'emergency' => 0xFFDC2626,
        'reception' => 0xFF2563EB,
        'management' => 0xFF7C3AED,
        'finance' => 0xFFD97706,
        'support' => 0xFF0D9488,
        _ => 0xFF64748B,
      };

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

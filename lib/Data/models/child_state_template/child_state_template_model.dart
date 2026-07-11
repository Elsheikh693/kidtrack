// Firebase path: platform/{nurseryId}/childStateTemplates/{id}
// Owner-defined states for tracking what a child is doing (sleeping, eating, etc.)
// 'with_classroom' is the system default — not stored here.

import 'child_state_option.dart';

const kDefaultStateId = 'with_classroom';

class ChildStateTemplateModel {
  final String? key;
  final String nurseryId;
  final String title;
  final String icon;
  final bool isActive;
  final int createdAt;

  // Optional classification tree (2 levels). Empty = simple state, no evaluation.
  final List<ChildStateOption> options;

  const ChildStateTemplateModel({
    this.key,
    required this.nurseryId,
    required this.title,
    required this.icon,
    this.isActive = true,
    required this.createdAt,
    this.options = const [],
  });

  factory ChildStateTemplateModel.fromJson(
    Map<String, dynamic> json, {
    String? key,
  }) {
    return ChildStateTemplateModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      isActive: json['isActive'] != false,
      createdAt: _parseInt(json['createdAt']) ?? 0,
      options: _parseOptions(json['options']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('key', key);
    data['nurseryId'] = nurseryId;
    data['title'] = title;
    data['icon'] = icon;
    data['isActive'] = isActive;
    data['createdAt'] = createdAt;
    if (options.isNotEmpty) {
      data['options'] = options.map((o) => o.toJson()).toList();
    }
    return data;
  }

  ChildStateTemplateModel copyWith({
    String? key,
    String? title,
    String? icon,
    bool? isActive,
    List<ChildStateOption>? options,
  }) {
    return ChildStateTemplateModel(
      key: key ?? this.key,
      nurseryId: nurseryId,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      options: options ?? this.options,
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  // RTDB returns a list either as a List (sequential keys) or a Map.
  static List<ChildStateOption> _parseOptions(dynamic raw) {
    Iterable<dynamic>? values;
    if (raw is List) {
      values = raw;
    } else if (raw is Map) {
      values = raw.values;
    }
    if (values == null) return const [];
    return values
        .whereType<Map>()
        .map((m) => ChildStateOption.fromJson(Map<String, dynamic>.from(m)))
        .where((o) => o.label.isNotEmpty)
        .toList();
  }
}

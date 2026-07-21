// Firebase path: platform/{nurseryId}/childStateTemplates/{id}
// Owner-defined states for tracking what a child is doing (sleeping, eating, etc.)
// 'with_classroom' is the system default — not stored here.

import 'child_state_option.dart';

const kDefaultStateId = 'with_classroom';

// A template is either a persistent STATUS (sticky — becomes the child's current
// state until it ends, e.g. sleeping) or an instant EVENT (logged to the day's
// timeline and does NOT change the current state, e.g. toilet / ate). Old records
// saved before this split default to `status` so their behaviour never changes.
const kStateKindStatus = 'status';
const kStateKindEvent = 'event';

class ChildStateTemplateModel {
  final String? key;
  final String nurseryId;
  final String title;
  final String icon;
  final bool isActive;
  final int createdAt;

  // 'status' (persistent) or 'event' (instant). See constants above.
  final String kind;

  // Optional classification tree (2 levels). Empty = simple state, no evaluation.
  final List<ChildStateOption> options;

  const ChildStateTemplateModel({
    this.key,
    required this.nurseryId,
    required this.title,
    required this.icon,
    this.isActive = true,
    required this.createdAt,
    this.kind = kStateKindStatus,
    this.options = const [],
  });

  bool get isEvent => kind == kStateKindEvent;
  bool get isStatus => !isEvent;

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
      kind: _resolveKind(json['kind'], key ?? json['key']?.toString()),
      options: _parseOptions(json['options']),
    );
  }

  // Seed keys that are instant EVENTS by default (see [ChildStateDefaults]).
  static const _seedEventKeys = {'eat', 'toilet'};

  // Resolve the kind: honour an explicit value; otherwise (legacy records saved
  // before the status/event split) infer from the seed key so nurseries that
  // never re-classified still behave right — eat/toilet are instant events,
  // everything else stays a persistent status.
  static String _resolveKind(dynamic raw, String? key) {
    final k = raw?.toString();
    if (k == kStateKindEvent) return kStateKindEvent;
    if (k == kStateKindStatus) return kStateKindStatus;
    return _seedEventKeys.contains(key) ? kStateKindEvent : kStateKindStatus;
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
    data['kind'] = kind;
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
    String? kind,
    List<ChildStateOption>? options,
  }) {
    return ChildStateTemplateModel(
      key: key ?? this.key,
      nurseryId: nurseryId,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      kind: kind ?? this.kind,
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

/// The states seeded the first time the child-states settings screen is opened
/// (when the nursery has none yet). Titles/option labels are localization keys
/// resolved to the active locale at seed time; the owner can edit or delete
/// them afterwards. `الأكل` ships with its evaluation tree (أكل → الكل/النص/الربع,
/// لم يأكل); `النوم` and `الحمام` stay simple.
class ChildStateDefaults {
  ChildStateDefaults._();

  static const List<
      ({
        String key,
        String titleKey,
        String icon,
        String kind,
        List<({String labelKey, List<String> subLabelKeys})> options,
      })> seed = [
    (
      key: 'eat',
      titleKey: 'child_state_default_eat',
      icon: 'food',
      kind: kStateKindEvent,
      options: [
        (
          labelKey: 'child_state_default_eat_ate',
          subLabelKeys: [
            'child_state_default_eat_all',
            'child_state_default_eat_half',
            'child_state_default_eat_quarter',
          ],
        ),
        (labelKey: 'child_state_default_eat_none', subLabelKeys: []),
      ],
    ),
    (
      key: 'sleep',
      titleKey: 'child_state_default_sleep',
      icon: 'sleep',
      kind: kStateKindStatus,
      options: [],
    ),
    (
      key: 'toilet',
      titleKey: 'child_state_default_toilet',
      icon: 'toilet',
      kind: kStateKindEvent,
      options: [],
    ),
  ];
}

// Firebase path: platform/{nurseryId}/assessmentTemplates/{id}
//
// The REUSABLE plan for an assessment (quiz / observation / evaluation). It is
// nursery-wide ON PURPOSE — NOT branch/classroom bound — so one template
// ("حرف الألف") can be run for any classroom in any branch at any time. Branch,
// classroom, teacher and dates are chosen later, on the AssessmentRun.
//
// Deliberately NOT a `BranchScoped` — templates are visible to every branch.
//
// [type] labels the flavour (weekly quiz / monthly / observation / …) purely for
// display and filtering; the engine treats them identically. [scale] and
// [items] are snapshotted onto each Run at creation time.

import 'assessment_item.dart';
import 'assessment_scale.dart';

class AssessmentTemplateModel {
  final String? key;
  final String nurseryId;
  final String title;
  final String? subject;
  final String? instructions;

  /// Free-form label: 'weekly_quiz' | 'monthly' | 'observation' | 'final' | …
  final String? type;

  final AssessmentScale scale;
  final List<AssessmentItem> items;

  final bool isActive;
  final String createdBy;
  final int? createdAt;
  final int? updatedAt;

  const AssessmentTemplateModel({
    this.key,
    required this.nurseryId,
    required this.title,
    this.subject,
    this.instructions,
    this.type,
    this.scale = const AssessmentScale(),
    this.items = const [],
    this.isActive = true,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  factory AssessmentTemplateModel.fromJson(
    Map<dynamic, dynamic> json, {
    String? key,
  }) {
    return AssessmentTemplateModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subject: json['subject']?.toString(),
      instructions: json['instructions']?.toString(),
      type: json['type']?.toString(),
      scale: _parseScale(json['scale']),
      items: _parseItems(json['items']),
      isActive: json['isActive'] != false,
      createdBy: json['createdBy']?.toString() ?? '',
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
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
    put('subject', subject);
    put('instructions', instructions);
    put('type', type);
    data['scale'] = scale.toJson();
    data['items'] = items.map((i) => i.toJson()).toList();
    data['isActive'] = isActive;
    data['createdBy'] = createdBy;
    data['createdAt'] = createdAt ?? _now();
    data['updatedAt'] = _now();
    return data;
  }

  AssessmentTemplateModel copyWith({
    String? key,
    String? nurseryId,
    String? title,
    String? subject,
    String? instructions,
    String? type,
    AssessmentScale? scale,
    List<AssessmentItem>? items,
    bool? isActive,
    String? createdBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return AssessmentTemplateModel(
      key: key ?? this.key,
      nurseryId: nurseryId ?? this.nurseryId,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      instructions: instructions ?? this.instructions,
      type: type ?? this.type,
      scale: scale ?? this.scale,
      items: items ?? this.items,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static AssessmentScale _parseScale(dynamic raw) {
    if (raw is Map) return AssessmentScale.fromJson(Map<String, dynamic>.from(raw));
    return const AssessmentScale();
  }

  static List<AssessmentItem> _parseItems(dynamic raw) {
    Iterable<dynamic>? values;
    if (raw is List) {
      values = raw;
    } else if (raw is Map) {
      values = raw.values;
    }
    if (values == null) return const [];
    final list = values
        .whereType<Map>()
        .map((m) => AssessmentItem.fromJson(Map<String, dynamic>.from(m)))
        .where((i) => i.id.isNotEmpty)
        .toList();
    list.sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }
}

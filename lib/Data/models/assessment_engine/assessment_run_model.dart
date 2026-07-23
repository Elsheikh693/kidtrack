// Firebase path: platform/{nurseryId}/assessmentRuns/{id}
//
// A concrete EXECUTION of an AssessmentTemplate on a specific branch + classes
// over a date window. It carries a FULL SNAPSHOT of the template (title,
// subject, instructions, scale, items) taken at creation time — so editing (or
// deleting) the template afterwards never changes what this run meant.
//
// `BranchScoped`: a run belongs to exactly one branch, so the central branch
// filter in BaseService.getData hides other branches' runs from branch-bound
// staff automatically.
//
// The run's own [status] is intentionally simple (draft → active → completed);
// the real per-child workflow lives on ChildAssessment. Progress ("28/32") is
// computed at runtime from the child rows, never stored here.

import '../core/branch_scoped.dart';
import 'assessment_enums.dart';
import 'assessment_item.dart';
import 'assessment_scale.dart';

class AssessmentRunModel implements BranchScoped {
  @override
  List<String> get scopeBranches => branchId.isEmpty ? const [] : [branchId];

  final String? key;
  final String nurseryId;
  final String templateId;

  // ─── Snapshot of the template at creation time ───────────────────────────
  final String title;
  final String? subject;
  final String? instructions;
  final String? type;
  final AssessmentScale scale;
  final List<AssessmentItem> items;

  // ─── Scope ───────────────────────────────────────────────────────────────
  final String branchId;
  final List<String> classroomIds;
  final String? teacherId; // optional; can be derived from the classroom(s)

  // ─── Schedule & state ────────────────────────────────────────────────────
  final int startDate;
  final int? endDate;
  final String status; // kRunStatus*

  // ─── Visibility flags (data-ready; no MVP UI) ────────────────────────────
  final bool visibleToTeacher;
  final bool visibleToParentAfterPublish;
  final bool includedInReports;

  final String createdBy;
  final int? createdAt;
  final int? updatedAt;

  const AssessmentRunModel({
    this.key,
    required this.nurseryId,
    required this.templateId,
    required this.title,
    this.subject,
    this.instructions,
    this.type,
    this.scale = const AssessmentScale(),
    this.items = const [],
    this.branchId = '',
    this.classroomIds = const [],
    this.teacherId,
    required this.startDate,
    this.endDate,
    this.status = kRunStatusDraft,
    this.visibleToTeacher = true,
    this.visibleToParentAfterPublish = true,
    this.includedInReports = true,
    required this.createdBy,
    this.createdAt,
    this.updatedAt,
  });

  bool get isDraft => status == kRunStatusDraft;
  bool get isActive => status == kRunStatusActive;
  bool get isCompleted => status == kRunStatusCompleted;

  factory AssessmentRunModel.fromJson(
    Map<dynamic, dynamic> json, {
    String? key,
  }) {
    return AssessmentRunModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      templateId: json['templateId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subject: json['subject']?.toString(),
      instructions: json['instructions']?.toString(),
      type: json['type']?.toString(),
      scale: _parseScale(json['scale']),
      items: _parseItems(json['items']),
      branchId: json['branchId']?.toString() ?? '',
      classroomIds: _parseStringList(json['classroomIds']),
      teacherId: json['teacherId']?.toString(),
      startDate: _parseInt(json['startDate']) ?? _now(),
      endDate: _parseInt(json['endDate']),
      status: json['status']?.toString() ?? kRunStatusDraft,
      visibleToTeacher: json['visibleToTeacher'] != false,
      visibleToParentAfterPublish: json['visibleToParentAfterPublish'] != false,
      includedInReports: json['includedInReports'] != false,
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
    data['templateId'] = templateId;
    data['title'] = title;
    put('subject', subject);
    put('instructions', instructions);
    put('type', type);
    data['scale'] = scale.toJson();
    data['items'] = items.map((i) => i.toJson()).toList();
    put('branchId', branchId.isEmpty ? null : branchId);
    data['classroomIds'] = classroomIds;
    put('teacherId', teacherId);
    data['startDate'] = startDate;
    put('endDate', endDate);
    data['status'] = status;
    data['visibleToTeacher'] = visibleToTeacher;
    data['visibleToParentAfterPublish'] = visibleToParentAfterPublish;
    data['includedInReports'] = includedInReports;
    data['createdBy'] = createdBy;
    data['createdAt'] = createdAt ?? _now();
    data['updatedAt'] = _now();
    return data;
  }

  AssessmentRunModel copyWith({
    String? key,
    String? nurseryId,
    String? templateId,
    String? title,
    String? subject,
    String? instructions,
    String? type,
    AssessmentScale? scale,
    List<AssessmentItem>? items,
    String? branchId,
    List<String>? classroomIds,
    String? teacherId,
    int? startDate,
    int? endDate,
    String? status,
    bool? visibleToTeacher,
    bool? visibleToParentAfterPublish,
    bool? includedInReports,
    String? createdBy,
    int? createdAt,
    int? updatedAt,
  }) {
    return AssessmentRunModel(
      key: key ?? this.key,
      nurseryId: nurseryId ?? this.nurseryId,
      templateId: templateId ?? this.templateId,
      title: title ?? this.title,
      subject: subject ?? this.subject,
      instructions: instructions ?? this.instructions,
      type: type ?? this.type,
      scale: scale ?? this.scale,
      items: items ?? this.items,
      branchId: branchId ?? this.branchId,
      classroomIds: classroomIds ?? this.classroomIds,
      teacherId: teacherId ?? this.teacherId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      visibleToTeacher: visibleToTeacher ?? this.visibleToTeacher,
      visibleToParentAfterPublish:
          visibleToParentAfterPublish ?? this.visibleToParentAfterPublish,
      includedInReports: includedInReports ?? this.includedInReports,
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

  static List<String> _parseStringList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    if (raw is Map) {
      return raw.values.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    return const [];
  }

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }
}

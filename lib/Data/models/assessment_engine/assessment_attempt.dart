import 'assessment_enums.dart';
import 'assessment_item_result.dart';

// One grading pass over a child for an assessment. The FIRST pass is normally
// the `official` attempt; a scheduled re-assessment appends a NEW attempt
// (`retake`/`practice`) rather than overwriting — so the child's full history is
// preserved. Which attempt "counts" is decided EXPLICITLY on the parent
// ChildAssessment (officialAttemptNo), never inferred as latest/highest.
//
// A retake may target only a subset of items ([scopedItemIds]); an empty list
// means the whole assessment. [totalFraction] (0-1) is the weighted average of
// the graded items' fractions, recomputed on save via [computeTotalFraction].
//
// The optional scheduledRetake* fields describe a PLANNED next attempt (set when
// the manager schedules a retake) — distinct from an unlock/correction.
class AssessmentAttempt {
  final int attemptNo;
  final int date;
  final String kind; // kAttemptKind*

  /// Items this attempt covers. Empty = all items in the assessment.
  final List<String> scopedItemIds;

  final List<AssessmentItemResult> results;
  final String? overallNote;

  /// Weighted mean of graded item fractions (0-1). Null until anything graded.
  final double? totalFraction;

  // ─── Planned retake attached to this attempt (nullable) ──────────────────
  final int? scheduledRetakeDate;
  final String? scheduledRetakeTeacherId;
  final List<String> scheduledRetakeItemIds;
  final bool scheduledRetakeNotifyParent;

  const AssessmentAttempt({
    required this.attemptNo,
    required this.date,
    this.kind = kAttemptKindOfficial,
    this.scopedItemIds = const [],
    this.results = const [],
    this.overallNote,
    this.totalFraction,
    this.scheduledRetakeDate,
    this.scheduledRetakeTeacherId,
    this.scheduledRetakeItemIds = const [],
    this.scheduledRetakeNotifyParent = false,
  });

  bool get hasScheduledRetake => scheduledRetakeDate != null;

  /// 0-100 percentage for display; null when nothing graded yet.
  double? get percentage =>
      totalFraction == null ? null : (totalFraction! * 100);

  /// Weighted mean of the graded results' fractions. Ungraded items are ignored
  /// so a half-finished attempt still shows a meaningful running score.
  static double? computeTotalFraction(List<AssessmentItemResult> results) {
    double sum = 0;
    double weight = 0;
    for (final r in results) {
      if (r.fraction == null) continue;
      sum += r.fraction! * r.weight;
      weight += r.weight;
    }
    if (weight == 0) return null;
    return sum / weight;
  }

  factory AssessmentAttempt.fromJson(Map<String, dynamic> json) {
    return AssessmentAttempt(
      attemptNo: _parseInt(json['attemptNo']) ?? 1,
      date: _parseInt(json['date']) ?? _now(),
      kind: json['kind']?.toString() ?? kAttemptKindOfficial,
      scopedItemIds: _parseStringList(json['scopedItemIds']),
      results: _parseResults(json['results']),
      overallNote: json['overallNote']?.toString(),
      totalFraction: _parseDouble(json['totalFraction']),
      scheduledRetakeDate: _parseInt(json['scheduledRetakeDate']),
      scheduledRetakeTeacherId: json['scheduledRetakeTeacherId']?.toString(),
      scheduledRetakeItemIds: _parseStringList(json['scheduledRetakeItemIds']),
      scheduledRetakeNotifyParent: json['scheduledRetakeNotifyParent'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'attemptNo': attemptNo,
      'date': date,
      'kind': kind,
    };
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    if (scopedItemIds.isNotEmpty) data['scopedItemIds'] = scopedItemIds;
    data['results'] = results.map((r) => r.toJson()).toList();
    put('overallNote', overallNote);
    put('totalFraction', totalFraction);
    put('scheduledRetakeDate', scheduledRetakeDate);
    put('scheduledRetakeTeacherId', scheduledRetakeTeacherId);
    if (scheduledRetakeItemIds.isNotEmpty) {
      data['scheduledRetakeItemIds'] = scheduledRetakeItemIds;
    }
    if (scheduledRetakeNotifyParent) {
      data['scheduledRetakeNotifyParent'] = true;
    }
    return data;
  }

  AssessmentAttempt copyWith({
    int? attemptNo,
    int? date,
    String? kind,
    List<String>? scopedItemIds,
    List<AssessmentItemResult>? results,
    String? overallNote,
    double? totalFraction,
    int? scheduledRetakeDate,
    String? scheduledRetakeTeacherId,
    List<String>? scheduledRetakeItemIds,
    bool? scheduledRetakeNotifyParent,
  }) {
    return AssessmentAttempt(
      attemptNo: attemptNo ?? this.attemptNo,
      date: date ?? this.date,
      kind: kind ?? this.kind,
      scopedItemIds: scopedItemIds ?? this.scopedItemIds,
      results: results ?? this.results,
      overallNote: overallNote ?? this.overallNote,
      totalFraction: totalFraction ?? this.totalFraction,
      scheduledRetakeDate: scheduledRetakeDate ?? this.scheduledRetakeDate,
      scheduledRetakeTeacherId:
          scheduledRetakeTeacherId ?? this.scheduledRetakeTeacherId,
      scheduledRetakeItemIds:
          scheduledRetakeItemIds ?? this.scheduledRetakeItemIds,
      scheduledRetakeNotifyParent:
          scheduledRetakeNotifyParent ?? this.scheduledRetakeNotifyParent,
    );
  }

  static List<AssessmentItemResult> _parseResults(dynamic raw) {
    Iterable<dynamic>? values;
    if (raw is List) {
      values = raw;
    } else if (raw is Map) {
      values = raw.values;
    }
    if (values == null) return const [];
    return values
        .whereType<Map>()
        .map((m) => AssessmentItemResult.fromJson(Map<String, dynamic>.from(m)))
        .where((r) => r.itemId.isNotEmpty)
        .toList();
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
  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }
}

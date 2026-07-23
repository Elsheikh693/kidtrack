// Firebase path: platform/{nurseryId}/childAssessments/{runId_childId}
//
// One child's participation in one AssessmentRun. This is where the REAL
// workflow lives (in_progress → teacher_completed → reviewed → published →
// locked) — each child advances INDEPENDENTLY, so a parent sees their child the
// moment its status hits `published`, regardless of the rest of the classroom.
//
// It holds the child's [attempts]; [officialAttemptNo] names which attempt
// counts (set EXPLICITLY by the manager — never inferred as latest/highest). A
// retake appends a new attempt; a correction UNLOCKS an existing one (recorded
// via the unlock* audit fields). Keyed `{runId}_{childId}` so re-materialising a
// run is idempotent.
//
// `BranchScoped` via the run's branch so branch-bound staff only read their own.

import '../core/branch_scoped.dart';
import 'assessment_attempt.dart';
import 'assessment_enums.dart';

class ChildAssessmentModel implements BranchScoped {
  @override
  List<String> get scopeBranches => branchId.isEmpty ? const [] : [branchId];

  final String? key;
  final String nurseryId;
  final String runId;
  final String childId;
  final String branchId;
  final String? classroomId;

  final String status; // kChildStatus*
  final int officialAttemptNo;
  final List<AssessmentAttempt> attempts;

  // ─── Correction audit (set only when a locked record is unlocked) ────────
  final String? unlockedBy;
  final int? unlockedAt;
  final String? unlockReason;

  final int? createdAt;
  final int? updatedAt;

  const ChildAssessmentModel({
    this.key,
    required this.nurseryId,
    required this.runId,
    required this.childId,
    this.branchId = '',
    this.classroomId,
    this.status = kChildStatusInProgress,
    this.officialAttemptNo = 1,
    this.attempts = const [],
    this.unlockedBy,
    this.unlockedAt,
    this.unlockReason,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPublished => status == kChildStatusPublished;
  bool get isLocked => status == kChildStatusLocked;
  bool get isTeacherCompleted => status == kChildStatusTeacherCompleted;
  bool get isVisibleToParent => isPublished || isLocked;

  /// The attempt the manager marked official (falls back to the last attempt,
  /// then the first) — for display of the "counting" score.
  AssessmentAttempt? get officialAttempt {
    if (attempts.isEmpty) return null;
    for (final a in attempts) {
      if (a.attemptNo == officialAttemptNo) return a;
    }
    return attempts.last;
  }

  AssessmentAttempt? get latestAttempt =>
      attempts.isEmpty ? null : attempts.last;

  bool get hasPendingRetake =>
      attempts.isNotEmpty && attempts.last.hasScheduledRetake;

  factory ChildAssessmentModel.fromJson(
    Map<dynamic, dynamic> json, {
    String? key,
  }) {
    return ChildAssessmentModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      runId: json['runId']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      classroomId: json['classroomId']?.toString(),
      status: json['status']?.toString() ?? kChildStatusInProgress,
      officialAttemptNo: _parseInt(json['officialAttemptNo']) ?? 1,
      attempts: _parseAttempts(json['attempts']),
      unlockedBy: json['unlockedBy']?.toString(),
      unlockedAt: _parseInt(json['unlockedAt']),
      unlockReason: json['unlockReason']?.toString(),
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
    data['runId'] = runId;
    data['childId'] = childId;
    put('branchId', branchId.isEmpty ? null : branchId);
    put('classroomId', classroomId);
    data['status'] = status;
    data['officialAttemptNo'] = officialAttemptNo;
    data['attempts'] = attempts.map((a) => a.toJson()).toList();
    put('unlockedBy', unlockedBy);
    put('unlockedAt', unlockedAt);
    put('unlockReason', unlockReason);
    data['createdAt'] = createdAt ?? _now();
    data['updatedAt'] = _now();
    return data;
  }

  ChildAssessmentModel copyWith({
    String? key,
    String? nurseryId,
    String? runId,
    String? childId,
    String? branchId,
    String? classroomId,
    String? status,
    int? officialAttemptNo,
    List<AssessmentAttempt>? attempts,
    String? unlockedBy,
    int? unlockedAt,
    String? unlockReason,
    int? createdAt,
    int? updatedAt,
  }) {
    return ChildAssessmentModel(
      key: key ?? this.key,
      nurseryId: nurseryId ?? this.nurseryId,
      runId: runId ?? this.runId,
      childId: childId ?? this.childId,
      branchId: branchId ?? this.branchId,
      classroomId: classroomId ?? this.classroomId,
      status: status ?? this.status,
      officialAttemptNo: officialAttemptNo ?? this.officialAttemptNo,
      attempts: attempts ?? this.attempts,
      unlockedBy: unlockedBy ?? this.unlockedBy,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      unlockReason: unlockReason ?? this.unlockReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<AssessmentAttempt> _parseAttempts(dynamic raw) {
    Iterable<dynamic>? values;
    if (raw is List) {
      values = raw;
    } else if (raw is Map) {
      values = raw.values;
    }
    if (values == null) return const [];
    final list = values
        .whereType<Map>()
        .map((m) => AssessmentAttempt.fromJson(Map<String, dynamic>.from(m)))
        .toList();
    list.sort((a, b) => a.attemptNo.compareTo(b.attemptNo));
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

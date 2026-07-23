import 'activity_photo_model.dart';

export 'activity_photo_model.dart';

enum EvalLevel {
  excellent,      // 🟢 ممتاز
  needsFollow,    // 🟡 يحتاج متابعة
  needsAttention; // 🔴 يحتاج اهتمام

  String get key {
    switch (this) {
      case EvalLevel.excellent:      return 'excellent';
      case EvalLevel.needsFollow:    return 'needs_follow';
      case EvalLevel.needsAttention: return 'needs_attention';
    }
  }

  static EvalLevel fromKey(String? k) {
    switch (k) {
      case 'excellent':      return EvalLevel.excellent;
      case 'needs_follow':   return EvalLevel.needsFollow;
      case 'needs_attention':return EvalLevel.needsAttention;
      default:               return EvalLevel.excellent;
    }
  }
}

class ClassroomActivityModel {
  final String? key;
  final String nurseryId;
  final String classroomId;
  // Branch that owns this activity — stamped from the teacher's branch at
  // creation. Empty for legacy records (before branch-stamping / backfill).
  // Used to keep classroom-scoped content from leaking across branches when a
  // classroom is shared (isAllBranches). See SessionService.branchVisible.
  final String? branchId;
  final String? subjectId;
  final String? subjectName;
  final String title;
  final String teacherId;
  final String status; // 'active' | 'completed'
  final int startedAt;
  final int? endedAt;
  // childId → EvalLevel.key  (saved only for evaluated children)
  final Map<String, String> evaluations;
  // childId → note text  (optional)
  final Map<String, String> notes;
  // childId → list of selected reason titles (structured evaluation reasons)
  final Map<String, List<String>> childReasons;
  // photoId → ActivityPhoto (url + approval + audience)
  final Map<String, ActivityPhoto> photos;
  // general note for the whole class
  final String? groupNote;
  final int? createdAt;
  // snapshot of child IDs present when activity started — used for timeline fan-out
  final List<String> childIds;
  // 'class'  → whole-classroom session (default; also all legacy records)
  // 'activity' → teacher picked a specific subset of children; childIds is the
  // fixed participant set the live panels + reports scope to.
  final String mode;

  const ClassroomActivityModel({
    this.key,
    required this.nurseryId,
    required this.classroomId,
    this.branchId,
    this.subjectId,
    this.subjectName,
    required this.title,
    required this.teacherId,
    this.status = 'active',
    required this.startedAt,
    this.endedAt,
    this.evaluations = const {},
    this.notes = const {},
    this.childReasons = const {},
    this.photos = const {},
    this.groupNote,
    this.createdAt,
    this.childIds = const [],
    this.mode = 'class',
  });

  bool get isActive => status == 'active';

  /// True when the teacher started this as a subset "activity" (picked
  /// specific children) rather than a whole-class session.
  bool get isActivityMode => mode == 'activity';

  Duration get elapsed =>
      DateTime.fromMillisecondsSinceEpoch(
              isActive ? DateTime.now().millisecondsSinceEpoch : (endedAt ?? startedAt))
          .difference(DateTime.fromMillisecondsSinceEpoch(startedAt));

  String get elapsedLabel {
    final d = elapsed;
    final h = d.inHours;
    final m = d.inMinutes % 60;
    if (h > 0) return '$h س ${m.toString().padLeft(2, '0')} د';
    return '$m دقيقة';
  }

  EvalLevel? evalFor(String childId) {
    final v = evaluations[childId];
    if (v == null) return null;
    return EvalLevel.fromKey(v);
  }

  // ── Photo helpers ──────────────────────────────────────────────────────────

  /// Every photo URL regardless of approval — staff/teacher-facing views.
  List<String> get allPhotoUrls =>
      photos.values.map((p) => p.url).where((u) => u.isNotEmpty).toList();

  /// Approved photo URLs a specific child's guardian may see (classroom-wide or
  /// targeted to that child) — the guardian-facing filter.
  List<String> approvedUrlsForChild(String childId) => photos.values
      .where((p) => p.isApproved && p.visibleTo(childId))
      .map((p) => p.url)
      .where((u) => u.isNotEmpty)
      .toList();

  bool get hasPendingPhotos => photos.values.any((p) => !p.isApproved);

  int get pendingPhotoCount =>
      photos.values.where((p) => !p.isApproved).length;

  factory ClassroomActivityModel.fromJson(Map<dynamic, dynamic> json,
      {String? key}) {
    Map<String, String> _parseMap(dynamic raw) {
      if (raw == null || raw is! Map) return {};
      return {
        for (final e in (raw as Map).entries)
          e.key.toString(): e.value.toString(),
      };
    }

    return ClassroomActivityModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      classroomId: json['classroomId']?.toString() ?? '',
      branchId: json['branchId']?.toString(),
      subjectId: json['subjectId']?.toString(),
      subjectName: json['subjectName']?.toString(),
      title: json['title']?.toString() ?? '',
      teacherId: json['teacherId']?.toString() ?? '',
      status: json['status']?.toString() ?? 'active',
      startedAt: _parseInt(json['startedAt']) ?? _now(),
      endedAt: _parseInt(json['endedAt']),
      evaluations: _parseMap(json['evaluations']),
      notes: _parseMap(json['notes']),
      childReasons: _parseReasonsMap(json['childReasons']),
      photos: _parsePhotos(json['photos']),
      groupNote: json['groupNote']?.toString(),
      createdAt: _parseInt(json['createdAt']),
      childIds: _parseStringList(json['childIds']),
      mode: json['mode']?.toString() ?? 'class',
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('key', key);
    data['nurseryId'] = nurseryId;
    data['classroomId'] = classroomId;
    put('branchId', branchId);
    put('subjectId', subjectId);
    put('subjectName', subjectName);
    data['title'] = title;
    data['teacherId'] = teacherId;
    data['status'] = status;
    data['startedAt'] = startedAt;
    put('endedAt', endedAt);
    if (evaluations.isNotEmpty) data['evaluations'] = evaluations;
    if (notes.isNotEmpty) data['notes'] = notes;
    if (childReasons.isNotEmpty) {
      data['childReasons'] = {
        for (final e in childReasons.entries)
          e.key: {for (int i = 0; i < e.value.length; i++) '$i': e.value[i]},
      };
    }
    if (photos.isNotEmpty) {
      data['photos'] = {
        for (final e in photos.entries) e.key: e.value.toJson(),
      };
    }
    put('groupNote', groupNote);
    put('createdAt', createdAt ?? _now());
    if (childIds.isNotEmpty) data['childIds'] = childIds;
    data['mode'] = mode;
    return data;
  }

  ClassroomActivityModel copyWith({
    String? key,
    String? nurseryId,
    String? classroomId,
    String? branchId,
    String? subjectId,
    String? subjectName,
    String? title,
    String? teacherId,
    String? status,
    int? startedAt,
    int? endedAt,
    Map<String, String>? evaluations,
    Map<String, String>? notes,
    Map<String, List<String>>? childReasons,
    Map<String, ActivityPhoto>? photos,
    String? groupNote,
    int? createdAt,
    List<String>? childIds,
    String? mode,
  }) =>
      ClassroomActivityModel(
        key: key ?? this.key,
        nurseryId: nurseryId ?? this.nurseryId,
        classroomId: classroomId ?? this.classroomId,
        branchId: branchId ?? this.branchId,
        subjectId: subjectId ?? this.subjectId,
        subjectName: subjectName ?? this.subjectName,
        title: title ?? this.title,
        teacherId: teacherId ?? this.teacherId,
        status: status ?? this.status,
        startedAt: startedAt ?? this.startedAt,
        endedAt: endedAt ?? this.endedAt,
        evaluations: evaluations ?? this.evaluations,
        notes: notes ?? this.notes,
        childReasons: childReasons ?? this.childReasons,
        photos: photos ?? this.photos,
        groupNote: groupNote ?? this.groupNote,
        createdAt: createdAt ?? this.createdAt,
        childIds: childIds ?? this.childIds,
        mode: mode ?? this.mode,
      );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static Map<String, ActivityPhoto> _parsePhotos(dynamic raw) {
    if (raw == null || raw is! Map) return {};
    return {
      for (final e in (raw as Map).entries)
        e.key.toString(): ActivityPhoto.fromValue(e.key.toString(), e.value),
    };
  }

  static Map<String, List<String>> _parseReasonsMap(dynamic raw) {
    if (raw == null || raw is! Map) return {};
    final result = <String, List<String>>{};
    for (final entry in (raw as Map).entries) {
      final childId = entry.key.toString();
      final value = entry.value;
      if (value is Map) {
        result[childId] = value.values.map((v) => v.toString()).toList();
      } else if (value is List) {
        result[childId] = value.map((v) => v.toString()).toList();
      }
    }
    return result;
  }

  static List<String> _parseStringList(dynamic raw) {
    if (raw == null) return [];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    if (raw is Map) return raw.values.map((e) => e.toString()).toList();
    return [];
  }
}

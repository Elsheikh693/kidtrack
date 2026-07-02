/// The relative weights that fold a branch's four health signals into a single
/// 0–100 Branch Health Score. Configurable per nursery (stored on
/// [BranchTargetModel]) but ship with v1 fixed defaults — owners can tune later
/// without a code change. Parent Satisfaction is intentionally absent until a
/// data source exists for it.
class BranchHealthWeights {
  final double occupancy;
  final double collections;
  final double teacherActivity;
  final double pendingTasks;

  const BranchHealthWeights({
    this.occupancy = 30,
    this.collections = 30,
    this.teacherActivity = 25,
    this.pendingTasks = 15,
  });

  /// v1 locked defaults: 30 / 30 / 25 / 15.
  static const BranchHealthWeights defaults = BranchHealthWeights();

  double get total => occupancy + collections + teacherActivity + pendingTasks;

  Map<String, dynamic> toJson() => {
        'occupancy': occupancy,
        'collections': collections,
        'teacherActivity': teacherActivity,
        'pendingTasks': pendingTasks,
      };

  factory BranchHealthWeights.fromJson(Map<String, dynamic>? json) {
    if (json == null) return defaults;
    double w(dynamic v, double d) =>
        v == null ? d : (v as num).toDouble();
    return BranchHealthWeights(
      occupancy: w(json['occupancy'], 30),
      collections: w(json['collections'], 30),
      teacherActivity: w(json['teacherActivity'], 25),
      pendingTasks: w(json['pendingTasks'], 15),
    );
  }
}

/// The goals a single branch is measured against — occupancy, collection rate,
/// and teacher-activity targets (all as 0–100 percentages) plus the health-score
/// [weights]. Lives at `platform/{nurseryId}/branchTargets/{branchId}`.
///
/// A branch with NO stored record simply uses [BranchTargetModel.defaults]
/// (85 / 95 / 90), so the system works the day a branch is created — targets are
/// an optional tuning layer, never a prerequisite.
class BranchTargetModel {
  /// Equals the branchId (the record key under `branchTargets`).
  final String? key;
  final String nurseryId;

  final double occupancyTarget;
  final double collectionTarget;
  final double teacherActivityTarget;

  final BranchHealthWeights weights;

  final int? createdAt;
  final int? updatedAt;

  const BranchTargetModel({
    this.key,
    required this.nurseryId,
    this.occupancyTarget = 85,
    this.collectionTarget = 95,
    this.teacherActivityTarget = 90,
    this.weights = BranchHealthWeights.defaults,
    this.createdAt,
    this.updatedAt,
  });

  /// Sensible v1 defaults for a branch that has no stored target record.
  factory BranchTargetModel.defaults({String nurseryId = '', String? branchId}) =>
      BranchTargetModel(key: branchId, nurseryId: nurseryId);

  factory BranchTargetModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return BranchTargetModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      occupancyTarget: _parseDouble(json['occupancyTarget']) ?? 85,
      collectionTarget: _parseDouble(json['collectionTarget']) ?? 95,
      teacherActivityTarget: _parseDouble(json['teacherActivityTarget']) ?? 90,
      weights: BranchHealthWeights.fromJson(
        (json['weights'] as Map?)?.cast<String, dynamic>(),
      ),
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
    put('nurseryId', nurseryId);
    data['occupancyTarget'] = occupancyTarget;
    data['collectionTarget'] = collectionTarget;
    data['teacherActivityTarget'] = teacherActivityTarget;
    data['weights'] = weights.toJson();
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  BranchTargetModel copyWith({
    String? key,
    String? nurseryId,
    double? occupancyTarget,
    double? collectionTarget,
    double? teacherActivityTarget,
    BranchHealthWeights? weights,
    int? createdAt,
    int? updatedAt,
  }) =>
      BranchTargetModel(
        key: key ?? this.key,
        nurseryId: nurseryId ?? this.nurseryId,
        occupancyTarget: occupancyTarget ?? this.occupancyTarget,
        collectionTarget: collectionTarget ?? this.collectionTarget,
        teacherActivityTarget:
            teacherActivityTarget ?? this.teacherActivityTarget,
        weights: weights ?? this.weights,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  static int _now() => DateTime.now().millisecondsSinceEpoch;

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

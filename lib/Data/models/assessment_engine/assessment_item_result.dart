// One item's grade for one child within a single Attempt.
//
// [rawValue] is what the teacher picked (a scale level key like 'good', or a
// number for a numeric scale). [fraction] (0-1) is the normalised value computed
// from the run's scale at save time — stored so totals never depend on
// re-resolving the scale later. [skillId] mirrors the item's skill link so
// skill-progress queries can read results directly (data-ready for V2).
// [updatedBy]/[updatedAt] are the lightweight audit fields (MVP: no full log).
class AssessmentItemResult {
  final String itemId;
  final String? skillId;

  /// The teacher's selection: a level key (rating) or a number-as-string (numeric).
  final String? rawValue;

  /// Normalised 0-1 value derived from the scale. Null = not yet graded.
  final double? fraction;

  final String? note;
  final double weight;

  final String? updatedBy;
  final int? updatedAt;

  const AssessmentItemResult({
    required this.itemId,
    this.skillId,
    this.rawValue,
    this.fraction,
    this.note,
    this.weight = 1.0,
    this.updatedBy,
    this.updatedAt,
  });

  bool get isGraded => rawValue != null && rawValue!.isNotEmpty;

  factory AssessmentItemResult.fromJson(Map<String, dynamic> json) {
    return AssessmentItemResult(
      itemId: json['itemId']?.toString() ?? '',
      skillId: json['skillId']?.toString(),
      rawValue: json['rawValue']?.toString(),
      fraction: _parseDouble(json['fraction']),
      note: json['note']?.toString(),
      weight: _parseDouble(json['weight']) ?? 1.0,
      updatedBy: json['updatedBy']?.toString(),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'itemId': itemId,
      'weight': weight,
    };
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('skillId', skillId);
    put('rawValue', rawValue);
    put('fraction', fraction);
    put('note', note);
    put('updatedBy', updatedBy);
    put('updatedAt', updatedAt);
    return data;
  }

  AssessmentItemResult copyWith({
    String? itemId,
    String? skillId,
    String? rawValue,
    double? fraction,
    String? note,
    double? weight,
    String? updatedBy,
    int? updatedAt,
  }) {
    return AssessmentItemResult(
      itemId: itemId ?? this.itemId,
      skillId: skillId ?? this.skillId,
      rawValue: rawValue ?? this.rawValue,
      fraction: fraction ?? this.fraction,
      note: note ?? this.note,
      weight: weight ?? this.weight,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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

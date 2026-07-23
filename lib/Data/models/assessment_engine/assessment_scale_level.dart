// One selectable level inside a rating [AssessmentScale].
//
// Example scale "Excellent…Weak":
//   levels = [
//     AssessmentScaleLevel(key: 'excellent', label: 'ممتاز',        fraction: 1.0),
//     AssessmentScaleLevel(key: 'good',      label: 'جيد',          fraction: 0.6),
//     AssessmentScaleLevel(key: 'weak',      label: 'ضعيف',         fraction: 0.0),
//   ]
//
// [fraction] (0-1) is the normalised weight of this level — it is what lets a
// Pass/Fail item and a 5-star item live in the same total. [color] is an ARGB
// int for the UI chip (same convention as EvalLevelTemplateModel.color).
class AssessmentScaleLevel {
  final String key;
  final String label;

  /// Normalised value 0.0-1.0 used to compute the child's total percentage.
  final double fraction;

  /// ARGB color value (stored as int); optional visual for the level chip.
  final int? color;

  const AssessmentScaleLevel({
    required this.key,
    required this.label,
    required this.fraction,
    this.color,
  });

  factory AssessmentScaleLevel.fromJson(Map<String, dynamic> json) {
    return AssessmentScaleLevel(
      key: json['key']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      fraction: _parseDouble(json['fraction']) ?? 0.0,
      color: _parseInt(json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'key': key,
      'label': label,
      'fraction': fraction,
    };
    if (color != null) data['color'] = color;
    return data;
  }

  AssessmentScaleLevel copyWith({
    String? key,
    String? label,
    double? fraction,
    int? color,
  }) {
    return AssessmentScaleLevel(
      key: key ?? this.key,
      label: label ?? this.label,
      fraction: fraction ?? this.fraction,
      color: color ?? this.color,
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

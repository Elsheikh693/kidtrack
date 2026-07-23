import 'assessment_enums.dart';
import 'assessment_scale_level.dart';

// The grading scale for an Assessment. ONE scale per assessment (not per item)
// — locked product decision. Two kinds:
//   • rating  → pick one of [levels] (Excellent…Weak, Pass/Fail)
//   • numeric → a value in 0..[numericMax] (e.g. 0-10)
//
// A scale is authored on the Template and then SNAPSHOTTED onto the Run, so
// editing the template later never mutates a past run's grading meaning.
//
// [fractionFor] maps any stored raw value to a 0-1 fraction — the single source
// of truth that lets different scale kinds produce a comparable total.
class AssessmentScale {
  final String kind; // kScaleKindRating | kScaleKindNumeric

  /// For [kScaleKindRating]: the ordered selectable levels.
  final List<AssessmentScaleLevel> levels;

  /// For [kScaleKindNumeric]: the maximum value (min is always 0).
  final double? numericMax;

  const AssessmentScale({
    this.kind = kScaleKindRating,
    this.levels = const [],
    this.numericMax,
  });

  bool get isNumeric => kind == kScaleKindNumeric;
  bool get isRating => !isNumeric;

  /// Normalise a stored raw value to 0-1.
  ///   • rating  → look the level up by key and return its [fraction]
  ///   • numeric → value / numericMax (clamped)
  /// Returns null when the value can't be resolved (ungraded item).
  double? fractionFor(dynamic rawValue) {
    if (rawValue == null) return null;
    if (isNumeric) {
      final max = numericMax ?? 0;
      if (max <= 0) return null;
      final v = rawValue is num
          ? rawValue.toDouble()
          : double.tryParse(rawValue.toString());
      if (v == null) return null;
      return (v / max).clamp(0.0, 1.0);
    }
    final key = rawValue.toString();
    for (final l in levels) {
      if (l.key == key) return l.fraction;
    }
    return null;
  }

  /// Human label for a stored raw value (the level label, or the number itself).
  String labelFor(dynamic rawValue) {
    if (rawValue == null) return '';
    if (isNumeric) return rawValue.toString();
    final key = rawValue.toString();
    for (final l in levels) {
      if (l.key == key) return l.label;
    }
    return key;
  }

  factory AssessmentScale.fromJson(Map<String, dynamic> json) {
    return AssessmentScale(
      kind: json['kind']?.toString() ?? kScaleKindRating,
      levels: _parseLevels(json['levels']),
      numericMax: _parseDouble(json['numericMax']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{'kind': kind};
    if (levels.isNotEmpty) {
      data['levels'] = levels.map((l) => l.toJson()).toList();
    }
    if (numericMax != null) data['numericMax'] = numericMax;
    return data;
  }

  AssessmentScale copyWith({
    String? kind,
    List<AssessmentScaleLevel>? levels,
    double? numericMax,
  }) {
    return AssessmentScale(
      kind: kind ?? this.kind,
      levels: levels ?? this.levels,
      numericMax: numericMax ?? this.numericMax,
    );
  }

  // RTDB returns a list either as a List (sequential keys) or a Map.
  static List<AssessmentScaleLevel> _parseLevels(dynamic raw) {
    Iterable<dynamic>? values;
    if (raw is List) {
      values = raw;
    } else if (raw is Map) {
      values = raw.values;
    }
    if (values == null) return const [];
    return values
        .whereType<Map>()
        .map((m) => AssessmentScaleLevel.fromJson(Map<String, dynamic>.from(m)))
        .where((l) => l.key.isNotEmpty)
        .toList();
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

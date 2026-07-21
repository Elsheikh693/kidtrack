// Firebase path: platform/{nurseryId}/evalLevelTemplates/{id}
// Nursery-defined activity evaluation levels (ممتاز / يحتاج متابعة / يحتاج دعم …).
// Each level carries a display (title/icon/color) and a numeric [score] (0-5)
// used to compute report averages. The three legacy levels keep their original
// keys ('excellent'/'needs_follow'/'needs_attention') so activities evaluated
// before this feature still resolve — no data migration needed.

const List<String> kLegacyEvalKeys = [
  'excellent',
  'needs_follow',
  'needs_attention',
];

class EvalLevelTemplateModel {
  final String? key;
  final String nurseryId;
  final String title;
  final String icon;

  /// ARGB color value (stored as int).
  final int color;

  /// Weight 0-5 used for report averages and ranking (excellent=5 … support=1).
  final double score;

  final bool isActive;
  final int createdAt;

  const EvalLevelTemplateModel({
    this.key,
    required this.nurseryId,
    required this.title,
    required this.icon,
    required this.color,
    required this.score,
    this.isActive = true,
    required this.createdAt,
  });

  factory EvalLevelTemplateModel.fromJson(
    Map<String, dynamic> json, {
    String? key,
  }) {
    return EvalLevelTemplateModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '',
      color: _parseInt(json['color']) ?? 0xFF16A34A,
      score: _parseDouble(json['score']) ?? 0.0,
      isActive: json['isActive'] != false,
      createdAt: _parseInt(json['createdAt']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (key != null) data['key'] = key;
    data['nurseryId'] = nurseryId;
    data['title'] = title;
    data['icon'] = icon;
    data['color'] = color;
    data['score'] = score;
    data['isActive'] = isActive;
    data['createdAt'] = createdAt;
    return data;
  }

  EvalLevelTemplateModel copyWith({
    String? key,
    String? title,
    String? icon,
    int? color,
    double? score,
    bool? isActive,
  }) {
    return EvalLevelTemplateModel(
      key: key ?? this.key,
      nurseryId: nurseryId,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      score: score ?? this.score,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v.toString());
  }

  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

/// Levels seeded the first time the eval-levels settings screen is opened (when
/// the nursery has none yet). Keys MUST match the legacy stored eval strings so
/// existing activity evaluations keep resolving. The owner can edit/delete them.
class EvalLevelDefaults {
  EvalLevelDefaults._();

  static const List<
      ({
        String key,
        String titleKey,
        String icon,
        int color,
        double score,
      })> seed = [
    (
      key: 'excellent',
      titleKey: 'teacher_eval_excellent',
      icon: 'excellent',
      color: 0xFF16A34A, // activityGreen
      score: 5,
    ),
    (
      key: 'needs_follow',
      titleKey: 'teacher_eval_needs_follow',
      icon: 'follow',
      color: 0xFFD97706, // activityAmber
      score: 3,
    ),
    (
      key: 'needs_attention',
      titleKey: 'teacher_eval_needs_attention',
      icon: 'support',
      color: 0xFFDC2626, // activityRed
      score: 1,
    ),
  ];
}

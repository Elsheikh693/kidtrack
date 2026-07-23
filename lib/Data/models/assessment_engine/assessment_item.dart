// A single item (بند / criterion) inside an Assessment — "يعرف حرف أ",
// "يكتب حرف أ", etc. Authored on the Template and SNAPSHOTTED onto the Run.
//
// [id] is a stable local id (not a Firebase key) so a child's ItemResult can
// reference the exact item even after the template is edited. [skillId] is
// nullable and unused by the MVP UI, but STORED from day one so future
// skill-progress-over-time charts have the data without a migration.
// [weight] defaults to 1 (all items count equally in the MVP) — the field
// exists only to enable weighting later.
class AssessmentItem {
  final String id;
  final String title;
  final String? description;

  /// Optional link to a reusable Skill (no Skill Library in the MVP — data only).
  final String? skillId;

  /// Relative weight in the total. MVP always 1; kept for future weighting.
  final double weight;

  /// Display order within the assessment.
  final int order;

  const AssessmentItem({
    required this.id,
    required this.title,
    this.description,
    this.skillId,
    this.weight = 1.0,
    this.order = 0,
  });

  factory AssessmentItem.fromJson(Map<String, dynamic> json) {
    return AssessmentItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      skillId: json['skillId']?.toString(),
      weight: _parseDouble(json['weight']) ?? 1.0,
      order: _parseInt(json['order']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'id': id,
      'title': title,
      'weight': weight,
      'order': order,
    };
    if (description != null && description!.isNotEmpty) {
      data['description'] = description;
    }
    if (skillId != null && skillId!.isNotEmpty) data['skillId'] = skillId;
    return data;
  }

  AssessmentItem copyWith({
    String? id,
    String? title,
    String? description,
    String? skillId,
    double? weight,
    int? order,
  }) {
    return AssessmentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      skillId: skillId ?? this.skillId,
      weight: weight ?? this.weight,
      order: order ?? this.order,
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

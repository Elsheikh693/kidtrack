class EvaluationReasonModel {
  final String? key;
  final String nurseryId;
  final String title;
  final bool isActive;
  final int createdAt;

  const EvaluationReasonModel({
    this.key,
    required this.nurseryId,
    required this.title,
    this.isActive = true,
    required this.createdAt,
  });

  factory EvaluationReasonModel.fromJson(
    Map<dynamic, dynamic> json, {
    String? key,
  }) {
    return EvaluationReasonModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      isActive: _parseBool(json['isActive']),
      createdAt:
          _parseInt(json['createdAt']) ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() => {
        'nurseryId': nurseryId,
        'title': title,
        'isActive': isActive,
        'createdAt': createdAt,
      };

  EvaluationReasonModel copyWith({
    String? key,
    String? nurseryId,
    String? title,
    bool? isActive,
    int? createdAt,
  }) =>
      EvaluationReasonModel(
        key: key ?? this.key,
        nurseryId: nurseryId ?? this.nurseryId,
        title: title ?? this.title,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );

  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) return v == 'true' || v == '1';
    return true;
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

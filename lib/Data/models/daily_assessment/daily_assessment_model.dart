enum DailyRating {
  excellent,
  veryGood,
  good,
  needsSupport;

  String get value {
    switch (this) {
      case DailyRating.excellent:    return 'excellent';
      case DailyRating.veryGood:     return 'very_good';
      case DailyRating.good:         return 'good';
      case DailyRating.needsSupport: return 'needs_support';
    }
  }

  static DailyRating fromValue(String v) {
    switch (v) {
      case 'excellent':     return DailyRating.excellent;
      case 'very_good':     return DailyRating.veryGood;
      case 'good':          return DailyRating.good;
      case 'needs_support': return DailyRating.needsSupport;
      default:              return DailyRating.good;
    }
  }

  String get labelAr {
    switch (this) {
      case DailyRating.excellent:    return 'ممتاز';
      case DailyRating.veryGood:     return 'جيد جداً';
      case DailyRating.good:         return 'جيد';
      case DailyRating.needsSupport: return 'يحتاج متابعة';
    }
  }

  String get emoji {
    switch (this) {
      case DailyRating.excellent:    return '⭐';
      case DailyRating.veryGood:     return '✅';
      case DailyRating.good:         return '➖';
      case DailyRating.needsSupport: return '⚠️';
    }
  }
}

/// Key pattern: {date}_{classroomId}_{childId}
/// One assessment per child per classroom per day.
class DailyAssessmentModel {
  final String? key;
  final String nurseryId;
  final String branchId;
  final String classroomId;
  final String teacherId;
  final String childId;
  final String date; // YYYY-MM-DD
  final DailyRating rating;
  final String? comment;
  final int? createdAt;
  final int? updatedAt;

  const DailyAssessmentModel({
    this.key,
    required this.nurseryId,
    required this.branchId,
    required this.classroomId,
    required this.teacherId,
    required this.childId,
    required this.date,
    this.rating = DailyRating.good,
    this.comment,
    this.createdAt,
    this.updatedAt,
  });

  static String buildKey(String date, String classroomId, String childId) =>
      '${date}_${classroomId}_$childId';

  factory DailyAssessmentModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return DailyAssessmentModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      classroomId: json['classroomId']?.toString() ?? '',
      teacherId: json['teacherId']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      rating: DailyRating.fromValue(json['rating']?.toString() ?? 'good'),
      comment: json['comment']?.toString(),
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    data['nurseryId'] = nurseryId;
    data['branchId'] = branchId;
    data['classroomId'] = classroomId;
    data['teacherId'] = teacherId;
    data['childId'] = childId;
    data['date'] = date;
    data['rating'] = rating.value;
    put('comment', comment);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  DailyAssessmentModel copyWith({
    String? key, String? nurseryId, String? branchId, String? classroomId,
    String? teacherId, String? childId, String? date, DailyRating? rating,
    String? comment, int? createdAt, int? updatedAt,
  }) =>
      DailyAssessmentModel(
        key: key ?? this.key,
        nurseryId: nurseryId ?? this.nurseryId,
        branchId: branchId ?? this.branchId,
        classroomId: classroomId ?? this.classroomId,
        teacherId: teacherId ?? this.teacherId,
        childId: childId ?? this.childId,
        date: date ?? this.date,
        rating: rating ?? this.rating,
        comment: comment ?? this.comment,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

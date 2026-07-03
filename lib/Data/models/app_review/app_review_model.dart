/// A user's rating of the KidTrack app itself, submitted pre-login from the
/// Discovery settings hub ("قولنا كلمة حلوة"). Stored at top-level global
/// `appReviews/{key}` — a NEW node, distinct from the nursery-scoped
/// `feedback` (which rates a specific nursery). SuperAdmin reads + replies.
class AppReviewModel {
  final String? key;
  final String? name; // taken from the session user; null if not logged in
  final int rating; // 1..5
  final String? comment;
  final List<String> tags; // preset quick-pick tag keys
  final String status; // new, read, replied
  final String? adminReply;
  final int? createdAt;
  final int? updatedAt;

  const AppReviewModel({
    this.key,
    this.name,
    required this.rating,
    this.comment,
    this.tags = const [],
    this.status = 'new',
    this.adminReply,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasReply => (adminReply ?? '').trim().isNotEmpty;

  factory AppReviewModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return AppReviewModel(
      key: key ?? json['key']?.toString(),
      name: json['name']?.toString(),
      rating: _parseInt(json['rating']) ?? 0,
      comment: json['comment']?.toString(),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
      status: json['status']?.toString() ?? 'new',
      adminReply: json['adminReply']?.toString(),
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
    put('name', name);
    data['rating'] = rating;
    put('comment', comment);
    data['tags'] = tags;
    data['status'] = status;
    put('adminReply', adminReply);
    data['createdAt'] = createdAt ?? _now();
    data['updatedAt'] = _now();
    return data;
  }

  AppReviewModel copyWith({
    String? key,
    String? name,
    int? rating,
    String? comment,
    List<String>? tags,
    String? status,
    String? adminReply,
    int? createdAt,
    int? updatedAt,
  }) {
    return AppReviewModel(
      key: key ?? this.key,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      adminReply: adminReply ?? this.adminReply,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

/// A parent's rating of the KidTrack app for one campaign. Stored at
/// `platformFeedback/{nurseryId}/{campaignId}/{parentId}` — nursery-first so a
/// SuperAdmin can read one nursery's responses per campaign (history/comparison)
/// with a single subtree read, and keyed by parent so a family answers once per
/// campaign (a re-submit overwrites).
class KidtrackFeedbackResponseModel {
  final String? key;
  final String campaignId;
  final String nurseryId;
  final String parentId;
  final String parentName;
  final String? childId;
  final int rating; // 1..5
  final String? comment;
  final List<String> tags;
  final int? createdAt;

  const KidtrackFeedbackResponseModel({
    this.key,
    required this.campaignId,
    required this.nurseryId,
    required this.parentId,
    required this.parentName,
    this.childId,
    required this.rating,
    this.comment,
    this.tags = const [],
    this.createdAt,
  });

  factory KidtrackFeedbackResponseModel.fromJson(
    Map<String, dynamic> json, {
    String? key,
  }) {
    return KidtrackFeedbackResponseModel(
      key: key ?? json['key']?.toString(),
      campaignId: json['campaignId']?.toString() ?? '',
      nurseryId: json['nurseryId']?.toString() ?? '',
      parentId: json['parentId']?.toString() ?? '',
      parentName: json['parentName']?.toString() ?? '',
      childId: json['childId']?.toString(),
      rating: _parseInt(json['rating']) ?? 0,
      comment: json['comment']?.toString(),
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      createdAt: _parseInt(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('key', key);
    data['campaignId'] = campaignId;
    data['nurseryId'] = nurseryId;
    data['parentId'] = parentId;
    data['parentName'] = parentName;
    put('childId', childId);
    data['rating'] = rating;
    put('comment', comment);
    data['tags'] = tags;
    data['createdAt'] = createdAt ?? _now();
    return data;
  }

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

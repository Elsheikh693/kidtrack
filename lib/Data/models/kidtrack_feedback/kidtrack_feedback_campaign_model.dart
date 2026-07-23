/// A reusable feedback survey targeting the KidTrack app itself (NOT a nursery).
/// Stored globally at `platform/kidtrackFeedbackCampaigns/{campaignId}`.
///
/// The SuperAdmin creates a campaign once (title/description), then assigns it
/// to individual nurseries via [NurseryModel.kidtrackFeedbackCampaignId]. A new
/// campaign auto-re-shows the parent prompt (the gate stores the last answered
/// campaign id), so future surveys — Attendance, Notifications, post-update
/// satisfaction — need no code change, just "Create Campaign + assign".
class KidtrackFeedbackCampaignModel {
  final String? key;
  final String title;
  final String? description;

  /// Master switch. A nursery's prompt is only live when it links this campaign
  /// AND [enabled] is true (effective-enabled = linked && campaign.enabled).
  final bool enabled;

  /// Free-text choices the parent picks from under "What did you like most?".
  /// Authored per-campaign by the SuperAdmin (not translation keys) so every
  /// campaign can offer its own options; stored verbatim on each response.
  final List<String> tags;
  final int? createdAt;

  const KidtrackFeedbackCampaignModel({
    this.key,
    required this.title,
    this.description,
    this.enabled = true,
    this.tags = const [],
    this.createdAt,
  });

  factory KidtrackFeedbackCampaignModel.fromJson(
    Map<String, dynamic> json, {
    String? key,
  }) {
    return KidtrackFeedbackCampaignModel(
      key: key ?? json['key']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      enabled: _parseBool(json['enabled']),
      tags: _parseTags(json['tags']),
      createdAt: _parseInt(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('key', key);
    data['title'] = title;
    put('description', description);
    data['enabled'] = enabled;
    if (tags.isNotEmpty) data['tags'] = tags;
    data['createdAt'] = createdAt ?? _now();
    return data;
  }

  KidtrackFeedbackCampaignModel copyWith({
    String? key,
    String? title,
    String? description,
    bool? enabled,
    List<String>? tags,
    int? createdAt,
  }) => KidtrackFeedbackCampaignModel(
    key: key ?? this.key,
    title: title ?? this.title,
    description: description ?? this.description,
    enabled: enabled ?? this.enabled,
    tags: tags ?? this.tags,
    createdAt: createdAt ?? this.createdAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static bool _parseBool(dynamic v, {bool fallback = true}) {
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) return v == '1' || v.toLowerCase() == 'true';
    return fallback;
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  /// RTDB may return tags as a List or (for sparse arrays) a Map; normalise both
  /// to a clean list of non-empty strings.
  static List<String> _parseTags(dynamic v) {
    Iterable? raw;
    if (v is List) raw = v;
    if (v is Map) raw = v.values;
    if (raw == null) return const [];
    return raw
        .where((e) => e != null)
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }
}

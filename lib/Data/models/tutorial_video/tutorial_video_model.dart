import '../user/user_type.dart';

/// A single in-app tutorial video. Uploaded and role-targeted by the SuperAdmin,
/// streamed by every role on the "Learn the App" screen.
///
/// [audience] holds the [UserType] names (e.g. `owner`, `branchManager`,
/// `teacher`, `receptionist`, `parent`) that are allowed to see the video, so a
/// single flexible list replaces per-role hard-coding: the SuperAdmin tags each
/// upload with the roles it belongs to.
class TutorialVideoModel {
  final String? key;
  final String title;
  final String? description;
  final String videoUrl;
  final String? thumbnailUrl;
  final List<String> audience;
  final int order;
  final bool isActive;
  final int? createdAt;

  const TutorialVideoModel({
    this.key,
    required this.title,
    this.description,
    required this.videoUrl,
    this.thumbnailUrl,
    this.audience = const [],
    this.order = 0,
    this.isActive = true,
    this.createdAt,
  });

  factory TutorialVideoModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return TutorialVideoModel(
      key: key ?? json['key']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      videoUrl: json['videoUrl']?.toString() ?? '',
      thumbnailUrl: json['thumbnailUrl']?.toString(),
      audience: _parseList(json['audience']),
      order: _parseInt(json['order']) ?? 0,
      isActive: json['isActive'] == true || json['isActive'] == null,
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
    data['videoUrl'] = videoUrl;
    put('thumbnailUrl', thumbnailUrl);
    data['audience'] = audience;
    data['order'] = order;
    data['isActive'] = isActive;
    put('createdAt', createdAt ?? _now());
    return data;
  }

  TutorialVideoModel copyWith({
    String? key,
    String? title,
    String? description,
    String? videoUrl,
    String? thumbnailUrl,
    List<String>? audience,
    int? order,
    bool? isActive,
    int? createdAt,
  }) =>
      TutorialVideoModel(
        key: key ?? this.key,
        title: title ?? this.title,
        description: description ?? this.description,
        videoUrl: videoUrl ?? this.videoUrl,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        audience: audience ?? this.audience,
        order: order ?? this.order,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );

  bool get hasThumbnail =>
      thumbnailUrl != null && thumbnailUrl!.trim().isNotEmpty;

  /// Whether this video should be shown to the given role.
  bool visibleTo(UserType role) => audience.contains(role.name);

  static List<String> _parseList(dynamic v) {
    if (v == null) return const [];
    if (v is List) {
      return v.map((e) => e.toString()).toList();
    }
    if (v is Map) {
      return v.values.map((e) => e.toString()).toList();
    }
    return const [];
  }

  static int _now() => DateTime.now().millisecondsSinceEpoch;

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

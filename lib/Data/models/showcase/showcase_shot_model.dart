/// A single marketing screenshot shown in the public website "شوف كل تطبيق من
/// جوّه" albums section. Uploaded and ordered by the SuperAdmin, read anonymously
/// by the static website via the RTDB REST endpoint.
///
/// [role] holds the website album key it belongs to — one of `owner`, `manager`,
/// `teacher`, `reception`, `parent` — matching the album keys hard-coded in
/// `public/index.html`, so the website can group shots by role directly.
class ShowcaseShotModel {
  final String? key;
  final String role;
  final String imageUrl;
  final int order;
  final bool isActive;
  final int? createdAt;

  const ShowcaseShotModel({
    this.key,
    required this.role,
    required this.imageUrl,
    this.order = 0,
    this.isActive = true,
    this.createdAt,
  });

  factory ShowcaseShotModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return ShowcaseShotModel(
      key: key ?? json['key']?.toString(),
      role: json['role']?.toString() ?? '',
      imageUrl: json['imageUrl']?.toString() ?? '',
      order: _parseInt(json['order']) ?? 0,
      isActive: json['isActive'] == true || json['isActive'] == null,
      createdAt: _parseInt(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (key != null) data['key'] = key;
    data['role'] = role;
    data['imageUrl'] = imageUrl;
    data['order'] = order;
    data['isActive'] = isActive;
    data['createdAt'] = createdAt ?? _now();
    return data;
  }

  ShowcaseShotModel copyWith({
    String? key,
    String? role,
    String? imageUrl,
    int? order,
    bool? isActive,
    int? createdAt,
  }) =>
      ShowcaseShotModel(
        key: key ?? this.key,
        role: role ?? this.role,
        imageUrl: imageUrl ?? this.imageUrl,
        order: order ?? this.order,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );

  static int _now() => DateTime.now().millisecondsSinceEpoch;

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

// Firebase path: platform/{nurseryId}/childStateTemplates/{id}
// Owner-defined states for tracking what a child is doing (sleeping, eating, etc.)
// 'with_classroom' is the system default — not stored here.

const kDefaultStateId = 'with_classroom';

class ChildStateTemplateModel {
  final String? key;
  final String nurseryId;
  final String title;
  final String icon;
  final bool isActive;
  final int createdAt;

  const ChildStateTemplateModel({
    this.key,
    required this.nurseryId,
    required this.title,
    required this.icon,
    this.isActive = true,
    required this.createdAt,
  });

  factory ChildStateTemplateModel.fromJson(
    Map<String, dynamic> json, {
    String? key,
  }) {
    return ChildStateTemplateModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '🟢',
      isActive: json['isActive'] != false,
      createdAt: _parseInt(json['createdAt']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('key', key);
    data['nurseryId'] = nurseryId;
    data['title'] = title;
    data['icon'] = icon;
    data['isActive'] = isActive;
    data['createdAt'] = createdAt;
    return data;
  }

  ChildStateTemplateModel copyWith({
    String? key,
    String? title,
    String? icon,
    bool? isActive,
  }) {
    return ChildStateTemplateModel(
      key: key ?? this.key,
      nurseryId: nurseryId,
      title: title ?? this.title,
      icon: icon ?? this.icon,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

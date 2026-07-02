class AboutUsModel {
  final String? key;
  final String title;
  final String description;
  final String? mission;
  final String? vision;
  final String? imageUrl;
  final int? updatedAt;

  const AboutUsModel({
    this.key,
    this.title = '',
    this.description = '',
    this.mission,
    this.vision,
    this.imageUrl,
    this.updatedAt,
  });

  bool get hasMission => (mission ?? '').trim().isNotEmpty;
  bool get hasVision => (vision ?? '').trim().isNotEmpty;
  bool get hasImage => (imageUrl ?? '').trim().isNotEmpty;
  bool get isEmpty => title.trim().isEmpty && description.trim().isEmpty;

  factory AboutUsModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return AboutUsModel(
      key: key ?? json['key']?.toString(),
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      mission: json['mission']?.toString(),
      vision: json['vision']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('key', key);
    put('title', title);
    put('description', description);
    put('mission', mission);
    put('vision', vision);
    put('imageUrl', imageUrl);
    data['updatedAt'] = updatedAt ?? DateTime.now().millisecondsSinceEpoch;
    return data;
  }

  AboutUsModel copyWith({
    String? key,
    String? title,
    String? description,
    String? mission,
    String? vision,
    String? imageUrl,
    int? updatedAt,
  }) {
    return AboutUsModel(
      key: key ?? this.key,
      title: title ?? this.title,
      description: description ?? this.description,
      mission: mission ?? this.mission,
      vision: vision ?? this.vision,
      imageUrl: imageUrl ?? this.imageUrl,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

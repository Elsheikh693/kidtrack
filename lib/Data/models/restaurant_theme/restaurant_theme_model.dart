/// Renamed to RestaurantThemeModel to avoid conflict with Flutter's ThemeData
class RestaurantThemeModel {
  final String? key;
  final String primaryColor;      // hex e.g. "#FF5722"
  final String secondaryColor;    // hex
  final String backgroundColor;   // hex e.g. "0E0C0A"
  final String? backgroundImage;  // URL
  final String? logo;             // URL
  final String? appName;
  final int? updatedAt;

  const RestaurantThemeModel({
    this.key,
    required this.primaryColor,
    required this.secondaryColor,
    this.backgroundColor = '0E0C0A',
    this.backgroundImage,
    this.logo,
    this.appName,
    this.updatedAt,
  });

  // ─── From JSON ────────────────────────────────────────────────────────────

  factory RestaurantThemeModel.fromJson(
    Map<String, dynamic> json, {
    String? key,
  }) {
    return RestaurantThemeModel(
      key: key ?? json['key']?.toString(),
      primaryColor: json['primaryColor']?.toString() ?? '#000000',
      secondaryColor: json['secondaryColor']?.toString() ?? '#FFFFFF',
      backgroundColor: json['backgroundColor']?.toString() ?? '0E0C0A',
      backgroundImage: json['backgroundImage']?.toString(),
      logo: json['logo']?.toString(),
      appName: json['appName']?.toString(),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  // ─── To JSON ──────────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};

    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('key', key);
    put('primaryColor', primaryColor);
    put('secondaryColor', secondaryColor);
    put('backgroundColor', backgroundColor);
    put('backgroundImage', backgroundImage);
    put('logo', logo);
    put('appName', appName);
    put('updatedAt', updatedAt ?? DateTime.now().millisecondsSinceEpoch);

    return data;
  }

  // ─── Copy With ────────────────────────────────────────────────────────────

  RestaurantThemeModel copyWith({
    String? key,
    String? primaryColor,
    String? secondaryColor,
    String? backgroundColor,
    String? backgroundImage,
    String? logo,
    String? appName,
    int? updatedAt,
  }) {
    return RestaurantThemeModel(
      key: key ?? this.key,
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      backgroundImage: backgroundImage ?? this.backgroundImage,
      logo: logo ?? this.logo,
      appName: appName ?? this.appName,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ─── Private Parsers ──────────────────────────────────────────────────────

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

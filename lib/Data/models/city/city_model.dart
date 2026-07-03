/// A platform-wide city (e.g. طنطا، المحلة، كفر الزيات). Global — NOT
/// nursery-scoped. Managed by the SuperAdmin and read pre-login so nurseries
/// can be tagged with a city and the Discovery list can filter by it.
class CityModel {
  final String? key;
  final String name;
  final bool isActive;
  final int? createdAt;

  const CityModel({
    this.key,
    required this.name,
    this.isActive = true,
    this.createdAt,
  });

  factory CityModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return CityModel(
      key: key ?? json['key']?.toString(),
      name: json['name']?.toString() ?? '',
      isActive: json['isActive'] == true || json['isActive'] == null,
      createdAt: _parseInt(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    data['name'] = name;
    data['isActive'] = isActive;
    put('createdAt', createdAt ?? _now());
    return data;
  }

  CityModel copyWith({
    String? key,
    String? name,
    bool? isActive,
    int? createdAt,
  }) =>
      CityModel(
        key: key ?? this.key,
        name: name ?? this.name,
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

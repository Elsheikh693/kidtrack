class BranchModel {
  final String? key;
  final String nurseryId;
  final String name;
  final String? address;
  final String? phone;
  final String? whatsapp;
  final double? lat;
  final double? lng;
  final bool isActive;
  final bool isMain;
  final int? capacity;
  final int? createdAt;
  final int? updatedAt;

  const BranchModel({
    this.key,
    required this.nurseryId,
    required this.name,
    this.address,
    this.phone,
    this.whatsapp,
    this.lat,
    this.lng,
    this.isActive = true,
    this.isMain = false,
    this.capacity,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasLocation => lat != null && lng != null;

  factory BranchModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return BranchModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      lat: _parseDouble(json['lat']),
      lng: _parseDouble(json['lng']),
      isActive: _parseBool(json['isActive']),
      isMain: _parseBool(json['isMain'], fallback: false),
      capacity: _parseInt(json['capacity']),
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    put('nurseryId', nurseryId);
    put('name', name);
    put('address', address);
    put('phone', phone);
    put('whatsapp', whatsapp);
    put('lat', lat);
    put('lng', lng);
    data['isActive'] = isActive;
    data['isMain'] = isMain;
    put('capacity', capacity);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  BranchModel copyWith({
    String? key, String? nurseryId, String? name, String? address,
    String? phone, String? whatsapp, double? lat, double? lng,
    bool? isActive, bool? isMain,
    int? capacity, int? createdAt, int? updatedAt,
  }) => BranchModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    name: name ?? this.name, address: address ?? this.address,
    phone: phone ?? this.phone, whatsapp: whatsapp ?? this.whatsapp,
    lat: lat ?? this.lat, lng: lng ?? this.lng,
    isActive: isActive ?? this.isActive, isMain: isMain ?? this.isMain,
    capacity: capacity ?? this.capacity,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
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
  static double? _parseDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

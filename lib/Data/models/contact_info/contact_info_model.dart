class ContactInfoModel {
  final String? key;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? address;
  final double? lat;
  final double? lng;
  final String? facebook;
  final String? instagram;
  final String? tiktok;
  final String? youtube;
  final String? website;
  final String? workingHours;
  final int? updatedAt;

  const ContactInfoModel({
    this.key,
    this.phone,
    this.whatsapp,
    this.email,
    this.address,
    this.lat,
    this.lng,
    this.facebook,
    this.instagram,
    this.tiktok,
    this.youtube,
    this.website,
    this.workingHours,
    this.updatedAt,
  });

  bool get hasPhone => (phone ?? '').trim().isNotEmpty;
  bool get hasWhatsapp => (whatsapp ?? '').trim().isNotEmpty;
  bool get hasEmail => (email ?? '').trim().isNotEmpty;
  bool get hasAddress => (address ?? '').trim().isNotEmpty;
  bool get hasLocation => lat != null && lng != null;
  bool get hasWorkingHours => (workingHours ?? '').trim().isNotEmpty;
  bool get hasFacebook => (facebook ?? '').trim().isNotEmpty;
  bool get hasInstagram => (instagram ?? '').trim().isNotEmpty;
  bool get hasTiktok => (tiktok ?? '').trim().isNotEmpty;
  bool get hasYoutube => (youtube ?? '').trim().isNotEmpty;
  bool get hasWebsite => (website ?? '').trim().isNotEmpty;
  bool get hasAnySocial =>
      hasFacebook || hasInstagram || hasTiktok || hasYoutube || hasWebsite;

  factory ContactInfoModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return ContactInfoModel(
      key: key ?? json['key']?.toString(),
      phone: json['phone']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      lat: _parseDouble(json['lat']),
      lng: _parseDouble(json['lng']),
      facebook: json['facebook']?.toString(),
      instagram: json['instagram']?.toString(),
      tiktok: json['tiktok']?.toString(),
      youtube: json['youtube']?.toString(),
      website: json['website']?.toString(),
      workingHours: json['workingHours']?.toString(),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('key', key);
    put('phone', phone);
    put('whatsapp', whatsapp);
    put('email', email);
    put('address', address);
    put('lat', lat);
    put('lng', lng);
    put('facebook', facebook);
    put('instagram', instagram);
    put('tiktok', tiktok);
    put('youtube', youtube);
    put('website', website);
    put('workingHours', workingHours);
    data['updatedAt'] = updatedAt ?? DateTime.now().millisecondsSinceEpoch;
    return data;
  }

  ContactInfoModel copyWith({
    String? key,
    String? phone,
    String? whatsapp,
    String? email,
    String? address,
    double? lat,
    double? lng,
    String? facebook,
    String? instagram,
    String? tiktok,
    String? youtube,
    String? website,
    String? workingHours,
    int? updatedAt,
  }) {
    return ContactInfoModel(
      key: key ?? this.key,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      email: email ?? this.email,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      facebook: facebook ?? this.facebook,
      instagram: instagram ?? this.instagram,
      tiktok: tiktok ?? this.tiktok,
      youtube: youtube ?? this.youtube,
      website: website ?? this.website,
      workingHours: workingHours ?? this.workingHours,
      updatedAt: updatedAt ?? this.updatedAt,
    );
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

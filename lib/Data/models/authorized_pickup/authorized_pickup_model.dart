class AuthorizedPickupModel {
  final String? key;
  final String nurseryId;
  final String childId;
  final String name;
  final String relationship; // father, mother, grandfather, grandmother, uncle, aunt, driver, other
  final String? phone;
  final String? idNumber;
  final String? idImage; // photo of the person's ID card
  final String? profileImage;
  final bool isActive;
  // null = permanent, set = valid until end of that day (milliseconds)
  final int? validUntil;
  final String? addedBy; // guardian uid who added this person
  final int? createdAt;
  final int? updatedAt;

  const AuthorizedPickupModel({
    this.key,
    required this.nurseryId,
    required this.childId,
    required this.name,
    this.relationship = 'other',
    this.phone,
    this.idNumber,
    this.idImage,
    this.profileImage,
    this.isActive = true,
    this.validUntil,
    this.addedBy,
    this.createdAt,
    this.updatedAt,
  });

  // true = permanent, false = expires today
  bool get isPermanent => validUntil == null;

  // still valid right now?
  bool get isCurrentlyValid {
    if (!isActive) return false;
    if (validUntil == null) return true;
    return DateTime.now().millisecondsSinceEpoch <= validUntil!;
  }

  factory AuthorizedPickupModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return AuthorizedPickupModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      relationship: json['relationship']?.toString() ?? 'other',
      phone: json['phone']?.toString(),
      idNumber: json['idNumber']?.toString(),
      idImage: json['idImage']?.toString(),
      profileImage: json['profileImage']?.toString(),
      isActive: _parseBool(json['isActive']),
      validUntil: _parseInt(json['validUntil']),
      addedBy: json['addedBy']?.toString(),
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    put('nurseryId', nurseryId);
    put('childId', childId);
    put('name', name);
    data['relationship'] = relationship;
    put('phone', phone);
    put('idNumber', idNumber);
    put('idImage', idImage);
    put('profileImage', profileImage);
    data['isActive'] = isActive;
    put('validUntil', validUntil);
    put('addedBy', addedBy);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  AuthorizedPickupModel copyWith({
    String? key, String? nurseryId, String? childId, String? name,
    String? relationship, String? phone, String? idNumber, String? idImage,
    String? profileImage, bool? isActive, int? validUntil,
    String? addedBy, int? createdAt, int? updatedAt,
  }) => AuthorizedPickupModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    childId: childId ?? this.childId, name: name ?? this.name,
    relationship: relationship ?? this.relationship, phone: phone ?? this.phone,
    idNumber: idNumber ?? this.idNumber, idImage: idImage ?? this.idImage,
    profileImage: profileImage ?? this.profileImage,
    isActive: isActive ?? this.isActive,
    validUntil: validUntil ?? this.validUntil,
    addedBy: addedBy ?? this.addedBy,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) return v == '1' || v.toLowerCase() == 'true';
    return true;
  }
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

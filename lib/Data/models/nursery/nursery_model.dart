import '../application_form/application_form_model.dart';

class NurseryModel {
  final String? key;
  final String name;
  final String? logo;
  final String? phone;
  final String? whatsapp;
  final String? email;
  final String? address;
  final String? ownerId;
  final List<String> ownerIds;
  final bool isActive;

  /// Owner-controlled discovery visibility. When false the nursery is hidden
  /// from the pre-login Discovery list even if [isActive] is true. Distinct
  /// from [isActive] (a SuperAdmin account suspend). Defaults to false so a
  /// freshly created / incomplete nursery is never listed until its owner
  /// opts in. Discovery requires both `isActive && isListed`.
  final bool isListed;

  final int? createdAt;
  final int? updatedAt;

  // ─── Discovery / profile display fields ───────────────────────────────────
  final String? coverPhoto;
  final List<String> photos;
  final String? description;
  final double? lat;
  final double? lng;
  final double? rating;
  final int? reviewsCount;
  final int? childrenCount;

  // ─── Discovery filter facts ────────────────────────────────────────────────
  /// Accepted age range, stored in MONTHS (UI shows years/months).
  final int? minAgeMonths;
  final int? maxAgeMonths;

  /// One-time fee to open a child's file (سعر فتح الملف). Display only — never
  /// a filter. When [applicationFeeFree] is true it is marketed as "free".
  final double? applicationFee;
  final bool applicationFeeFree;

  /// Normalized monthly price RANGE across all active packages. Computed
  /// automatically by the package sync (never manager-entered). Powers the
  /// price filter + the card's "starts from" line. Based on ORIGINAL prices.
  final double? priceFrom;
  final double? priceTo;

  final List<String> programs;
  final List<String> activities;
  final List<NurseryBranch> branches;

  /// Terms & conditions shown to a parent before submitting an online
  /// admission application (edited by the manager in the discovery profile).
  /// Each entry is a single clause; they're added/displayed one at a time.
  final List<String> terms;

  /// Manager-authored configuration of the online application form: which
  /// sections appear, in what order, plus the dynamic assessment questions and
  /// bus note. Falls back to [ApplicationFormConfig.defaults] when unset.
  final ApplicationFormConfig applicationForm;

  /// School days of the week as Dart weekday ints (Mon=1 … Sun=7).
  /// Drives homework date defaults (next school day). Empty = not configured;
  /// callers fall back to "every day except Friday" via [effectiveWorkingDays].
  final List<int> workingDays;

  const NurseryModel({
    this.key,
    required this.name,
    this.logo,
    this.phone,
    this.whatsapp,
    this.email,
    this.address,
    this.ownerId,
    this.ownerIds = const [],
    this.isActive = true,
    this.isListed = false,
    this.createdAt,
    this.updatedAt,
    this.coverPhoto,
    this.photos = const [],
    this.description,
    this.lat,
    this.lng,
    this.rating,
    this.reviewsCount,
    this.childrenCount,
    this.minAgeMonths,
    this.maxAgeMonths,
    this.applicationFee,
    this.applicationFeeFree = false,
    this.priceFrom,
    this.priceTo,
    this.programs = const [],
    this.activities = const [],
    this.branches = const [],
    this.terms = const [],
    this.applicationForm = const ApplicationFormConfig(),
    this.workingDays = const [],
  });

  /// Configured school days, or the sensible default (every day except Friday)
  /// when a nursery has not set them yet. Always sorted Mon→Sun.
  List<int> get effectiveWorkingDays {
    final days = workingDays.where((d) => d >= 1 && d <= 7).toSet().toList();
    if (days.isEmpty) return const [1, 2, 3, 4, 6, 7]; // all except Friday(5)
    days.sort();
    return days;
  }

  factory NurseryModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return NurseryModel(
      key: key ?? json['key']?.toString(),
      name: json['name']?.toString() ?? '',
      logo: json['logo']?.toString(),
      phone: json['phone']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      email: json['email']?.toString(),
      address: json['address']?.toString(),
      ownerId: json['ownerId']?.toString(),
      ownerIds: _parseOwnerIds(json['ownerIds'], json['ownerId']),
      isActive: _parseBool(json['isActive']),
      isListed: _parseBool(json['isListed'], fallback: false),
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
      coverPhoto: json['coverPhoto']?.toString(),
      photos: _parseStringList(json['photos']),
      description: json['description']?.toString(),
      lat: _parseDouble(json['lat']),
      lng: _parseDouble(json['lng']),
      rating: _parseDouble(json['rating']),
      reviewsCount: _parseInt(json['reviewsCount']),
      childrenCount: _parseInt(json['childrenCount']),
      minAgeMonths: _parseInt(json['minAgeMonths']),
      maxAgeMonths: _parseInt(json['maxAgeMonths']),
      applicationFee: _parseDouble(json['applicationFee']),
      applicationFeeFree: _parseBool(json['applicationFeeFree'], fallback: false),
      priceFrom: _parseDouble(json['priceFrom']),
      priceTo: _parseDouble(json['priceTo']),
      programs: _parseStringList(json['programs']),
      activities: _parseStringList(json['activities']),
      branches: NurseryBranch.parseList(json['branches']),
      terms: _parseTerms(json['terms']),
      applicationForm: ApplicationFormConfig.fromJson(json['applicationForm']),
      workingDays: _parseIntList(json['workingDays']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    put('name', name);
    put('logo', logo);
    put('phone', phone);
    put('whatsapp', whatsapp);
    put('email', email);
    put('address', address);
    final owners = allOwnerIds;
    put('ownerId', owners.isNotEmpty ? owners.first : ownerId);
    if (owners.isNotEmpty) data['ownerIds'] = owners;
    data['isActive'] = isActive;
    data['isListed'] = isListed;
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    put('coverPhoto', coverPhoto);
    if (photos.isNotEmpty) data['photos'] = photos;
    put('description', description);
    put('lat', lat);
    put('lng', lng);
    put('rating', rating);
    put('reviewsCount', reviewsCount);
    put('childrenCount', childrenCount);
    put('minAgeMonths', minAgeMonths);
    put('maxAgeMonths', maxAgeMonths);
    put('applicationFee', applicationFee);
    data['applicationFeeFree'] = applicationFeeFree;
    put('priceFrom', priceFrom);
    put('priceTo', priceTo);
    if (programs.isNotEmpty) data['programs'] = programs;
    if (activities.isNotEmpty) data['activities'] = activities;
    if (branches.isNotEmpty) {
      data['branches'] = branches.map((b) => b.toJson()).toList();
    }
    if (terms.isNotEmpty) data['terms'] = terms;
    if (applicationForm.sections.isNotEmpty) {
      data['applicationForm'] = applicationForm.toJson();
    }
    if (workingDays.isNotEmpty) data['workingDays'] = workingDays;
    return data;
  }

  NurseryModel copyWith({
    String? key, String? name, String? logo, String? phone, String? whatsapp,
    String? email, String? address, String? ownerId, List<String>? ownerIds,
    bool? isActive, bool? isListed, int? createdAt, int? updatedAt,
    String? coverPhoto, List<String>? photos, String? description,
    double? lat, double? lng, double? rating, int? reviewsCount,
    int? childrenCount,
    int? minAgeMonths, int? maxAgeMonths,
    double? applicationFee, bool? applicationFeeFree,
    double? priceFrom, double? priceTo,
    List<String>? programs, List<String>? activities,
    List<NurseryBranch>? branches,
    List<String>? terms,
    ApplicationFormConfig? applicationForm,
    List<int>? workingDays,
  }) => NurseryModel(
    key: key ?? this.key, name: name ?? this.name,
    logo: logo ?? this.logo, phone: phone ?? this.phone,
    whatsapp: whatsapp ?? this.whatsapp,
    email: email ?? this.email, address: address ?? this.address,
    ownerId: ownerId ?? this.ownerId, ownerIds: ownerIds ?? this.ownerIds,
    isActive: isActive ?? this.isActive,
    isListed: isListed ?? this.isListed,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
    coverPhoto: coverPhoto ?? this.coverPhoto, photos: photos ?? this.photos,
    description: description ?? this.description,
    lat: lat ?? this.lat, lng: lng ?? this.lng, rating: rating ?? this.rating,
    reviewsCount: reviewsCount ?? this.reviewsCount,
    childrenCount: childrenCount ?? this.childrenCount,
    minAgeMonths: minAgeMonths ?? this.minAgeMonths,
    maxAgeMonths: maxAgeMonths ?? this.maxAgeMonths,
    applicationFee: applicationFee ?? this.applicationFee,
    applicationFeeFree: applicationFeeFree ?? this.applicationFeeFree,
    priceFrom: priceFrom ?? this.priceFrom,
    priceTo: priceTo ?? this.priceTo,
    programs: programs ?? this.programs, activities: activities ?? this.activities,
    branches: branches ?? this.branches,
    terms: terms ?? this.terms,
    applicationForm: applicationForm ?? this.applicationForm,
    workingDays: workingDays ?? this.workingDays,
  );

  /// Merged, de-duplicated list of all owner uids (includes the legacy
  /// single [ownerId] so old single-owner records keep working).
  List<String> get allOwnerIds {
    final result = <String>[];
    for (final id in ownerIds) {
      if (id.isNotEmpty && !result.contains(id)) result.add(id);
    }
    if ((ownerId ?? '').isNotEmpty && !result.contains(ownerId)) {
      result.add(ownerId!);
    }
    return result;
  }

  int get ownerCount => allOwnerIds.length;

  static List<String> _parseOwnerIds(dynamic v, dynamic legacy) {
    final result = <String>[];
    void addAll(Iterable<dynamic> raw) {
      for (final e in raw) {
        final s = e?.toString() ?? '';
        if (s.isNotEmpty && !result.contains(s)) result.add(s);
      }
    }
    if (v is List) {
      addAll(v);
    } else if (v is Map) {
      addAll(v.values);
    }
    final legacyStr = legacy?.toString() ?? '';
    if (legacyStr.isNotEmpty && !result.contains(legacyStr)) {
      result.add(legacyStr);
    }
    return result;
  }

  /// True when the nursery accepts a child of [ageMonths].
  bool acceptsAgeMonths(int ageMonths) {
    if (minAgeMonths != null && ageMonths < minAgeMonths!) return false;
    if (maxAgeMonths != null && ageMonths > maxAgeMonths!) return false;
    return minAgeMonths != null || maxAgeMonths != null;
  }

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
  static List<String> _parseStringList(dynamic v) {
    if (v == null) return const [];
    if (v is List) return v.map((e) => e.toString()).toList();
    if (v is Map) return v.values.map((e) => e.toString()).toList();
    return const [];
  }

  static List<int> _parseIntList(dynamic v) {
    Iterable<dynamic>? raw;
    if (v is List) raw = v;
    if (v is Map) raw = v.values;
    if (raw == null) return const [];
    return raw
        .map((e) => _parseInt(e))
        .whereType<int>()
        .toList();
  }

  /// Terms were historically stored as a single newline-separated String;
  /// they're now a list of clauses. This parses both shapes so old records
  /// keep working (each line of the old String becomes a separate clause).
  static List<String> _parseTerms(dynamic v) {
    if (v == null) return const [];
    if (v is List) {
      return v
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (v is Map) {
      return v.values
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    if (v is String) {
      return v
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return const [];
  }
}

/// A single physical branch of a nursery (multi-location support).
class NurseryBranch {
  final String name;
  final String? address;
  final String? phone;
  final String? whatsapp;
  final double? lat;
  final double? lng;

  const NurseryBranch({
    required this.name,
    this.address,
    this.phone,
    this.whatsapp,
    this.lat,
    this.lng,
  });

  bool get hasLocation => lat != null && lng != null;

  factory NurseryBranch.fromJson(Map<String, dynamic> json) {
    return NurseryBranch(
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      lat: NurseryModel._parseDouble(json['lat']),
      lng: NurseryModel._parseDouble(json['lng']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{'name': name};
    if ((address ?? '').isNotEmpty) data['address'] = address;
    if ((phone ?? '').isNotEmpty) data['phone'] = phone;
    if ((whatsapp ?? '').isNotEmpty) data['whatsapp'] = whatsapp;
    if (lat != null) data['lat'] = lat;
    if (lng != null) data['lng'] = lng;
    return data;
  }

  NurseryBranch copyWith({
    String? name,
    String? address,
    String? phone,
    String? whatsapp,
    double? lat,
    double? lng,
  }) => NurseryBranch(
    name: name ?? this.name,
    address: address ?? this.address,
    phone: phone ?? this.phone,
    whatsapp: whatsapp ?? this.whatsapp,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
  );

  /// Parses a list (RTDB may store as List or Map keyed by index/id).
  static List<NurseryBranch> parseList(dynamic v) {
    if (v == null) return const [];
    Iterable<dynamic> raw;
    if (v is List) {
      raw = v;
    } else if (v is Map) {
      raw = v.values;
    } else {
      return const [];
    }
    return raw
        .whereType<Map>()
        .map((e) => NurseryBranch.fromJson(Map<String, dynamic>.from(e)))
        .where((b) => b.name.isNotEmpty)
        .toList();
  }
}

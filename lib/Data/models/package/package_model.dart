/// Number of months each [PackageModel.duration] spans, used to convert any
/// package price into an equivalent MONTHLY price so prices across durations
/// are comparable in Discovery filtering. Term defaults to 3 months.
const Map<String, int> kPackageDurationMonths = {
  'monthly': 1,
  'term': 3,
  'yearly': 12,
};

class PackageModel {
  final String? key;
  final String nurseryId;
  final String? branchId;
  final String name;
  final String? description;
  final double price;
  final String duration; // monthly, term, yearly
  final bool isActive;

  // ─── Promotion (per-package, optional) ─────────────────────────────────────
  final bool discountEnabled;
  final String discountType; // percentage | fixed
  final double discountValue;
  final int? offerStart; // epoch ms, optional
  final int? offerEnd; // epoch ms, optional

  final int? createdAt;
  final int? updatedAt;

  const PackageModel({
    this.key,
    required this.nurseryId,
    this.branchId,
    required this.name,
    this.description,
    this.price = 0,
    this.duration = 'monthly',
    this.isActive = true,
    this.discountEnabled = false,
    this.discountType = 'percentage',
    this.discountValue = 0,
    this.offerStart,
    this.offerEnd,
    this.createdAt,
    this.updatedAt,
  });

  /// Months this package's duration spans (term = 3, yearly = 12, else 1).
  int get durationMonths => kPackageDurationMonths[duration] ?? 1;

  /// Original price normalized to a monthly equivalent. This is what Discovery
  /// filters/sorts on (Option A: based on the ORIGINAL price, never the
  /// discounted one — keeps the registry summary stable when offers expire).
  double get normalizedMonthlyPrice => price / durationMonths;

  /// Whether the discount is currently in effect (enabled, has a positive
  /// value, and — if an offer window is set — today falls inside it).
  bool get hasActiveDiscount {
    if (!discountEnabled || discountValue <= 0) return false;
    final now = DateTime.now().millisecondsSinceEpoch;
    if (offerStart != null && now < offerStart!) return false;
    if (offerEnd != null && now > offerEnd!) return false;
    return finalPrice < price;
  }

  /// The discounted monthly amount a subscribed child owes each month —
  /// [finalPrice] spread across the package's duration. Drives monthly billing.
  double get monthlyDue => finalPrice / durationMonths;

  /// Price after applying the discount (clamped to ≥ 0). Equals [price] when no
  /// discount is configured.
  double get finalPrice {
    if (!discountEnabled || discountValue <= 0) return price;
    final discounted = discountType == 'fixed'
        ? price - discountValue
        : price * (1 - discountValue / 100);
    return discounted < 0 ? 0 : discounted;
  }

  factory PackageModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return PackageModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      branchId: json['branchId']?.toString(),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      price: _parseDouble(json['price']),
      duration: json['duration']?.toString() ?? 'monthly',
      isActive: _parseBool(json['isActive']),
      discountEnabled: _parseBool(json['discountEnabled'], fallback: false),
      discountType: json['discountType']?.toString() ?? 'percentage',
      discountValue: _parseDouble(json['discountValue']),
      offerStart: _parseInt(json['offerStart']),
      offerEnd: _parseInt(json['offerEnd']),
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    put('nurseryId', nurseryId);
    put('branchId', branchId);
    put('name', name);
    put('description', description);
    data['price'] = price;
    data['duration'] = duration;
    data['isActive'] = isActive;
    data['discountEnabled'] = discountEnabled;
    data['discountType'] = discountType;
    data['discountValue'] = discountValue;
    put('offerStart', offerStart);
    put('offerEnd', offerEnd);
    // Denormalized for querying/debugging; always derived from price+duration.
    data['normalizedMonthlyPrice'] = normalizedMonthlyPrice;
    data['finalPrice'] = finalPrice;
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  PackageModel copyWith({
    String? key, String? nurseryId, String? branchId, String? name, String? description,
    double? price, String? duration, bool? isActive,
    bool? discountEnabled, String? discountType, double? discountValue,
    int? offerStart, int? offerEnd,
    int? createdAt, int? updatedAt,
  }) => PackageModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    branchId: branchId ?? this.branchId,
    name: name ?? this.name, description: description ?? this.description,
    price: price ?? this.price, duration: duration ?? this.duration,
    isActive: isActive ?? this.isActive,
    discountEnabled: discountEnabled ?? this.discountEnabled,
    discountType: discountType ?? this.discountType,
    discountValue: discountValue ?? this.discountValue,
    offerStart: offerStart ?? this.offerStart,
    offerEnd: offerEnd ?? this.offerEnd,
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
  static double _parseDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString()) ?? 0;
  }
}

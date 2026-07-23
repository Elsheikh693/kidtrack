/// A daily attendance shift a nursery runs (صباحي، بيني، مسائي…).
///
/// Shifts used to be three hard-coded strings ('morning' | 'between' |
/// 'evening') stored on [ChildModel.shift]. They are now editable records with
/// real times so arrival lateness can be derived automatically: a child is late
/// when their check-in is past [startMinutes] + [graceMinutes] of their shift.
///
/// The three original shifts are seeded with their ORIGINAL keys
/// ('morning'/'between'/'evening') so existing `child.shift` values keep
/// resolving — see [ShiftDefaults].
class ShiftModel {
  final String? key;
  final String nurseryId;
  final String name;

  /// Start of the shift as minutes from midnight (e.g. 8:00 → 480).
  final int startMinutes;

  /// End of the shift as minutes from midnight (e.g. 12:00 → 720).
  final int endMinutes;

  /// Tolerance before a check-in counts as late. Default 15 minutes.
  final int graceMinutes;

  final bool isActive;
  final int sortOrder;
  final int? createdAt;

  const ShiftModel({
    this.key,
    required this.nurseryId,
    required this.name,
    required this.startMinutes,
    required this.endMinutes,
    this.graceMinutes = 15,
    this.isActive = true,
    this.sortOrder = 0,
    this.createdAt,
  });

  /// The latest minute-of-day that still counts as on time.
  int get onTimeCutoff => startMinutes + graceMinutes;

  /// "08:00 AM" style label, locale-independent (no BuildContext needed).
  String get startLabel => formatMinutes(startMinutes);
  String get endLabel => formatMinutes(endMinutes);

  /// Whether a check-in at [checkInEpochMs] (local time) is late for this shift.
  /// Returns false when there is no check-in time to judge.
  bool isLateAt(int? checkInEpochMs) {
    if (checkInEpochMs == null) return false;
    final t = DateTime.fromMillisecondsSinceEpoch(checkInEpochMs);
    final minuteOfDay = t.hour * 60 + t.minute;
    return minuteOfDay > onTimeCutoff;
  }

  /// Minutes late relative to the shift start (before grace). Negative or zero
  /// means the child arrived on time or early. Null when there is no check-in.
  int? minutesLate(int? checkInEpochMs) {
    if (checkInEpochMs == null) return null;
    final t = DateTime.fromMillisecondsSinceEpoch(checkInEpochMs);
    final minuteOfDay = t.hour * 60 + t.minute;
    return minuteOfDay - startMinutes;
  }

  static String formatMinutes(int minutes) {
    final h24 = (minutes ~/ 60) % 24;
    final m = minutes % 60;
    final period = h24 < 12 ? 'AM' : 'PM';
    var h12 = h24 % 12;
    if (h12 == 0) h12 = 12;
    final mm = m.toString().padLeft(2, '0');
    return '$h12:$mm $period';
  }

  factory ShiftModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return ShiftModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      startMinutes: _parseInt(json['startMinutes']) ?? 0,
      endMinutes: _parseInt(json['endMinutes']) ?? 0,
      graceMinutes: _parseInt(json['graceMinutes']) ?? 15,
      isActive: json['isActive'] == true || json['isActive'] == null,
      sortOrder: _parseInt(json['sortOrder']) ?? 0,
      createdAt: _parseInt(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('key', key);
    put('nurseryId', nurseryId);
    data['name'] = name;
    data['startMinutes'] = startMinutes;
    data['endMinutes'] = endMinutes;
    data['graceMinutes'] = graceMinutes;
    data['isActive'] = isActive;
    data['sortOrder'] = sortOrder;
    put('createdAt', createdAt ?? _now());
    return data;
  }

  ShiftModel copyWith({
    String? key,
    String? nurseryId,
    String? name,
    int? startMinutes,
    int? endMinutes,
    int? graceMinutes,
    bool? isActive,
    int? sortOrder,
    int? createdAt,
  }) =>
      ShiftModel(
        key: key ?? this.key,
        nurseryId: nurseryId ?? this.nurseryId,
        name: name ?? this.name,
        startMinutes: startMinutes ?? this.startMinutes,
        endMinutes: endMinutes ?? this.endMinutes,
        graceMinutes: graceMinutes ?? this.graceMinutes,
        isActive: isActive ?? this.isActive,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt ?? this.createdAt,
      );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}

/// The three shifts seeded the first time the shifts settings screen is opened.
/// Keys MATCH the legacy [ChildModel.shift] strings so existing children stay
/// linked. Times are sensible defaults the owner can edit per nursery.
class ShiftDefaults {
  ShiftDefaults._();

  static const List<({String key, String nameKey, int start, int end})> seed = [
    (key: 'morning', nameKey: 'shift_morning', start: 480, end: 720), //  8:00–12:00
    (key: 'between', nameKey: 'shift_between', start: 720, end: 900), // 12:00–15:00
    (key: 'evening', nameKey: 'shift_evening', start: 900, end: 1080), // 15:00–18:00
  ];
}

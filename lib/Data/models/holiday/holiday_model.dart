/// A single nursery-wide day off. Stored under
/// `platform/{nurseryId}/holidays/{yyyy-MM-dd}` — keyed by the day so marking
/// the same date twice is idempotent and "is this day a holiday" is a direct
/// key lookup.
class HolidayModel {
  final String key; // yyyy-MM-dd
  final int date; // midnight of the day, ms since epoch
  final String label; // e.g. "عيد الفطر" — empty falls back to "إجازة"
  final String? createdBy;
  final int? createdAt;

  const HolidayModel({
    required this.key,
    required this.date,
    this.label = '',
    this.createdBy,
    this.createdAt,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return HolidayModel(
      key: key ?? json['key']?.toString() ?? '',
      date: _parseInt(json['date']) ?? 0,
      label: json['label']?.toString() ?? '',
      createdBy: json['createdBy']?.toString(),
      createdAt: _parseInt(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    data['date'] = date;
    data['label'] = label;
    put('createdBy', createdBy);
    put('createdAt', createdAt ?? _now());
    return data;
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(date);

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

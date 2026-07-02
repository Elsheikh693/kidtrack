// Firebase path: platform/{nurseryId}/careEvents
// eventType values: meal | bathroom | diaper | sleep_start | sleep_end | mood
// Meal key format : {childId}_{date}_meal_{mealType}  (predictable → overwrites)
// Mood key format : {childId}_{date}_mood             (predictable → overwrites)
// All other events: push() key

class CareEventModel {
  final String? key;
  final String nurseryId;
  final String branchId;
  final String childId;
  final String nannyId;
  final String date; // "2024-01-15"
  final String eventType;

  // meal fields
  final String? mealType;   // breakfast | lunch | snack
  final String? mealStatus; // ate_all | ate_half | refused

  // bathroom field
  final String? bathroomType; // urine | potty

  // mood field
  final String? mood; // happy | neutral | sad

  // sleep_end references its sleep_start key
  final String? sessionId;

  final int timestamp;
  final int? createdAt;

  const CareEventModel({
    this.key,
    required this.nurseryId,
    required this.branchId,
    required this.childId,
    required this.nannyId,
    required this.date,
    required this.eventType,
    this.mealType,
    this.mealStatus,
    this.bathroomType,
    this.mood,
    this.sessionId,
    required this.timestamp,
    this.createdAt,
  });

  factory CareEventModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return CareEventModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      nannyId: json['nannyId']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? '',
      mealType: json['mealType']?.toString(),
      mealStatus: json['mealStatus']?.toString(),
      bathroomType: json['bathroomType']?.toString(),
      mood: json['mood']?.toString(),
      sessionId: json['sessionId']?.toString(),
      timestamp: _parseInt(json['timestamp']) ?? 0,
      createdAt: _parseInt(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('key', key);
    data['nurseryId'] = nurseryId;
    data['branchId'] = branchId;
    data['childId'] = childId;
    data['nannyId'] = nannyId;
    data['date'] = date;
    data['eventType'] = eventType;
    put('mealType', mealType);
    put('mealStatus', mealStatus);
    put('bathroomType', bathroomType);
    put('mood', mood);
    put('sessionId', sessionId);
    data['timestamp'] = timestamp;
    data['createdAt'] = createdAt ?? timestamp;
    return data;
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

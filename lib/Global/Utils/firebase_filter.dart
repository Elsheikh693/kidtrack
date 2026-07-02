import 'dart:convert';

class FirebaseFilter {
  String? orderBy;
  dynamic equalTo; // This can be of various types
  dynamic startAt;
  dynamic endAt;
  int? limitToFirst;
  int? limitToLast;

  FirebaseFilter({
    this.orderBy,
    this.equalTo,
    this.startAt,
    this.endAt,
    this.limitToFirst,
    this.limitToLast,
  });

  // Convert to Map<String, dynamic> for the Firebase query parameters.
  // Values are JSON-encoded so they can be passed to your filtering functions.
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> filterData = {};
    if (orderBy != null) filterData['orderBy'] = jsonEncode(orderBy);
    if (equalTo != null) filterData['equalTo'] = jsonEncode(equalTo);
    if (startAt != null) filterData['startAt'] = jsonEncode(startAt);
    if (endAt != null) filterData['endAt'] = jsonEncode(endAt);
    if (limitToFirst != null) filterData['limitToFirst'] = jsonEncode(limitToFirst);
    if (limitToLast != null) filterData['limitToLast'] = jsonEncode(limitToLast);
    return filterData;
  }

  // Create an instance of FirebaseFilter from a Map<String, dynamic>.
  factory FirebaseFilter.fromMap(Map<String, dynamic> map) {
    return FirebaseFilter(
      orderBy: map['orderBy'] != null ? jsonDecode(map['orderBy']) : null,
      equalTo: map['equalTo'] != null ? jsonDecode(map['equalTo']) : null,
      startAt: map['startAt'] != null ? jsonDecode(map['startAt']) : null,
      endAt: map['endAt'] != null ? jsonDecode(map['endAt']) : null,
      limitToFirst: map['limitToFirst'] != null ? jsonDecode(map['limitToFirst']) : null,
      limitToLast: map['limitToLast'] != null ? jsonDecode(map['limitToLast']) : null,
    );
  }
}

// Firebase path: platform/{nurseryId}/childCurrentStatus/{childId}
// Cache — overwritten on every status change.
// Teacher NEVER writes here. Teacher activity is read separately from classroomActivities.
//
// status values:
//   not_arrived | checked_in | having_meal | sleeping | on_bus
//   pickup_requested | checked_out

class ChildCurrentStatusModel {
  final String childId;
  final String status;

  // true when a parent pickup request is active — orthogonal to status
  final bool pickupRequested;

  final DateTime? statusStartedAt;
  final DateTime updatedAt;

  final String updatedById;
  final String updatedByRole; // reception | nanny | bus | parent

  // optional: set on check_in, cleared on check_out
  final DateTime? checkInTime;
  final DateTime? checkOutTime;

  // ── Child Current State (teacher-managed, separate from attendance) ────────
  // null = default state ('with_classroom') — child is participating normally
  final String? currentStateId;
  final String? currentStateTitle;
  final int? currentStateStartedAt; // epoch ms

  const ChildCurrentStatusModel({
    required this.childId,
    required this.status,
    this.pickupRequested = false,
    this.statusStartedAt,
    required this.updatedAt,
    required this.updatedById,
    required this.updatedByRole,
    this.checkInTime,
    this.checkOutTime,
    this.currentStateId,
    this.currentStateTitle,
    this.currentStateStartedAt,
  });

  factory ChildCurrentStatusModel.fromJson(
      Map<String, dynamic> json, {
      required String childId,
    }) {
    return ChildCurrentStatusModel(
      childId: childId,
      status: json['status']?.toString() ?? ChildStatus.notArrived,
      pickupRequested: json['pickupRequested'] == true,
      statusStartedAt: _parseDate(json['statusStartedAt']),
      updatedAt: _parseDate(json['updatedAt']) ?? DateTime.now(),
      updatedById: json['updatedById']?.toString() ?? '',
      updatedByRole: json['updatedByRole']?.toString() ?? '',
      checkInTime: _parseDate(json['checkInTime']),
      checkOutTime: _parseDate(json['checkOutTime']),
      currentStateId: json['currentStateId']?.toString(),
      currentStateTitle: json['currentStateTitle']?.toString(),
      currentStateStartedAt: json['currentStateStartedAt'] is int
          ? json['currentStateStartedAt'] as int
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'childId': childId,
      'status': status,
      'pickupRequested': pickupRequested,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
      'updatedById': updatedById,
      'updatedByRole': updatedByRole,
    };
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('statusStartedAt', statusStartedAt?.millisecondsSinceEpoch);
    put('checkInTime', checkInTime?.millisecondsSinceEpoch);
    put('checkOutTime', checkOutTime?.millisecondsSinceEpoch);
    put('currentStateId', currentStateId);
    put('currentStateTitle', currentStateTitle);
    put('currentStateStartedAt', currentStateStartedAt);
    return data;
  }

  ChildCurrentStatusModel copyWith({
    String? status,
    bool? pickupRequested,
    DateTime? statusStartedAt,
    DateTime? updatedAt,
    String? updatedById,
    String? updatedByRole,
    DateTime? checkInTime,
    DateTime? checkOutTime,
    String? currentStateId,
    String? currentStateTitle,
    int? currentStateStartedAt,
  }) {
    return ChildCurrentStatusModel(
      childId: childId,
      status: status ?? this.status,
      pickupRequested: pickupRequested ?? this.pickupRequested,
      statusStartedAt: statusStartedAt ?? this.statusStartedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedById: updatedById ?? this.updatedById,
      updatedByRole: updatedByRole ?? this.updatedByRole,
      checkInTime: checkInTime ?? this.checkInTime,
      checkOutTime: checkOutTime ?? this.checkOutTime,
      currentStateId: currentStateId ?? this.currentStateId,
      currentStateTitle: currentStateTitle ?? this.currentStateTitle,
      currentStateStartedAt:
          currentStateStartedAt ?? this.currentStateStartedAt,
    );
  }

  static DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    final ms = v is int ? v : int.tryParse(v.toString());
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }
}

// All valid status string constants.
abstract class ChildStatus {
  static const notArrived = 'not_arrived';
  static const checkedIn = 'checked_in';
  static const havingMeal = 'having_meal';
  static const sleeping = 'sleeping';
  static const onBus = 'on_bus';
  static const pickupRequested = 'pickup_requested';
  static const checkedOut = 'checked_out';
}

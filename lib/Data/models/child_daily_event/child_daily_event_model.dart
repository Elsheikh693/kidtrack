// Firebase path: platform/{nurseryId}/childDailyEvents/{date}/{childId}/{eventId}
// Append-only journal — nothing is ever deleted or overwritten.
//
// eventType values:
//   check_in | check_out
//   meal_started | meal_completed
//   nap_started  | nap_completed
//   bathroom
//   pickup_requested
//   bus_boarded | bus_arrived
//   activity_started | activity_completed   ← written by Cloud Function fan-out
//   note_added | medicine_given
//
// source values: reception | nanny | bus | parent | teacher | system

class ChildDailyEventModel {
  final String id;
  final String childId;
  final String nurseryId;
  final String branchId;
  final String eventType;
  final String source;

  // human-readable label (already localised by the writer)
  final String? title;
  final String? description;

  // optional references
  final String? activityId;    // classroomActivity key (activity_started/completed)
  final String? classroomId;
  final String? subjectName;   // denormalised from subject at write-time

  // meta for special event types
  final String? mealType;      // breakfast | lunch | snack
  final String? mealStatus;    // ate_all | ate_half | refused
  final String? sessionId;     // pairs nap_started ↔ nap_completed

  final String? createdBy;
  final String? createdByRole;
  final int createdAt; // epoch ms

  const ChildDailyEventModel({
    required this.id,
    required this.childId,
    required this.nurseryId,
    required this.branchId,
    required this.eventType,
    required this.source,
    this.title,
    this.description,
    this.activityId,
    this.classroomId,
    this.subjectName,
    this.mealType,
    this.mealStatus,
    this.sessionId,
    this.createdBy,
    this.createdByRole,
    required this.createdAt,
  });

  factory ChildDailyEventModel.fromJson(
      Map<String, dynamic> json, {
      required String id,
    }) {
    return ChildDailyEventModel(
      id: id,
      childId: json['childId']?.toString() ?? '',
      nurseryId: json['nurseryId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      eventType: json['eventType']?.toString() ?? '',
      source: json['source']?.toString() ?? 'system',
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      activityId: json['activityId']?.toString(),
      classroomId: json['classroomId']?.toString(),
      subjectName: json['subjectName']?.toString(),
      mealType: json['mealType']?.toString(),
      mealStatus: json['mealStatus']?.toString(),
      sessionId: json['sessionId']?.toString(),
      createdBy: json['createdBy']?.toString(),
      createdByRole: json['createdByRole']?.toString(),
      createdAt: _parseInt(json['createdAt']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'childId': childId,
      'nurseryId': nurseryId,
      'branchId': branchId,
      'eventType': eventType,
      'source': source,
      'createdAt': createdAt,
    };
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('title', title);
    put('description', description);
    put('activityId', activityId);
    put('classroomId', classroomId);
    put('subjectName', subjectName);
    put('mealType', mealType);
    put('mealStatus', mealStatus);
    put('sessionId', sessionId);
    put('createdBy', createdBy);
    put('createdByRole', createdByRole);
    return data;
  }

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

// All valid eventType string constants — avoids magic strings in callers.
abstract class ChildEventType {
  static const checkIn = 'check_in';
  static const checkOut = 'check_out';

  static const mealStarted = 'meal_started';
  static const mealCompleted = 'meal_completed';

  static const napStarted = 'nap_started';
  static const napCompleted = 'nap_completed';

  static const bathroom = 'bathroom';

  static const pickupRequested = 'pickup_requested';

  static const busBoarded = 'bus_boarded';
  static const busArrived = 'bus_arrived';

  static const activityStarted = 'activity_started';
  static const activityCompleted = 'activity_completed';

  static const homeworkAssigned = 'homework_assigned';

  static const noteAdded = 'note_added';
  static const medicineGiven = 'medicine_given';

  // Teacher changes a child's current real-world state (sleeping, eating, etc.)
  static const childStateChanged = 'child_state_changed';
}

// All valid source string constants.
abstract class ChildEventSource {
  static const reception = 'reception';
  static const nanny = 'nanny';
  static const bus = 'bus';
  static const parent = 'parent';
  static const teacher = 'teacher';
  static const system = 'system';
}

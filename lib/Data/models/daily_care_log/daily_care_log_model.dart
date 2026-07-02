class DailyCareLogModel {
  final String? key;
  final String nurseryId;
  final String childId;
  final String classroomId;
  final String recordedBy; // nanny or teacher uid
  final String date;       // "2024-01-15"

  // Meals
  final String? breakfastStatus;  // ate_all, ate_some, did_not_eat
  final String? lunchStatus;
  final String? snackStatus;
  final String? mealNotes;

  // Sleep
  final int? sleepStart;          // timestamp
  final int? sleepEnd;
  final String? sleepNotes;

  // Bathroom
  final int bathroomCount;
  final int diaperChanges;

  // Mood & notes
  final String? mood;             // happy, calm, cranky, sick
  final String? notes;

  final int? createdAt;
  final int? updatedAt;

  const DailyCareLogModel({
    this.key,
    required this.nurseryId,
    required this.childId,
    required this.classroomId,
    required this.recordedBy,
    required this.date,
    this.breakfastStatus,
    this.lunchStatus,
    this.snackStatus,
    this.mealNotes,
    this.sleepStart,
    this.sleepEnd,
    this.sleepNotes,
    this.bathroomCount = 0,
    this.diaperChanges = 0,
    this.mood,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  // sleep duration in minutes
  int? get sleepMinutes {
    if (sleepStart == null || sleepEnd == null) return null;
    return ((sleepEnd! - sleepStart!) / 60000).round();
  }

  factory DailyCareLogModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return DailyCareLogModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      classroomId: json['classroomId']?.toString() ?? '',
      recordedBy: json['recordedBy']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      breakfastStatus: json['breakfastStatus']?.toString(),
      lunchStatus: json['lunchStatus']?.toString(),
      snackStatus: json['snackStatus']?.toString(),
      mealNotes: json['mealNotes']?.toString(),
      sleepStart: _parseInt(json['sleepStart']),
      sleepEnd: _parseInt(json['sleepEnd']),
      sleepNotes: json['sleepNotes']?.toString(),
      bathroomCount: _parseIntDef(json['bathroomCount']),
      diaperChanges: _parseIntDef(json['diaperChanges']),
      mood: json['mood']?.toString(),
      notes: json['notes']?.toString(),
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
    put('classroomId', classroomId);
    put('recordedBy', recordedBy);
    data['date'] = date;
    put('breakfastStatus', breakfastStatus);
    put('lunchStatus', lunchStatus);
    put('snackStatus', snackStatus);
    put('mealNotes', mealNotes);
    put('sleepStart', sleepStart);
    put('sleepEnd', sleepEnd);
    put('sleepNotes', sleepNotes);
    data['bathroomCount'] = bathroomCount;
    data['diaperChanges'] = diaperChanges;
    put('mood', mood);
    put('notes', notes);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  DailyCareLogModel copyWith({
    String? key, String? nurseryId, String? childId, String? classroomId,
    String? recordedBy, String? date,
    String? breakfastStatus, String? lunchStatus, String? snackStatus, String? mealNotes,
    int? sleepStart, int? sleepEnd, String? sleepNotes,
    int? bathroomCount, int? diaperChanges,
    String? mood, String? notes,
    int? createdAt, int? updatedAt,
  }) => DailyCareLogModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    childId: childId ?? this.childId, classroomId: classroomId ?? this.classroomId,
    recordedBy: recordedBy ?? this.recordedBy, date: date ?? this.date,
    breakfastStatus: breakfastStatus ?? this.breakfastStatus,
    lunchStatus: lunchStatus ?? this.lunchStatus,
    snackStatus: snackStatus ?? this.snackStatus,
    mealNotes: mealNotes ?? this.mealNotes,
    sleepStart: sleepStart ?? this.sleepStart,
    sleepEnd: sleepEnd ?? this.sleepEnd,
    sleepNotes: sleepNotes ?? this.sleepNotes,
    bathroomCount: bathroomCount ?? this.bathroomCount,
    diaperChanges: diaperChanges ?? this.diaperChanges,
    mood: mood ?? this.mood, notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
  static int _parseIntDef(dynamic v) {
    if (v is int) return v;
    return int.tryParse(v.toString()) ?? 0;
  }
}

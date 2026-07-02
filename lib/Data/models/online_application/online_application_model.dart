import '../application_form/application_form_model.dart';

/// A parent's online admission request submitted to a nursery before having an
/// account. Lives at `platform/{nurseryId}/onlineApplications/{key}`. The
/// nursery manager reviews it and either approves (which provisions the parent
/// account + child record) or rejects it with a reason.
class OnlineApplicationModel {
  final String? key;
  final String nurseryId;
  final String? nurseryName;

  // ─── Chosen branch + fee packages ─────────────────────────────────────────
  final String? branchId;
  final String? branchName;
  final List<ApplicationPackage> selectedPackages;

  // ─── Child ────────────────────────────────────────────────────────────────
  final String childFirstName;
  final String childLastName;
  final String? childPhoto;
  final String? childGender; // male, female
  final int? childDateOfBirth; // ms since epoch
  final String? childNationality;
  final String? childBloodType;
  final String? childAddress;

  // ─── Father ─────────────────────────────────────────────────────────────--
  final String fatherName;
  final String fatherPhone;
  final String? fatherJob;
  final String? fatherNationalId;

  // ─── Mother ─────────────────────────────────────────────────────────────--
  final String motherName;
  final String motherPhone;
  final String? motherJob;
  final String? motherNationalId;

  /// Which guardian becomes the primary app account on approval: father|mother.
  final String primaryContact;

  final String? notes;
  final bool agreed;

  /// Optional bus service opt-in plus the detailed pickup address.
  final bool busSubscription;
  final String? busAddress;

  /// Skill assessment, only collected for children aged 4–6 at apply time.
  final ApplicationAssessment? assessment;

  /// Snapshots of the manager's custom (non-built-in) fields and the parent's
  /// answers, so the manager reviews exactly what was asked and answered.
  final List<ApplicationCustomField> customFields;

  final String status; // pending, approved, rejected
  final String? rejectionReason;
  final int? appointmentAt; // ms since epoch — visit date/time set on approval
  final String? createdParentId; // set when approved
  final String? createdChildId; // set when approved

  final int? createdAt;
  final int? updatedAt;

  const OnlineApplicationModel({
    this.key,
    required this.nurseryId,
    this.nurseryName,
    this.branchId,
    this.branchName,
    this.selectedPackages = const [],
    required this.childFirstName,
    required this.childLastName,
    this.childPhoto,
    this.childGender,
    this.childDateOfBirth,
    this.childNationality,
    this.childBloodType,
    this.childAddress,
    required this.fatherName,
    required this.fatherPhone,
    this.fatherJob,
    this.fatherNationalId,
    required this.motherName,
    required this.motherPhone,
    this.motherJob,
    this.motherNationalId,
    this.primaryContact = 'father',
    this.notes,
    this.agreed = false,
    this.busSubscription = false,
    this.busAddress,
    this.assessment,
    this.customFields = const [],
    this.status = 'pending',
    this.rejectionReason,
    this.appointmentAt,
    this.createdParentId,
    this.createdChildId,
    this.createdAt,
    this.updatedAt,
  });

  bool get isPending => status == 'pending';

  bool get isApproved => status == 'approved';

  bool get isRejected => status == 'rejected';

  String get childFullName => '$childFirstName $childLastName'.trim();

  double get totalFees => selectedPackages.fold(0, (sum, p) => sum + p.price);

  /// The guardian designated as the app account owner.
  String get primaryName =>
      primaryContact == 'mother' ? motherName : fatherName;

  String get primaryPhone =>
      primaryContact == 'mother' ? motherPhone : fatherPhone;

  factory OnlineApplicationModel.fromJson(
    Map<String, dynamic> json, {
    String? key,
  }) {
    return OnlineApplicationModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      nurseryName: json['nurseryName']?.toString(),
      branchId: json['branchId']?.toString(),
      branchName: json['branchName']?.toString(),
      selectedPackages: ApplicationPackage.parseList(json['selectedPackages']),
      childFirstName: json['childFirstName']?.toString() ?? '',
      childLastName: json['childLastName']?.toString() ?? '',
      childPhoto: json['childPhoto']?.toString(),
      childGender: json['childGender']?.toString(),
      childDateOfBirth: _parseInt(json['childDateOfBirth']),
      childNationality: json['childNationality']?.toString(),
      childBloodType: json['childBloodType']?.toString(),
      childAddress: json['childAddress']?.toString(),
      fatherName: json['fatherName']?.toString() ?? '',
      fatherPhone: json['fatherPhone']?.toString() ?? '',
      fatherJob: json['fatherJob']?.toString(),
      fatherNationalId: json['fatherNationalId']?.toString(),
      motherName: json['motherName']?.toString() ?? '',
      motherPhone: json['motherPhone']?.toString() ?? '',
      motherJob: json['motherJob']?.toString(),
      motherNationalId: json['motherNationalId']?.toString(),
      primaryContact: json['primaryContact']?.toString() ?? 'father',
      notes: json['notes']?.toString(),
      agreed: _parseBool(json['agreed']),
      busSubscription: _parseBool(json['busSubscription']),
      busAddress: json['busAddress']?.toString(),
      assessment: ApplicationAssessment.fromJson(json['assessment']),
      customFields: ApplicationCustomField.parseList(json['customFields']),
      status: json['status']?.toString() ?? 'pending',
      rejectionReason: json['rejectionReason']?.toString(),
      appointmentAt: _parseInt(json['appointmentAt']),
      createdParentId: json['createdParentId']?.toString(),
      createdChildId: json['createdChildId']?.toString(),
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) {
      if (v != null) data[k] = v;
    }

    put('key', key);
    put('nurseryId', nurseryId);
    put('nurseryName', nurseryName);
    put('branchId', branchId);
    put('branchName', branchName);
    if (selectedPackages.isNotEmpty) {
      data['selectedPackages'] = selectedPackages
          .map((p) => p.toJson())
          .toList();
    }
    put('childFirstName', childFirstName);
    put('childLastName', childLastName);
    put('childPhoto', childPhoto);
    put('childGender', childGender);
    put('childDateOfBirth', childDateOfBirth);
    put('childNationality', childNationality);
    put('childBloodType', childBloodType);
    put('childAddress', childAddress);
    put('fatherName', fatherName);
    put('fatherPhone', fatherPhone);
    put('fatherJob', fatherJob);
    put('fatherNationalId', fatherNationalId);
    put('motherName', motherName);
    put('motherPhone', motherPhone);
    put('motherJob', motherJob);
    put('motherNationalId', motherNationalId);
    data['primaryContact'] = primaryContact;
    put('notes', notes);
    data['agreed'] = agreed;
    data['busSubscription'] = busSubscription;
    if (busSubscription) put('busAddress', busAddress);
    if (assessment != null && assessment!.isNotEmpty) {
      data['assessment'] = assessment!.toJson();
    }
    if (customFields.isNotEmpty) {
      data['customFields'] = customFields.map((f) => f.toJson()).toList();
    }
    data['status'] = status;
    put('rejectionReason', rejectionReason);
    put('appointmentAt', appointmentAt);
    put('createdParentId', createdParentId);
    put('createdChildId', createdChildId);
    put('createdAt', createdAt ?? _now());
    data['updatedAt'] = _now();
    return data;
  }

  OnlineApplicationModel copyWith({
    String? key,
    String? nurseryId,
    String? nurseryName,
    String? branchId,
    String? branchName,
    List<ApplicationPackage>? selectedPackages,
    String? childFirstName,
    String? childLastName,
    String? childPhoto,
    String? childGender,
    int? childDateOfBirth,
    String? childNationality,
    String? childBloodType,
    String? childAddress,
    String? fatherName,
    String? fatherPhone,
    String? fatherJob,
    String? fatherNationalId,
    String? motherName,
    String? motherPhone,
    String? motherJob,
    String? motherNationalId,
    String? primaryContact,
    String? notes,
    bool? agreed,
    bool? busSubscription,
    String? busAddress,
    ApplicationAssessment? assessment,
    List<ApplicationCustomField>? customFields,
    String? status,
    String? rejectionReason,
    int? appointmentAt,
    String? createdParentId,
    String? createdChildId,
    int? createdAt,
    int? updatedAt,
  }) {
    return OnlineApplicationModel(
      key: key ?? this.key,
      nurseryId: nurseryId ?? this.nurseryId,
      nurseryName: nurseryName ?? this.nurseryName,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      selectedPackages: selectedPackages ?? this.selectedPackages,
      childFirstName: childFirstName ?? this.childFirstName,
      childLastName: childLastName ?? this.childLastName,
      childPhoto: childPhoto ?? this.childPhoto,
      childGender: childGender ?? this.childGender,
      childDateOfBirth: childDateOfBirth ?? this.childDateOfBirth,
      childNationality: childNationality ?? this.childNationality,
      childBloodType: childBloodType ?? this.childBloodType,
      childAddress: childAddress ?? this.childAddress,
      fatherName: fatherName ?? this.fatherName,
      fatherPhone: fatherPhone ?? this.fatherPhone,
      fatherJob: fatherJob ?? this.fatherJob,
      fatherNationalId: fatherNationalId ?? this.fatherNationalId,
      motherName: motherName ?? this.motherName,
      motherPhone: motherPhone ?? this.motherPhone,
      motherJob: motherJob ?? this.motherJob,
      motherNationalId: motherNationalId ?? this.motherNationalId,
      primaryContact: primaryContact ?? this.primaryContact,
      notes: notes ?? this.notes,
      agreed: agreed ?? this.agreed,
      busSubscription: busSubscription ?? this.busSubscription,
      busAddress: busAddress ?? this.busAddress,
      assessment: assessment ?? this.assessment,
      customFields: customFields ?? this.customFields,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      appointmentAt: appointmentAt ?? this.appointmentAt,
      createdParentId: createdParentId ?? this.createdParentId,
      createdChildId: createdChildId ?? this.createdChildId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _now() => DateTime.now().millisecondsSinceEpoch;

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static bool _parseBool(dynamic v) {
    if (v is bool) return v;
    if (v is int) return v == 1;
    if (v is String) return v == '1' || v.toLowerCase() == 'true';
    return false;
  }
}

/// A snapshot of a fee package the parent selected at submission time. Stored
/// denormalized on the application so the manager sees the exact name/price the
/// parent agreed to, even if the nursery later edits its packages.
class ApplicationPackage {
  final String id;
  final String name;
  final double price;
  final String duration; // monthly, term, yearly

  const ApplicationPackage({
    required this.id,
    required this.name,
    this.price = 0,
    this.duration = 'monthly',
  });

  factory ApplicationPackage.fromJson(Map<String, dynamic> json) {
    return ApplicationPackage(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: _toDouble(json['price']),
      duration: json['duration']?.toString() ?? 'monthly',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'duration': duration,
  };

  static List<ApplicationPackage> parseList(dynamic raw) {
    if (raw is List) {
      return raw
          .whereType<Map>()
          .map((m) => ApplicationPackage.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }
    if (raw is Map) {
      return raw.values
          .whereType<Map>()
          .map((m) => ApplicationPackage.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    }
    return const [];
  }

  static double _toDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0;
  }
}

/// The dynamic skill assessment a guardian fills during the online application,
/// when the child's age falls in the nursery's configured band. [ratings] maps
/// each question id to one of `always` | `sometimes` | `never`. [questions] is a
/// snapshot of the manager's authored questions at submit time, so the manager
/// can review the exact wording the parent answered even if it's later edited.
class ApplicationAssessment {
  final Map<String, String> ratings;
  final List<AssessmentQuestion> questions;
  final String? notes;

  const ApplicationAssessment({
    this.ratings = const {},
    this.questions = const [],
    this.notes,
  });

  bool get isNotEmpty => ratings.isNotEmpty || (notes ?? '').isNotEmpty;

  static ApplicationAssessment? fromJson(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final ratings = <String, String>{};
    final ratingsRaw = map['ratings'];
    if (ratingsRaw is Map) {
      ratingsRaw.forEach((k, v) => ratings[k.toString()] = v.toString());
    }
    return ApplicationAssessment(
      ratings: ratings,
      questions: _parseQuestions(map['questions']),
      notes: map['notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'ratings': ratings,
    if (questions.isNotEmpty)
      'questions': questions.map((q) => q.toJson()).toList(),
    if ((notes ?? '').isNotEmpty) 'notes': notes,
  };

  static List<AssessmentQuestion> _parseQuestions(dynamic raw) {
    Iterable maps;
    if (raw is List) {
      maps = raw.whereType<Map>();
    } else if (raw is Map) {
      maps = raw.values.whereType<Map>();
    } else {
      return const [];
    }
    return maps
        .map((m) => AssessmentQuestion.fromJson(Map<String, dynamic>.from(m)))
        .toList();
  }
}

/// A manager-defined custom field and the parent's answer, snapshotted at submit
/// time. [section] is the data section it belonged to (`child` | `father` |
/// `mother`), [label] is the field's display name, and [value] is the answer as
/// shown to the parent (choice values joined, dates formatted, yes/no for toggles).
class ApplicationCustomField {
  final String section;
  final String label;
  final String value;

  const ApplicationCustomField({
    required this.section,
    required this.label,
    required this.value,
  });

  factory ApplicationCustomField.fromJson(Map<String, dynamic> json) =>
      ApplicationCustomField(
        section: json['section']?.toString() ?? '',
        label: json['label']?.toString() ?? '',
        value: json['value']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
    'section': section,
    'label': label,
    'value': value,
  };

  static List<ApplicationCustomField> parseList(dynamic raw) {
    Iterable maps;
    if (raw is List) {
      maps = raw.whereType<Map>();
    } else if (raw is Map) {
      maps = raw.values.whereType<Map>();
    } else {
      return const [];
    }
    return maps
        .map(
          (m) => ApplicationCustomField.fromJson(Map<String, dynamic>.from(m)),
        )
        .toList();
  }
}

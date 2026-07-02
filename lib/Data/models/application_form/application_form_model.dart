import 'package:uuid/uuid.dart';

/// The kinds of sections a nursery can place in its online application form.
/// Each maps to one step the parent fills (or, for [terms], a gate). Stored by
/// the stable [id] so reordering/renaming never corrupts saved configs.
enum ApplyFormSectionType {
  branches('branches', 'apply_section_branches', 'storefront'),
  childInfo('child', 'apply_section_child', 'child'),
  fatherInfo('father', 'apply_section_father', 'man'),
  motherInfo('mother', 'apply_section_mother', 'woman'),
  assessment('assessment', 'apply_section_assessment', 'assessment'),
  bus('bus', 'apply_section_bus', 'bus'),
  terms('terms', 'apply_section_terms', 'terms');

  const ApplyFormSectionType(this.id, this.labelKey, this.icon);

  /// Stable storage key, persisted in Firebase.
  final String id;

  /// Localization key for the section's manager-facing title.
  final String labelKey;

  /// Logical icon name resolved to an `IconData` in the UI layer.
  final String icon;

  static ApplyFormSectionType? fromId(String? id) {
    for (final t in values) {
      if (t.id == id) return t;
    }
    return null;
  }
}

/// Fixed three-point scale used by every assessment question. The manager only
/// authors the questions; the rating options are not configurable.
const List<String> kAssessmentRatingKeys = ['always', 'sometimes', 'never'];

/// One manager-authored skill question in the [ApplyAssessmentConfig]. [id] is
/// the stable key the parent's rating is stored under, so editing the [text]
/// never orphans a submitted answer.
class AssessmentQuestion {
  final String id;
  final String text;

  const AssessmentQuestion({required this.id, required this.text});

  factory AssessmentQuestion.create(String text) =>
      AssessmentQuestion(id: const Uuid().v4(), text: text.trim());

  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) =>
      AssessmentQuestion(
        id: json['id']?.toString() ?? const Uuid().v4(),
        text: json['text']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {'id': id, 'text': text};

  AssessmentQuestion copyWith({String? text}) =>
      AssessmentQuestion(id: id, text: text ?? this.text);
}

/// Configuration for the age-gated skill assessment: which age band triggers it
/// (in whole years) and the manager's dynamic list of questions.
class ApplyAssessmentConfig {
  final int minAgeYears;
  final int maxAgeYears;
  final List<AssessmentQuestion> questions;

  const ApplyAssessmentConfig({
    this.minAgeYears = 3,
    this.maxAgeYears = 5,
    this.questions = const [],
  });

  bool appliesToAge(int years) =>
      years >= minAgeYears && years <= maxAgeYears;

  factory ApplyAssessmentConfig.fromJson(dynamic raw) {
    if (raw is! Map) return const ApplyAssessmentConfig();
    final map = Map<String, dynamic>.from(raw);
    return ApplyAssessmentConfig(
      minAgeYears: _parseInt(map['minAgeYears']) ?? 3,
      maxAgeYears: _parseInt(map['maxAgeYears']) ?? 5,
      questions: _parseList(map['questions'])
          .map((m) => AssessmentQuestion.fromJson(m))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'minAgeYears': minAgeYears,
        'maxAgeYears': maxAgeYears,
        'questions': questions.map((q) => q.toJson()).toList(),
      };

  ApplyAssessmentConfig copyWith({
    int? minAgeYears,
    int? maxAgeYears,
    List<AssessmentQuestion>? questions,
  }) =>
      ApplyAssessmentConfig(
        minAgeYears: minAgeYears ?? this.minAgeYears,
        maxAgeYears: maxAgeYears ?? this.maxAgeYears,
        questions: questions ?? this.questions,
      );
}

/// Configuration for the bus-subscription opt-in. The price is settled directly
/// with the nursery, so the manager only authors an optional explanatory note.
class ApplyBusConfig {
  final String? note;

  const ApplyBusConfig({this.note});

  factory ApplyBusConfig.fromJson(dynamic raw) {
    if (raw is! Map) return const ApplyBusConfig();
    final map = Map<String, dynamic>.from(raw);
    final note = map['note']?.toString();
    return ApplyBusConfig(note: (note ?? '').isEmpty ? null : note);
  }

  Map<String, dynamic> toJson() => {if ((note ?? '').isNotEmpty) 'note': note};

  ApplyBusConfig copyWith({String? note}) => ApplyBusConfig(note: note);
}

/// The input widget a parent sees for a single field, chosen by the manager in
/// the form builder. Stored by [id] so saved configs survive renaming.
enum ApplyFieldType {
  text('text'),
  number('number'),
  phone('phone'),
  date('date'),
  dropdown('dropdown'),
  radio('radio'),
  checkbox('checkbox'), // multi-select from [options]
  toggle('toggle'), // single yes/no
  photo('photo'); // system-only (child photo)

  const ApplyFieldType(this.id);

  final String id;

  /// Whether this type collects its answer from [ApplyFieldConfig.options].
  bool get hasOptions =>
      this == dropdown || this == radio || this == checkbox;

  static ApplyFieldType fromId(String? id) {
    for (final t in values) {
      if (t.id == id) return t;
    }
    return ApplyFieldType.text;
  }
}

/// The built-in field roles the rest of the app depends on (account/child
/// provisioning on approval). A field carrying one of these [systemRole]s can be
/// relabeled and reordered but never deleted. The subset in [kLockedRoles] is
/// additionally always-enabled and always-required.
class ApplyFieldRoles {
  static const childName = 'child_name';
  static const childPhoto = 'child_photo';
  static const childGender = 'child_gender';
  static const childDob = 'child_dob';
  static const childNationality = 'child_nationality';
  static const childBlood = 'child_blood';
  static const childAddress = 'child_address';
  static const fatherName = 'father_name';
  static const fatherPhone = 'father_phone';
  static const fatherJob = 'father_job';
  static const fatherNationalId = 'father_national_id';
  static const motherName = 'mother_name';
  static const motherPhone = 'mother_phone';
  static const motherJob = 'mother_job';
  static const motherNationalId = 'mother_national_id';
}

/// Roles that must stay enabled + required — the minimum the app needs to create
/// the parent account and child record when the application is approved.
const Set<String> kLockedRoles = {
  ApplyFieldRoles.childName,
  ApplyFieldRoles.childPhoto,
  ApplyFieldRoles.fatherName,
  ApplyFieldRoles.fatherPhone,
  ApplyFieldRoles.motherName,
  ApplyFieldRoles.motherPhone,
};

/// Dropdown option presets for the built-in child fields.
const List<String> kNationalityOptions = [
  'مصري', 'سعودي', 'إماراتي', 'كويتي', 'قطري', 'بحريني', 'عماني', 'أردني',
  'فلسطيني', 'لبناني', 'سوري', 'عراقي', 'يمني', 'ليبي', 'سوداني', 'تونسي',
  'جزائري', 'مغربي', 'أخرى',
];
const List<String> kBloodTypeOptions = [
  'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-',
];

/// One manager-configured field inside a data-collection section (child, father,
/// mother). [systemRole] is non-null for the built-in fields the app needs; for
/// those the visible name comes from [labelKey] unless the manager overrode it
/// via [label]. Custom fields carry a free-text [label] and empty [labelKey].
class ApplyFieldConfig {
  final String id;
  final String label;
  final String labelKey;
  final ApplyFieldType type;
  final bool required;
  final bool enabled;
  final List<String> options;
  final String? systemRole;

  const ApplyFieldConfig({
    required this.id,
    this.label = '',
    this.labelKey = '',
    this.type = ApplyFieldType.text,
    this.required = false,
    this.enabled = true,
    this.options = const [],
    this.systemRole,
  });

  /// A manager-authored custom field.
  factory ApplyFieldConfig.create({
    required String label,
    required ApplyFieldType type,
    bool required = false,
    List<String> options = const [],
  }) =>
      ApplyFieldConfig(
        id: const Uuid().v4(),
        label: label.trim(),
        type: type,
        required: required,
        options: options,
      );

  bool get isSystem => systemRole != null;
  bool get isLocked => systemRole != null && kLockedRoles.contains(systemRole);

  factory ApplyFieldConfig.fromJson(Map<String, dynamic> json) =>
      ApplyFieldConfig(
        id: json['id']?.toString() ?? const Uuid().v4(),
        label: json['label']?.toString() ?? '',
        labelKey: json['labelKey']?.toString() ?? '',
        type: ApplyFieldType.fromId(json['type']?.toString()),
        required: _parseBool(json['required']),
        enabled: _parseBool(json['enabled'], fallback: true),
        options: (json['options'] is List)
            ? (json['options'] as List).map((e) => e.toString()).toList()
            : const [],
        systemRole: json['systemRole']?.toString(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        if (label.isNotEmpty) 'label': label,
        if (labelKey.isNotEmpty) 'labelKey': labelKey,
        'type': type.id,
        'required': required,
        'enabled': enabled,
        if (options.isNotEmpty) 'options': options,
        if (systemRole != null) 'systemRole': systemRole,
      };

  ApplyFieldConfig copyWith({
    String? label,
    ApplyFieldType? type,
    bool? required,
    bool? enabled,
    List<String>? options,
  }) =>
      ApplyFieldConfig(
        id: id,
        label: label ?? this.label,
        labelKey: labelKey,
        type: type ?? this.type,
        required: required ?? this.required,
        enabled: enabled ?? this.enabled,
        options: options ?? this.options,
        systemRole: systemRole,
      );
}

/// The built-in fields seeded for a data section the first time (and merged into
/// older saved configs that predate the field builder). Returns empty for
/// sections that don't collect free fields (branches/assessment/bus/terms).
List<ApplyFieldConfig> defaultFieldsFor(ApplyFormSectionType type) {
  ApplyFieldConfig f(
    String role,
    String labelKey,
    ApplyFieldType type, {
    bool required = false,
    List<String> options = const [],
  }) =>
      ApplyFieldConfig(
        id: role,
        labelKey: labelKey,
        type: type,
        required: required,
        options: options,
        systemRole: role,
      );

  switch (type) {
    case ApplyFormSectionType.childInfo:
      return [
        f(ApplyFieldRoles.childPhoto, 'apply_field_child_photo',
            ApplyFieldType.photo,
            required: true),
        f(ApplyFieldRoles.childName, 'apply_field_child_name',
            ApplyFieldType.text,
            required: true),
        f(ApplyFieldRoles.childGender, 'apply_field_gender',
            ApplyFieldType.radio,
            options: const ['male', 'female']),
        f(ApplyFieldRoles.childDob, 'apply_field_dob', ApplyFieldType.date),
        f(ApplyFieldRoles.childNationality, 'apply_field_nationality',
            ApplyFieldType.dropdown,
            options: kNationalityOptions),
        f(ApplyFieldRoles.childBlood, 'apply_field_blood_type',
            ApplyFieldType.dropdown,
            options: kBloodTypeOptions),
        f(ApplyFieldRoles.childAddress, 'apply_field_address',
            ApplyFieldType.text),
      ];
    case ApplyFormSectionType.fatherInfo:
      return [
        f(ApplyFieldRoles.fatherName, 'apply_field_full_name',
            ApplyFieldType.text,
            required: true),
        f(ApplyFieldRoles.fatherPhone, 'apply_field_phone',
            ApplyFieldType.phone,
            required: true),
        f(ApplyFieldRoles.fatherJob, 'apply_field_job', ApplyFieldType.text),
        f(ApplyFieldRoles.fatherNationalId, 'apply_field_national_id',
            ApplyFieldType.number),
      ];
    case ApplyFormSectionType.motherInfo:
      return [
        f(ApplyFieldRoles.motherName, 'apply_field_full_name',
            ApplyFieldType.text,
            required: true),
        f(ApplyFieldRoles.motherPhone, 'apply_field_phone',
            ApplyFieldType.phone,
            required: true),
        f(ApplyFieldRoles.motherJob, 'apply_field_job', ApplyFieldType.text),
        f(ApplyFieldRoles.motherNationalId, 'apply_field_national_id',
            ApplyFieldType.number),
      ];
    default:
      return const [];
  }
}

/// One entry in the ordered application form. Carries the [enabled] flag plus
/// the per-type config (only the field matching [type] is meaningful).
class ApplyFormSection {
  final ApplyFormSectionType type;
  final bool enabled;
  final ApplyAssessmentConfig assessment;
  final ApplyBusConfig bus;
  final List<ApplyFieldConfig> fields;

  const ApplyFormSection({
    required this.type,
    this.enabled = true,
    this.assessment = const ApplyAssessmentConfig(),
    this.bus = const ApplyBusConfig(),
    this.fields = const [],
  });

  /// A section seeded with its built-in default fields.
  factory ApplyFormSection.standard(ApplyFormSectionType type,
          {bool enabled = true}) =>
      ApplyFormSection(
        type: type,
        enabled: enabled,
        fields: defaultFieldsFor(type),
      );

  /// True for sections whose parent step is a free, manager-built field form.
  bool get collectsFields =>
      type == ApplyFormSectionType.childInfo ||
      type == ApplyFormSectionType.fatherInfo ||
      type == ApplyFormSectionType.motherInfo;

  factory ApplyFormSection.fromJson(Map<String, dynamic> json) {
    final type = ApplyFormSectionType.fromId(json['type']?.toString()) ??
        ApplyFormSectionType.childInfo;
    final parsedFields = _parseList(json['fields'])
        .map((m) => ApplyFieldConfig.fromJson(m))
        .toList();
    return ApplyFormSection(
      type: type,
      enabled: _parseBool(json['enabled'], fallback: true),
      assessment: ApplyAssessmentConfig.fromJson(json['assessment']),
      bus: ApplyBusConfig.fromJson(json['bus']),
      // Seed defaults for data sections saved before the field builder existed.
      fields: parsedFields.isEmpty ? defaultFieldsFor(type) : parsedFields,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'type': type.id,
      'enabled': enabled,
    };
    if (type == ApplyFormSectionType.assessment) {
      data['assessment'] = assessment.toJson();
    }
    if (type == ApplyFormSectionType.bus) {
      data['bus'] = bus.toJson();
    }
    if (collectsFields) {
      data['fields'] = fields.map((f) => f.toJson()).toList();
    }
    return data;
  }

  ApplyFormSection copyWith({
    bool? enabled,
    ApplyAssessmentConfig? assessment,
    ApplyBusConfig? bus,
    List<ApplyFieldConfig>? fields,
  }) =>
      ApplyFormSection(
        type: type,
        enabled: enabled ?? this.enabled,
        assessment: assessment ?? this.assessment,
        bus: bus ?? this.bus,
        fields: fields ?? this.fields,
      );
}

/// The full, ordered configuration of a nursery's online application form. The
/// order of [sections] is the order the parent sees them; a disabled section is
/// kept (so its config survives) but skipped during apply.
class ApplicationFormConfig {
  final List<ApplyFormSection> sections;

  const ApplicationFormConfig({this.sections = const []});

  /// A first-run default covering every section in a sensible order, all on.
  factory ApplicationFormConfig.defaults() => ApplicationFormConfig(
        sections: [
          ApplyFormSection.standard(ApplyFormSectionType.branches),
          ApplyFormSection.standard(ApplyFormSectionType.childInfo),
          ApplyFormSection.standard(ApplyFormSectionType.fatherInfo),
          ApplyFormSection.standard(ApplyFormSectionType.motherInfo),
          ApplyFormSection.standard(ApplyFormSectionType.assessment),
          ApplyFormSection.standard(ApplyFormSectionType.bus),
          ApplyFormSection.standard(ApplyFormSectionType.terms),
        ],
      );

  bool get isEmpty => sections.isEmpty;

  ApplyFormSection? sectionOf(ApplyFormSectionType type) {
    for (final s in sections) {
      if (s.type == type) return s;
    }
    return null;
  }

  /// Enabled sections in display order — what the parent actually walks through.
  List<ApplyFormSection> get enabledSections =>
      sections.where((s) => s.enabled).toList();

  factory ApplicationFormConfig.fromJson(dynamic raw) {
    final parsed = _parseList(raw is Map ? raw['sections'] : raw)
        .map((m) => ApplyFormSection.fromJson(m))
        .toList();
    if (parsed.isEmpty) return ApplicationFormConfig.defaults();
    // Append any section type missing from a saved config (e.g. added in a new
    // app version) so the builder always exposes the full catalogue, disabled.
    final present = parsed.map((s) => s.type).toSet();
    for (final t in ApplyFormSectionType.values) {
      if (!present.contains(t)) {
        parsed.add(ApplyFormSection.standard(t, enabled: false));
      }
    }
    return ApplicationFormConfig(sections: parsed);
  }

  Map<String, dynamic> toJson() =>
      {'sections': sections.map((s) => s.toJson()).toList()};

  ApplicationFormConfig copyWith({List<ApplyFormSection>? sections}) =>
      ApplicationFormConfig(sections: sections ?? this.sections);
}

// ─── Parsing helpers (RTDB lists arrive as List or index-keyed Map) ──────────

List<Map<String, dynamic>> _parseList(dynamic raw) {
  if (raw is List) {
    return raw
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }
  if (raw is Map) {
    return raw.values
        .whereType<Map>()
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }
  return const [];
}

int? _parseInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  return int.tryParse(v.toString());
}

bool _parseBool(dynamic v, {bool fallback = false}) {
  if (v is bool) return v;
  if (v is int) return v == 1;
  if (v is String) return v == '1' || v.toLowerCase() == 'true';
  return fallback;
}

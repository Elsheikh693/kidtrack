class MedicalProfileModel {
  final String? key;
  final String childId;
  final String nurseryId;
  final List<String> allergies;
  final List<String> medications;
  final String? bloodType;
  final String? emergencyContact;
  final String? emergencyPhone;
  final String? doctorName;
  final String? doctorPhone;
  final String? notes;
  final int? createdAt;
  final int? updatedAt;

  const MedicalProfileModel({
    this.key,
    required this.childId,
    required this.nurseryId,
    this.allergies = const [],
    this.medications = const [],
    this.bloodType,
    this.emergencyContact,
    this.emergencyPhone,
    this.doctorName,
    this.doctorPhone,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory MedicalProfileModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return MedicalProfileModel(
      key: key ?? json['key']?.toString(),
      childId: json['childId']?.toString() ?? '',
      nurseryId: json['nurseryId']?.toString() ?? '',
      allergies: _parseList(json['allergies']),
      medications: _parseList(json['medications']),
      bloodType: json['bloodType']?.toString(),
      emergencyContact: json['emergencyContact']?.toString(),
      emergencyPhone: json['emergencyPhone']?.toString(),
      doctorName: json['doctorName']?.toString(),
      doctorPhone: json['doctorPhone']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    put('childId', childId);
    put('nurseryId', nurseryId);
    if (allergies.isNotEmpty) data['allergies'] = allergies;
    if (medications.isNotEmpty) data['medications'] = medications;
    put('bloodType', bloodType);
    put('emergencyContact', emergencyContact);
    put('emergencyPhone', emergencyPhone);
    put('doctorName', doctorName);
    put('doctorPhone', doctorPhone);
    put('notes', notes);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  MedicalProfileModel copyWith({
    String? key, String? childId, String? nurseryId,
    List<String>? allergies, List<String>? medications, String? bloodType,
    String? emergencyContact, String? emergencyPhone, String? doctorName,
    String? doctorPhone, String? notes, int? createdAt, int? updatedAt,
  }) => MedicalProfileModel(
    key: key ?? this.key, childId: childId ?? this.childId,
    nurseryId: nurseryId ?? this.nurseryId,
    allergies: allergies ?? this.allergies, medications: medications ?? this.medications,
    bloodType: bloodType ?? this.bloodType,
    emergencyContact: emergencyContact ?? this.emergencyContact,
    emergencyPhone: emergencyPhone ?? this.emergencyPhone,
    doctorName: doctorName ?? this.doctorName, doctorPhone: doctorPhone ?? this.doctorPhone,
    notes: notes ?? this.notes,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
  static List<String> _parseList(dynamic v) {
    if (v is List) return v.map((e) => e.toString()).toList();
    return [];
  }
}

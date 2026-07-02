class DocumentModel {
  final String? key;
  final String nurseryId;
  final String childId;
  final String type; // birth_certificate, id, vaccination, medical, other
  final String? title;
  final String fileUrl;
  final String? mimeType;
  final String? uploadedBy;
  final int? createdAt;
  final int? updatedAt;

  const DocumentModel({
    this.key,
    required this.nurseryId,
    required this.childId,
    required this.type,
    this.title,
    required this.fileUrl,
    this.mimeType,
    this.uploadedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory DocumentModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return DocumentModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      type: json['type']?.toString() ?? 'other',
      title: json['title']?.toString(),
      fileUrl: json['fileUrl']?.toString() ?? '',
      mimeType: json['mimeType']?.toString(),
      uploadedBy: json['uploadedBy']?.toString(),
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
    data['type'] = type;
    put('title', title);
    data['fileUrl'] = fileUrl;
    put('mimeType', mimeType);
    put('uploadedBy', uploadedBy);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  DocumentModel copyWith({
    String? key, String? nurseryId, String? childId, String? type,
    String? title, String? fileUrl, String? mimeType, String? uploadedBy,
    int? createdAt, int? updatedAt,
  }) => DocumentModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    childId: childId ?? this.childId, type: type ?? this.type,
    title: title ?? this.title, fileUrl: fileUrl ?? this.fileUrl,
    mimeType: mimeType ?? this.mimeType, uploadedBy: uploadedBy ?? this.uploadedBy,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

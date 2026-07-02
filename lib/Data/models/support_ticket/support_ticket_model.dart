class SupportTicketModel {
  final String? key;
  final String nurseryId;
  final String submittedBy;
  final String title;
  final String description;
  final String status; // open, in_progress, resolved, closed
  final String? adminReply;
  final int? createdAt;
  final int? updatedAt;

  const SupportTicketModel({
    this.key,
    required this.nurseryId,
    required this.submittedBy,
    required this.title,
    required this.description,
    this.status = 'open',
    this.adminReply,
    this.createdAt,
    this.updatedAt,
  });

  factory SupportTicketModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return SupportTicketModel(
      key: key ?? json['key']?.toString(),
      nurseryId: json['nurseryId']?.toString() ?? '',
      submittedBy: json['submittedBy']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      adminReply: json['adminReply']?.toString(),
      createdAt: _parseInt(json['createdAt']),
      updatedAt: _parseInt(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    void put(String k, dynamic v) { if (v != null) data[k] = v; }
    put('key', key);
    put('nurseryId', nurseryId);
    put('submittedBy', submittedBy);
    put('title', title);
    put('description', description);
    data['status'] = status;
    put('adminReply', adminReply);
    put('createdAt', createdAt ?? _now());
    put('updatedAt', _now());
    return data;
  }

  SupportTicketModel copyWith({
    String? key, String? nurseryId, String? submittedBy, String? title,
    String? description, String? status, String? adminReply,
    int? createdAt, int? updatedAt,
  }) => SupportTicketModel(
    key: key ?? this.key, nurseryId: nurseryId ?? this.nurseryId,
    submittedBy: submittedBy ?? this.submittedBy, title: title ?? this.title,
    description: description ?? this.description, status: status ?? this.status,
    adminReply: adminReply ?? this.adminReply,
    createdAt: createdAt ?? this.createdAt, updatedAt: updatedAt ?? this.updatedAt,
  );

  static int _now() => DateTime.now().millisecondsSinceEpoch;
  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

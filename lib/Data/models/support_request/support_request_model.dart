class SupportRequestModel {
  final String? key;
  final String name;
  final String phone;
  final String? email;
  final String subject;
  final String message;
  final String status; // open, in_progress, resolved, closed
  final String? adminReply;
  final int? createdAt;
  final int? updatedAt;

  const SupportRequestModel({
    this.key,
    required this.name,
    required this.phone,
    this.email,
    required this.subject,
    required this.message,
    this.status = 'open',
    this.adminReply,
    this.createdAt,
    this.updatedAt,
  });

  bool get hasReply => (adminReply ?? '').trim().isNotEmpty;

  factory SupportRequestModel.fromJson(Map<String, dynamic> json, {String? key}) {
    return SupportRequestModel(
      key: key ?? json['key']?.toString(),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      email: json['email']?.toString(),
      subject: json['subject']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      status: json['status']?.toString() ?? 'open',
      adminReply: json['adminReply']?.toString(),
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
    put('name', name);
    put('phone', phone);
    put('email', email);
    put('subject', subject);
    put('message', message);
    data['status'] = status;
    put('adminReply', adminReply);
    put('createdAt', createdAt ?? _now());
    data['updatedAt'] = _now();
    return data;
  }

  SupportRequestModel copyWith({
    String? key,
    String? name,
    String? phone,
    String? email,
    String? subject,
    String? message,
    String? status,
    String? adminReply,
    int? createdAt,
    int? updatedAt,
  }) {
    return SupportRequestModel(
      key: key ?? this.key,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      subject: subject ?? this.subject,
      message: message ?? this.message,
      status: status ?? this.status,
      adminReply: adminReply ?? this.adminReply,
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
}

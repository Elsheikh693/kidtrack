/// A single message inside a per-child manager↔parent conversation. Stored at
/// `platform/{nurseryId}/chats/{childId}/messages/{messageId}`.
class ChatMessageModel {
  final String id;
  final String senderId;

  /// 'manager' (nursery side) or 'parent'. Drives bubble alignment.
  final String senderRole;
  final String text;
  final int createdAt;

  const ChatMessageModel({
    required this.id,
    required this.senderId,
    required this.senderRole,
    required this.text,
    required this.createdAt,
  });

  bool get isManager => senderRole == 'manager';

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return ChatMessageModel(
      id: id ?? json['id']?.toString() ?? '',
      senderId: json['senderId']?.toString() ?? '',
      senderRole: json['senderRole']?.toString() ?? 'manager',
      text: json['text']?.toString() ?? '',
      createdAt: _parseInt(json['createdAt']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'senderId': senderId,
        'senderRole': senderRole,
        'text': text,
        'createdAt': createdAt,
      };

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

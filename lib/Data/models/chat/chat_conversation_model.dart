/// Metadata for one per-child manager↔parent conversation. The conversation id
/// is the child's id. Stored at `platform/{nurseryId}/chats/{childId}/meta`.
class ChatConversationModel {
  final String childId;
  final String childName;
  final String? childImage;
  final String? classroomId;
  final String branchId;
  final String parentId;
  final String parentName;

  final String lastText;
  final int lastAt;

  /// Role that sent the last message: 'manager' or 'parent'.
  final String lastSenderRole;

  /// Unread counts, one per side. Reset to 0 when that side opens the thread.
  final int unreadManager;
  final int unreadParent;

  const ChatConversationModel({
    required this.childId,
    required this.childName,
    this.childImage,
    this.classroomId,
    this.branchId = '',
    this.parentId = '',
    this.parentName = '',
    this.lastText = '',
    this.lastAt = 0,
    this.lastSenderRole = '',
    this.unreadManager = 0,
    this.unreadParent = 0,
  });

  bool get hasMessages => lastAt > 0;

  factory ChatConversationModel.fromJson(
    Map<String, dynamic> json, {
    required String childId,
  }) {
    return ChatConversationModel(
      childId: childId,
      childName: json['childName']?.toString() ?? '',
      childImage: json['childImage']?.toString(),
      classroomId: json['classroomId']?.toString(),
      branchId: json['branchId']?.toString() ?? '',
      parentId: json['parentId']?.toString() ?? '',
      parentName: json['parentName']?.toString() ?? '',
      lastText: json['lastText']?.toString() ?? '',
      lastAt: _parseInt(json['lastAt']) ?? 0,
      lastSenderRole: json['lastSenderRole']?.toString() ?? '',
      unreadManager: _parseInt(json['unreadManager']) ?? 0,
      unreadParent: _parseInt(json['unreadParent']) ?? 0,
    );
  }

  /// Stable meta fields written on every send (counters handled separately).
  Map<String, dynamic> toMetaJson() => {
        'childName': childName,
        if (childImage != null) 'childImage': childImage,
        if (classroomId != null) 'classroomId': classroomId,
        'branchId': branchId,
        'parentId': parentId,
        'parentName': parentName,
        'lastText': lastText,
        'lastAt': lastAt,
        'lastSenderRole': lastSenderRole,
      };

  static int? _parseInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}

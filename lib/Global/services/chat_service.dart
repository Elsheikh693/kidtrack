import 'package:firebase_database/firebase_database.dart';
import '../../Data/models/chat/chat_conversation_model.dart';
import '../../Data/models/chat/chat_message_model.dart';
import 'session_service.dart';

/// Real-time service for the per-child manager↔parent chat. Bypasses the
/// 4-layer CRUD (like [FeedService]) and talks to RTDB directly.
///
/// Tree: `platform/{nurseryId}/chats/{childId}/meta`      (conversation summary)
///       `platform/{nurseryId}/chats/{childId}/messages`  (pushId → message)
class ChatService {
  final _db = FirebaseDatabase.instance;
  final _session = SessionService();

  String get _nurseryId => _session.nurseryId ?? '';

  DatabaseReference get _chatsRef => _db.ref('platform/$_nurseryId/chats');

  DatabaseReference _chatRef(String childId) => _chatsRef.child(childId);

  // ─── Conversations (manager inbox) ──────────────────────────────────────────
  Stream<List<ChatConversationModel>> watchConversations() {
    return _chatsRef.onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return <ChatConversationModel>[];
      final list = <ChatConversationModel>[];
      for (final entry in data.entries) {
        try {
          final node = Map<String, dynamic>.from(entry.value as Map);
          final meta = node['meta'];
          if (meta is! Map) continue;
          list.add(ChatConversationModel.fromJson(
            Map<String, dynamic>.from(meta),
            childId: entry.key.toString(),
          ));
        } catch (_) {}
      }
      list.sort((a, b) => b.lastAt.compareTo(a.lastAt));
      return list;
    });
  }

  // ─── Messages (single thread) ───────────────────────────────────────────────
  Stream<List<ChatMessageModel>> watchMessages(String childId) {
    return _chatRef(childId)
        .child('messages')
        .orderByChild('createdAt')
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return <ChatMessageModel>[];
      final list = <ChatMessageModel>[];
      for (final entry in data.entries) {
        try {
          final map = Map<String, dynamic>.from(entry.value as Map);
          list.add(ChatMessageModel.fromJson(map, id: entry.key.toString()));
        } catch (_) {}
      }
      list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return list;
    });
  }

  // ─── Send ───────────────────────────────────────────────────────────────────
  /// Writes the message, upserts the conversation meta, and adjusts the unread
  /// counters: the sender's own counter resets, the other side increments.
  Future<bool> sendMessage({
    required ChatConversationModel meta,
    required String text,
    required String senderRole, // 'manager' | 'parent'
  }) async {
    final body = text.trim();
    if (body.isEmpty) return false;
    try {
      final childId = meta.childId;
      final now = DateTime.now().millisecondsSinceEpoch;
      final senderId = _session.userId ?? '';

      final msgRef = _chatRef(childId).child('messages').push();
      final message = ChatMessageModel(
        id: msgRef.key ?? '',
        senderId: senderId,
        senderRole: senderRole,
        text: body,
        createdAt: now,
      );
      await msgRef.set(message.toJson());

      final summary = ChatConversationModel(
        childId: childId,
        childName: meta.childName,
        childImage: meta.childImage,
        classroomId: meta.classroomId,
        branchId: meta.branchId,
        parentId: meta.parentId,
        parentName: meta.parentName,
        lastText: body,
        lastAt: now,
        lastSenderRole: senderRole,
      );
      final metaRef = _chatRef(childId).child('meta');
      await metaRef.update(summary.toMetaJson());

      final mineKey = senderRole == 'manager' ? 'unreadManager' : 'unreadParent';
      final theirsKey =
          senderRole == 'manager' ? 'unreadParent' : 'unreadManager';
      await metaRef.child(mineKey).set(0);
      await metaRef.child(theirsKey).set(ServerValue.increment(1));
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Mark read ──────────────────────────────────────────────────────────────
  Future<void> markRead(String childId, String role) async {
    try {
      final key = role == 'manager' ? 'unreadManager' : 'unreadParent';
      await _chatRef(childId).child('meta').child(key).set(0);
    } catch (_) {}
  }
}

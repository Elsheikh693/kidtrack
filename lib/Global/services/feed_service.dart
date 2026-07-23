import 'dart:async';
import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../../Data/models/feed/nursery_post_model.dart';
import 'session_service.dart';

class FeedService {
  final _db = FirebaseDatabase.instance;
  final _storage = FirebaseStorage.instance;
  final _session = SessionService();

  String get _nurseryId => _session.nurseryId ?? '';

  DatabaseReference get _feedRef => _db.ref('platform/$_nurseryId/feed');

  // ─── Watch feed real-time ──────────────────────────────────────────────────
  Stream<List<NurseryPostModel>> watchFeed() {
    return _feedRef.orderByChild('createdAt').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return <NurseryPostModel>[];
      final posts = <NurseryPostModel>[];
      for (final entry in data.entries) {
        try {
          final map = Map<String, dynamic>.from(entry.value as Map);
          posts.add(NurseryPostModel.fromJson(map, id: entry.key.toString()));
        } catch (_) {}
      }
      // Effectively-pinned (not expired) first, then by createdAt descending.
      final now = DateTime.now().millisecondsSinceEpoch;
      posts.sort((a, b) {
        final ap = a.effectivePinnedAt(now);
        final bp = b.effectivePinnedAt(now);
        if (ap && !bp) return -1;
        if (!ap && bp) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });
      return posts;
    });
  }

  // ─── Create ───────────────────────────────────────────────────────────────
  Future<bool> createPost({
    required String text,
    required List<XFile> images,
    required PostCategory category,
    required bool isPinned,
    int? pinnedUntil,
    List<String> branchIds = const [],
    String? classroomId,
  }) async {
    try {
      final user = _session.currentUser;
      final id = const Uuid().v4();
      final photoUrls = await _uploadImages(id, images);
      final post = NurseryPostModel(
        id: id,
        nurseryId: _nurseryId,
        branchIds: branchIds,
        classroomId: classroomId,
        authorId: _session.userId ?? '',
        authorName: user?.displayName ?? 'المدير',
        text: text,
        photos: photoUrls,
        category: category,
        isPinned: isPinned,
        pinnedUntil: pinnedUntil,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _feedRef.child(id).set(post.toJson());
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Create from already-hosted photo URLs ─────────────────────────────────
  // Publishes a post without re-uploading any images — the [photoUrls] are
  // existing Storage download URLs (e.g. a child's profile photo). Returns the
  // new post id, or null on failure. Used by "Star of the Week", which reuses
  // the child's avatar rather than asking the manager to attach a new photo.
  Future<String?> createPostRaw({
    required String text,
    required PostCategory category,
    bool isPinned = false,
    int? pinnedUntil,
    List<String> branchIds = const [],
    String? classroomId,
    List<String> photoUrls = const [],
    String? authorName,
  }) async {
    try {
      final user = _session.currentUser;
      final id = const Uuid().v4();
      final post = NurseryPostModel(
        id: id,
        nurseryId: _nurseryId,
        branchIds: branchIds,
        classroomId: classroomId,
        authorId: _session.userId ?? '',
        authorName: authorName ?? user?.displayName ?? 'المدير',
        text: text,
        photos: photoUrls,
        category: category,
        isPinned: isPinned,
        pinnedUntil: pinnedUntil,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _feedRef.child(id).set(post.toJson());
      return id;
    } catch (_) {
      return null;
    }
  }

  // ─── Update ───────────────────────────────────────────────────────────────
  Future<bool> updatePost({
    required NurseryPostModel post,
    required String text,
    required List<String> existingPhotos,
    required List<XFile> newImages,
    required PostCategory category,
    required bool isPinned,
    List<String> branchIds = const [],
    String? classroomId,
  }) async {
    try {
      final removedUrls = post.photos
          .where((u) => !existingPhotos.contains(u))
          .toList();
      for (final url in removedUrls) {
        await _deleteImageByUrl(url);
      }
      final newUrls = await _uploadImages(post.id, newImages);
      final allPhotos = [...existingPhotos, ...newUrls];
      final updated = post.copyWith(
        text: text,
        photos: allPhotos,
        category: category,
        isPinned: isPinned,
        branchIds: branchIds,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      );
      // Explicit so switching to "everyone"/"all branches" clears the stored value.
      await _feedRef.child(post.id).update({
        ...updated.toJson(),
        'classroomId': classroomId,
        'branchIds': branchIds,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Delete just the post node (no image cleanup) ──────────────────────────
  // For posts whose photos are shared URLs the feed doesn't own (e.g. a "Star
  // of the Week" post reuses the child's profile photo). Removing the node must
  // NOT delete those images from Storage, so this skips the image cleanup that
  // [deletePost] does. Best-effort.
  Future<void> deletePostNode(String id) async {
    if (id.isEmpty) return;
    try {
      await _feedRef.child(id).remove();
    } catch (_) {}
  }

  // ─── Delete ───────────────────────────────────────────────────────────────
  Future<bool> deletePost(NurseryPostModel post) async {
    try {
      for (final url in post.photos) {
        await _deleteImageByUrl(url);
      }
      await _feedRef.child(post.id).remove();
      return true;
    } catch (_) {
      return false;
    }
  }

  // ─── Pinned-only stream (parent) ─────────────────────────────────────────
  Stream<List<NurseryPostModel>> watchPinnedFeed() {
    return _feedRef
        .orderByChild('isPinned')
        .equalTo(true)
        .onValue
        .map((event) {
          final data = event.snapshot.value;
          if (data == null || data is! Map) return <NurseryPostModel>[];
          final now = DateTime.now().millisecondsSinceEpoch;
          final posts = <NurseryPostModel>[];
          for (final entry in data.entries) {
            try {
              final map = Map<String, dynamic>.from(entry.value as Map);
              final p =
                  NurseryPostModel.fromJson(map, id: entry.key.toString());
              // Drop expired pins — they fall back to the regular feed.
              if (p.effectivePinnedAt(now)) posts.add(p);
            } catch (_) {}
          }
          posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return posts;
        });
  }

  // ─── Paginated page fetch (parent) ────────────────────────────────────────
  Future<({List<NurseryPostModel> posts, bool hasMore, int? cursor})> fetchPage({
    int? beforeTimestamp,
    int pageSize = 15,
  }) async {
    try {
      final query = beforeTimestamp != null
          ? _feedRef.orderByChild('createdAt').endBefore(beforeTimestamp).limitToLast(pageSize)
          : _feedRef.orderByChild('createdAt').limitToLast(pageSize);
      final snap = await query.get();
      if (snap.value == null || snap.value is! Map) {
        return (posts: <NurseryPostModel>[], hasMore: false, cursor: null);
      }
      final all = <NurseryPostModel>[];
      for (final entry in (snap.value as Map).entries) {
        try {
          final map = Map<String, dynamic>.from(entry.value as Map);
          all.add(NurseryPostModel.fromJson(map, id: entry.key.toString()));
        } catch (_) {}
      }
      final now = DateTime.now().millisecondsSinceEpoch;
      final regular = all.where((p) => !p.effectivePinnedAt(now)).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      all.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      return (
        posts: regular,
        hasMore: all.length >= pageSize,
        cursor: all.isNotEmpty ? all.first.createdAt : null,
      );
    } catch (_) {
      return (posts: <NurseryPostModel>[], hasMore: true, cursor: null);
    }
  }

  // ─── Toggle pin ───────────────────────────────────────────────────────────
  Future<void> togglePin(String id, bool current) async {
    // A manual re-pin clears any expiry window (indefinite pin).
    await _feedRef.child(id).update({'isPinned': !current, 'pinnedUntil': null});
  }

  // ─── Update an existing post's media + pin window ──────────────────────────
  // Used when an event's photos are re-approved: refresh the gallery post's
  // photos and re-pin it for a new window instead of creating a duplicate.
  Future<void> updatePostMedia({
    required String postId,
    List<String>? photoUrls,
    bool? isPinned,
    int? pinnedUntil,
  }) async {
    if (postId.isEmpty) return;
    final m = <String, dynamic>{
      'updatedAt': DateTime.now().millisecondsSinceEpoch,
      'pinnedUntil': pinnedUntil, // explicit — null clears the window
    };
    if (photoUrls != null) m['photos'] = photoUrls;
    if (isPinned != null) m['isPinned'] = isPinned;
    try {
      await _feedRef.child(postId).update(m);
    } catch (_) {}
  }

  // ─── Mark a post as seen by the current parent ─────────────────────────────
  // Writes `feed/{postId}/seenBy/{uid}`. Idempotent (one entry per parent) so
  // the manager's `seenCount` is a count of DISTINCT parents. Fire-and-forget:
  // seen-tracking must never break the parent's feed.
  Future<void> markPostSeen(String postId) async {
    final uid = _session.userId ?? '';
    if (uid.isEmpty || postId.isEmpty) return;
    try {
      await _feedRef.child(postId).child('seenBy').child(uid).set(
            ServerValue.timestamp,
          );
    } catch (_) {}
  }

  // ─── Latest posts (parent home peek) ───────────────────────────────────────
  // Small real-time window of the most recent posts, newest first. The home
  // card picks the newest one that matches this parent's audience and was
  // created today — so it self-clears at midnight.
  Stream<List<NurseryPostModel>> watchLatestPosts({int limit = 5}) {
    return _feedRef
        .orderByChild('createdAt')
        .limitToLast(limit)
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data == null || data is! Map) return <NurseryPostModel>[];
      final posts = <NurseryPostModel>[];
      for (final entry in data.entries) {
        try {
          final map = Map<String, dynamic>.from(entry.value as Map);
          posts.add(NurseryPostModel.fromJson(map, id: entry.key.toString()));
        } catch (_) {}
      }
      posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return posts;
    });
  }

  // ─── Image helpers ────────────────────────────────────────────────────────
  Future<List<String>> _uploadImages(String postId, List<XFile> images) async {
    final urls = <String>[];
    for (final xfile in images) {
      try {
        final compressed = await _compress(xfile.path);
        final file = compressed ?? File(xfile.path);
        final name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        final ref = _storage.ref('nurseries/$_nurseryId/feed/$postId/$name');
        await ref.putFile(file);
        urls.add(await ref.getDownloadURL());
      } catch (_) {}
    }
    return urls;
  }

  Future<File?> _compress(String path) async {
    try {
      final dir = await getTemporaryDirectory();
      final target =
          '${dir.path}/${DateTime.now().millisecondsSinceEpoch}_c.jpg';
      final result = await FlutterImageCompress.compressAndGetFile(
        path,
        target,
        quality: 75,
        minWidth: 1080,
        minHeight: 1080,
      );
      return result != null ? File(result.path) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _deleteImageByUrl(String url) async {
    try {
      await _storage.refFromURL(url).delete();
    } catch (_) {}
  }
}

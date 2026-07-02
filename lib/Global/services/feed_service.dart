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
      // pinned first, then by createdAt descending
      posts.sort((a, b) {
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
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
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );
      await _feedRef.child(id).set(post.toJson());
      return true;
    } catch (_) {
      return false;
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
      final regular = all.where((p) => !p.isPinned).toList()
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
    await _feedRef.child(id).update({'isPinned': !current});
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

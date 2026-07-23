import 'dart:io';

import '../../../Global/services/feed_service.dart';
import '../../../index/index_main.dart';

/// Orchestrates the "Star of the Week" workflow: publishing a manager's pick
/// both as a celebratory feed post AND as a stored [StarOfWeekModel] record so
/// the current star stays queryable (highlight card, history, one-per-week).
class StarOfWeekParentService {
  final BaseService<StarOfWeekModel> _service =
      Get.find<BaseService<StarOfWeekModel>>(tag: 'starOfWeek');

  final FeedService _feed = FeedService();

  Future<void> getAll({
    required Function(List<StarOfWeekModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  /// Publishes [star]: first creates the feed post from the child's avatar +
  /// caption, then saves the record (linked to the post) at a deterministic
  /// per-week id so it overwrites any earlier pick for the same week.
  ///
  /// When re-picking within the same week, pass the replaced pick's
  /// [previousPostId] so its now-orphaned feed post is removed (node only — the
  /// child's shared avatar in Storage is left untouched).
  /// Returns the saved record (with its new `postId`) on success, or null on
  /// failure — so the caller can refresh the "current star" and reveal it.
  ///
  /// [customImage] (optional) is a manager-supplied/captured photo that replaces
  /// the child's avatar in both the post and the reveal; when null the child's
  /// profile photo is used.
  Future<StarOfWeekModel?> publish({
    required StarOfWeekModel star,
    String? previousPostId,
    File? customImage,
  }) async {
    if (previousPostId != null && previousPostId.isNotEmpty) {
      await _feed.deletePostNode(previousPostId);
    }

    // Resolve the photo: a captured/uploaded image wins over the child's avatar.
    String? photoUrl = star.childPhotoUrl;
    if (customImage != null) {
      final uploaded = await _uploadStarImage(
        customImage,
        nurseryId: star.nurseryId,
        weekKey: star.weekKey,
      );
      if (uploaded != null) photoUrl = uploaded;
    }

    final postId = await _feed.createPostRaw(
      text: star.caption,
      category: PostCategory.starOfWeek,
      branchIds: star.branchId.isEmpty ? const [] : [star.branchId],
      photoUrls: (photoUrl != null && photoUrl.isNotEmpty)
          ? [photoUrl]
          : const [],
      authorName: star.pickedByName,
    );

    final record = star.copyWith(childPhotoUrl: photoUrl, postId: postId);
    ResponseStatus? status;
    await _service.addData(
      item: record,
      toJson: (m) => m.toJson(),
      id: record.key ?? '',
      voidCallBack: (s) => status = s,
    );
    return status == ResponseStatus.success ? record : null;
  }

  Future<String?> _uploadStarImage(
    File file, {
    required String nurseryId,
    required String weekKey,
  }) async {
    try {
      final ts = DateTime.now().millisecondsSinceEpoch;
      final ref = FirebaseStorage.instance
          .ref('nurseries/$nurseryId/starOfWeek/${weekKey}_$ts.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }
}

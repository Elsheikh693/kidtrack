import 'dart:io';

import '../../../index/index_main.dart';

/// CRUD + media orchestration for the SuperAdmin-managed tutorial videos.
///
/// Reads/writes go through the standard [BaseService] CRUD stack; raw file
/// uploads go to Firebase Storage under `tutorialVideos/<id>/...` and only the
/// resulting download URL is persisted on the model (progressive streaming).
class TutorialVideoParentService {
  final BaseService<TutorialVideoModel> _service =
      Get.find<BaseService<TutorialVideoModel>>(tag: 'tutorialVideos');

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> getAll({
    required Function(List<TutorialVideoModel?>) callBack,
  }) async {
    await _service.getData(data: const {}, voidCallBack: callBack);
  }

  Future<void> add({
    required TutorialVideoModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.addData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.key ?? '',
      voidCallBack: callBack,
    );
  }

  Future<void> update({
    required TutorialVideoModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.updateData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.key ?? '',
      voidCallBack: callBack,
    );
  }

  Future<void> delete({
    required String id,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.deleteData(id: id, voidCallBack: callBack);
  }

  /// Uploads the raw video file and returns its download URL. Reports byte
  /// progress via [onProgress] (0.0–1.0) so the UI can show an upload bar.
  Future<String> uploadVideo({
    required String id,
    required File file,
    void Function(double progress)? onProgress,
  }) async {
    final ref = _storage.ref('tutorialVideos/$id/video.mp4');
    final task = ref.putFile(
      file,
      SettableMetadata(contentType: 'video/mp4'),
    );
    if (onProgress != null) {
      task.snapshotEvents.listen((s) {
        if (s.totalBytes > 0) {
          onProgress(s.bytesTransferred / s.totalBytes);
        }
      });
    }
    await task;
    return ref.getDownloadURL();
  }

  /// Uploads an optional thumbnail image and returns its download URL.
  Future<String> uploadThumbnail({
    required String id,
    required File file,
  }) async {
    final ref = _storage.ref('tutorialVideos/$id/thumb.jpg');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  /// Best-effort cleanup of a video's storage folder on delete.
  Future<void> deleteMedia(String id) async {
    try {
      await _storage.ref('tutorialVideos/$id/video.mp4').delete();
    } catch (_) {}
    try {
      await _storage.ref('tutorialVideos/$id/thumb.jpg').delete();
    } catch (_) {}
  }
}

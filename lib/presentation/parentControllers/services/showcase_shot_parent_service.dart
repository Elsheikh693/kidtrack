import 'dart:io';

import '../../../index/index_main.dart';

/// CRUD + media orchestration for the SuperAdmin-managed website showcase shots.
///
/// Reads/writes go through the standard [BaseService] CRUD stack; raw image
/// uploads go to Firebase Storage under `showcaseShots/<id>.jpg` and only the
/// resulting download URL is persisted on the model.
class ShowcaseShotParentService {
  final BaseService<ShowcaseShotModel> _service =
      Get.find<BaseService<ShowcaseShotModel>>(tag: 'showcaseShots');

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> getAll({
    required Function(List<ShowcaseShotModel?>) callBack,
  }) async {
    await _service.getData(data: const {}, voidCallBack: callBack);
  }

  Future<void> add({
    required ShowcaseShotModel item,
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
    required ShowcaseShotModel item,
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

  /// Uploads the raw screenshot image and returns its download URL.
  Future<String> uploadImage({
    required String id,
    required File file,
  }) async {
    final ref = _storage.ref('showcaseShots/$id.jpg');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  /// Best-effort cleanup of a shot's storage file on delete.
  Future<void> deleteMedia(String id) async {
    try {
      await _storage.ref('showcaseShots/$id.jpg').delete();
    } catch (_) {}
  }
}

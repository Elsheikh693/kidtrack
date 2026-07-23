import 'dart:io';

import '../../../index/index_main.dart';

class AuthorizedPickupParentService {
  final BaseService<AuthorizedPickupModel> _service =
      Get.find<BaseService<AuthorizedPickupModel>>(tag: 'authorizedPickups');

  Future<void> getAll({required Function(List<AuthorizedPickupModel?>) callBack}) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  /// Uploads an authorized person's ID-card photo to Firebase Storage and
  /// returns its public download URL, or `null` on failure. The [file] is
  /// expected to already be compressed (e.g. via [PickedImage]).
  Future<String?> uploadIdImage({
    required String nurseryId,
    required String childId,
    required String pickupId,
    required File file,
  }) async {
    try {
      final ref = FirebaseStorage.instance
          .ref('nurseries/$nurseryId/children/$childId/pickups/$pickupId.jpg');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (_) {
      return null;
    }
  }

  Future<void> add({
    required AuthorizedPickupModel item,
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
    required AuthorizedPickupModel item,
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
}

import 'package:firebase_database/firebase_database.dart';
import '../../../index/index_main.dart';

class ChildParentService {
  final BaseService<ChildModel> _service =
      Get.find<BaseService<ChildModel>>(tag: 'children');

  Future<void> getAll({required Function(List<ChildModel?>) callBack}) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required ChildModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.addData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.key ?? '',
      voidCallBack: (status) {
        callBack(status);
        if (status == ResponseStatus.success) _syncChildrenCount();
      },
    );
  }

  Future<void> update({
    required ChildModel item,
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
    await _service.deleteData(
      id: id,
      voidCallBack: (status) {
        callBack(status);
        if (status == ResponseStatus.success) _syncChildrenCount();
      },
    );
  }

  /// Recomputes the enrolled-children count and mirrors it onto the public
  /// nursery registry record (`platform/info/{id}`) so pre-login Discovery can
  /// show "N children" without reading the whole tenant subtree.
  Future<void> _syncChildrenCount() async {
    final nurseryId = ApiConstants.nurseryId;
    if (nurseryId.isEmpty) return;
    try {
      final snap =
          await FirebaseDatabase.instance.ref(ApiConstants.children).get();
      final count = snap.exists && snap.value is Map
          ? (snap.value as Map).length
          : 0;
      await FirebaseDatabase.instance
          .ref('platform/info/$nurseryId/childrenCount')
          .set(count);
    } catch (_) {
      // Count is a best-effort display field; never block child CRUD on it.
    }
  }
}

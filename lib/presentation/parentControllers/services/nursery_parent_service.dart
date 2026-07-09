import 'package:cloud_functions/cloud_functions.dart';
import '../../../index/index_main.dart';

class NurseryParentService {
  final BaseService<NurseryModel> _service =
      Get.find<BaseService<NurseryModel>>(tag: 'nurseryInfo');

  /// [limit] caps the server-side result (Firebase `orderBy="$key"&limitToFirst`)
  /// so existence/first-record probes fetch one row instead of the whole list.
  Future<void> getAll({
    required Function(List<NurseryModel?>) callBack,
    int? limit,
  }) async {
    await _service.getData(
      data: limit == null ? const {} : FirebaseFilter.firstN(limit),
      voidCallBack: callBack,
    );
  }

  Future<void> add({
    required NurseryModel item,
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
    required NurseryModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.updateData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.key ?? '',
      voidCallBack: callBack,
    );
  }

  /// Full-cascade nursery removal (SuperAdmin). Deletes the global registry
  /// entry, the entire `platform/{id}` scoped subtree, every owner/staff/parent
  /// `users/{uid}` record + Firebase Auth account, activation codes and per-user
  /// notifications. Runs in the `deleteNursery` Cloud Function because the client
  /// SDK can only delete the signed-in user's Auth account. Returns true on
  /// success.
  Future<bool> deleteCascade(String nurseryId) async {
    if (nurseryId.isEmpty) return false;
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('deleteNursery');
      final result = await callable.call<Map<String, dynamic>>({
        'nurseryId': nurseryId,
      });
      return result.data['ok'] == true;
    } catch (_) {
      return false;
    }
  }
}

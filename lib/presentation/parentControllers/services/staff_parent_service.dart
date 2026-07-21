import 'package:firebase_database/firebase_database.dart';

import '../../../index/index_main.dart';

class StaffParentService {
  final BaseService<StaffModel> _service =
      Get.find<BaseService<StaffModel>>(tag: 'staff');

  Future<void> add({
    required StaffModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.addData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.uid,
      voidCallBack: callBack,
    );
  }

  Future<void> update({
    required StaffModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.updateData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.uid,
      voidCallBack: callBack,
    );
  }

  Future<void> getAll({
    required Function(List<StaffModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> delete({
    required String id,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.deleteData(id: id, voidCallBack: callBack);
  }

  /// Hard-deletes a staff member and every record that hangs off their account:
  /// the staff doc, their permission set, and the `users/{uid}` node. Mirrors the
  /// branch-manager cleanup in [BranchManagementService]. Returns true only when
  /// the staff doc itself was removed. (The Firebase Auth user can't be deleted
  /// from the client SDK; revoking the activation code is the caller's job.)
  Future<bool> deleteCompletely({required StaffModel staff}) async {
    bool ok = false;
    await _service.deleteData(
      id: staff.uid,
      voidCallBack: (status) => ok = status == ResponseStatus.success,
    );
    if (!ok) return false;

    await Get.find<PermissionParentService>()
        .delete(id: staff.uid, callBack: (_) {});
    await FirebaseDatabase.instance.ref('users/${staff.uid}').remove();
    return true;
  }
}

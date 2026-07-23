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

  /// Hard-deletes a staff member: the staff doc, their permission set, and this
  /// staff hat's membership. The global `users/{uid}` identity is removed ONLY
  /// when this was the person's last membership — the same person may still be a
  /// guardian here or staff at another nursery, and wiping their identity would
  /// break those logins. Returns true only when the staff doc itself was removed.
  /// (The Firebase Auth user can't be deleted from the client SDK; when the
  /// identity survives, keeping the auth account is in fact desirable so the same
  /// phone still resolves. Revoking the activation code is the caller's job.)
  Future<bool> deleteCompletely({required StaffModel staff}) async {
    bool ok = false;
    await _service.deleteData(
      id: staff.uid,
      voidCallBack: (status) => ok = status == ResponseStatus.success,
    );
    if (!ok) return false;

    await Get.find<PermissionParentService>()
        .delete(id: staff.uid, callBack: (_) {});

    final identity = Get.find<IdentityService>();
    await identity.removeMembership(
      uid: staff.uid,
      nurseryId: staff.nurseryId,
      role: staff.role.name,
    );
    final remaining = await identity.memberships(staff.uid);
    if (remaining.isEmpty) {
      await FirebaseDatabase.instance.ref('users/${staff.uid}').remove();
    }
    return true;
  }
}

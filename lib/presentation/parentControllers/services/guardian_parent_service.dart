import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../../index/index_main.dart';

class GuardianParentService {
  final BaseService<ParentModel> _service =
      Get.find<BaseService<ParentModel>>(tag: 'parents');

  Future<void> getAll({required Function(List<ParentModel?>) callBack}) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }

  Future<void> add({
    required ParentModel item,
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
    required ParentModel item,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.updateData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.uid,
      voidCallBack: callBack,
    );
  }

  Future<void> delete({
    required String uid,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.deleteData(id: uid, voidCallBack: callBack);
  }

  /// Unlinks [parentUid] from [childId] and, when that guardian is left with no
  /// other children, deletes their records AND their Firebase Auth account. The
  /// Auth delete needs the Admin SDK, so the whole cleanup runs server-side in
  /// the `removeGuardian` Cloud Function (mirrors the withdrawal orphan logic).
  /// Returns true on success.
  Future<bool> removeGuardian({
    required String childId,
    required String parentUid,
  }) async {
    final nurseryId = SessionService().nurseryId ?? '';
    if (nurseryId.isEmpty || childId.isEmpty || parentUid.isEmpty) return false;
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('removeGuardian');
      final result = await callable.call<Map<String, dynamic>>({
        'nurseryId': nurseryId,
        'childId': childId,
        'parentUid': parentUid,
      });
      return result.data['ok'] == true;
    } catch (_) {
      return false;
    }
  }

  /// Stamps the "WhatsApp invitation sent" timestamp on a guardian record.
  /// Writes only that one field (never the full model) so concurrent login
  /// telemetry the parent may set is not clobbered. Fire-and-forget: a failed
  /// write must never block the receptionist while sending invitations.
  Future<void> markInvitationSent(String uid) async {
    final nurseryId = SessionService().nurseryId ?? '';
    if (nurseryId.isEmpty || uid.isEmpty) return;
    try {
      await FirebaseDatabase.instance
          .ref('platform/$nurseryId/parents/$uid')
          .update({'invitationSentAt': ServerValue.timestamp});
    } catch (_) {}
  }
}

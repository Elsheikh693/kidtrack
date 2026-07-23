import 'dart:math';

import '../../../index/index_main.dart';

/// The role-agnostic Activation Engine — the ONLY layer that mints, rotates and
/// resolves account-activation codes. Every account in the platform (parent,
/// reception, teacher, manager, owner) is provisioned through here.
///
/// Codes live at a GLOBAL root (`activationCodes/{code}`, the code IS the key)
/// so they resolve BEFORE login, before the nursery/session is known.
///
/// A code is DURABLE: it keeps working as a login key until the creator calls
/// [regenerate], which rotates it (deletes the old key, mints a fresh one).
class ActivationParentService {
  final BaseService<ActivationCodeModel> _service =
      Get.find<BaseService<ActivationCodeModel>>(tag: 'activationCodes');

  /// Unambiguous alphabet — no O/0, I/1, L, etc. so a printed QR paper code can
  /// be typed by hand without confusion.
  static const String _alphabet = 'ABCDEFGHJKMNPQRSTUVWXYZ23456789';
  static final Random _rng = Random.secure();

  /// Human-readable 8-char code, hyphen-grouped: `KA4X-92QF`.
  String generateCode() {
    final buf = StringBuffer();
    for (var i = 0; i < 8; i++) {
      if (i == 4) buf.write('-');
      buf.write(_alphabet[_rng.nextInt(_alphabet.length)]);
    }
    return buf.toString();
  }

  /// Mint a brand-new code for [targetId]. Returns the persisted model (with the
  /// generated [code]) on success, or null on failure.
  Future<ActivationCodeModel?> generate({
    required String role,
    required String targetId,
    required String nurseryId,
    required String createdBy,
    bool silent = false,
  }) async {
    final model = ActivationCodeModel(
      code: generateCode(),
      role: role,
      targetId: targetId,
      nurseryId: nurseryId,
      createdBy: createdBy,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    ActivationCodeModel? result;
    await _service.addData(
      item: model,
      toJson: (m) => m.toJson(),
      id: model.code, // code IS the key → activationCodes/{code}
      silent: silent,
      voidCallBack: (status) {
        if (status == ResponseStatus.success) result = model.copyWith(key: model.code);
      },
    );
    return result;
  }

  /// Rotate the code for a target: delete the old key, mint a fresh one. This is
  /// the recovery path (lost phone / new device) and the revoke path in one.
  Future<ActivationCodeModel?> regenerate({
    required ActivationCodeModel current,
    bool silent = false,
  }) async {
    bool deleted = false;
    await _service.deleteData(
      id: current.code,
      voidCallBack: (status) => deleted = status == ResponseStatus.success,
    );
    if (!deleted) return null;

    return generate(
      role: current.role,
      targetId: current.targetId,
      nurseryId: current.nurseryId,
      createdBy: current.createdBy,
      silent: silent,
    );
  }

  /// Telemetry: flag that a code has been used at least once. Does NOT disable
  /// the code — it stays a valid login key until [regenerate].
  Future<void> markActivated(String code) async {
    ActivationCodeModel? found;
    await getAll(
      callBack: (list) {
        found = list
            .whereType<ActivationCodeModel>()
            .where((c) => c.code == code)
            .firstOrNull;
      },
    );
    if (found == null || found!.isActivated) return;

    await _service.updateData(
      item: found!.copyWith(isActivated: true),
      toJson: (m) => m.toJson(),
      id: found!.code,
      voidCallBack: (_) {},
    );
  }

  Future<void> delete({
    required String code,
    required Function(ResponseStatus) callBack,
  }) async {
    await _service.deleteData(id: code, voidCallBack: callBack);
  }

  Future<void> getAll({
    required Function(List<ActivationCodeModel?>) callBack,
  }) async {
    await _service.getData(data: {}, voidCallBack: callBack);
  }
}

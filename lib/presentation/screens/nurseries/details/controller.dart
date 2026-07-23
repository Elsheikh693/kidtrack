import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';
import 'nursery_feedback_admin_mixin.dart';
import 'nursery_staff_admin_mixin.dart';

/// SuperAdmin screen that drills into a single nursery: edit its info AND manage
/// its owners (list / add / edit / delete). The nursery itself lives in the
/// global registry ([ApiPaths.globalNurseries]); each owner is a `users/{uid}`
/// record whose uid is referenced from the nursery's `ownerIds`.
class NurseryDetailsController extends GetxController
    with NurseryFeedbackAdminMixin, NurseryStaffAdminMixin {
  final NurseryParentService _service = Get.find<NurseryParentService>();

  @override
  final Rx<NurseryModel> nursery = const NurseryModel(name: '').obs;
  final RxList<UserModel> owners = <UserModel>[].obs;
  final RxBool loadingOwners = true.obs;
  final RxBool savingInfo = false.obs;

  /// Set by [createOwner] when a fresh owner + code are minted; consumed by
  /// [_openForm] once the form sheet closes, so the activation sheet opens on a
  /// clean route instead of stacking under the closing form.
  ({ActivationCodeModel code, String name, String? phone})? _pendingActivation;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    final arg = Get.arguments;
    if (arg is NurseryModel) {
      nursery.value = arg;
      nameCtrl.text = arg.name;
      phoneCtrl.text = arg.phone ?? '';
      addressCtrl.text = arg.address ?? '';
      loadOwners();
      loadFeedback();
      loadStaffAndChildren();
    }
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    super.onClose();
  }

  String get _registryPath => '${ApiPaths.globalNurseries}/${nursery.value.key}';

  // ─── Owners ─────────────────────────────────────────────────────────────────

  Future<void> loadOwners() async {
    loadingOwners.value = true;
    final result = <UserModel>[];
    for (final uid in nursery.value.allOwnerIds) {
      try {
        final snap = await FirebaseDatabase.instance.ref('users/$uid').get();
        if (snap.exists && snap.value is Map) {
          final data = Map<String, dynamic>.from(snap.value as Map);
          data['uid'] = uid;
          result.add(UserModel.fromJson(data));
        } else {
          result.add(UserModel(uid: uid));
        }
      } catch (_) {
        result.add(UserModel(uid: uid));
      }
    }
    owners.value = result;
    loadingOwners.value = false;
  }

  /// Re-read the nursery record from the registry so `ownerIds`/`ownerId` stay
  /// in sync after an owner mutation (the model's copyWith can't null ownerId).
  Future<void> _reloadNursery() async {
    final key = nursery.value.key;
    if (key == null) return;
    final snap = await FirebaseDatabase.instance.ref(_registryPath).get();
    if (snap.exists && snap.value is Map) {
      nursery.value = NurseryModel.fromJson(
        Map<String, dynamic>.from(snap.value as Map),
        key: key,
      );
    }
  }

  // ─── Nursery info ────────────────────────────────────────────────────────────

  Future<void> saveInfo() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      Loader.showError('nursery_error_name'.tr);
      return;
    }
    final updated = nursery.value.copyWith(
      name: name,
      phone: phoneCtrl.text.trim().isEmpty ? null : phoneCtrl.text.trim(),
      address: addressCtrl.text.trim().isEmpty ? null : addressCtrl.text.trim(),
    );
    savingInfo.value = true;
    Loader.show();
    await _service.update(
      item: updated,
      callBack: (status) {
        Loader.dismiss();
        savingInfo.value = false;
        if (status == ResponseStatus.success) {
          nursery.value = updated;
          Loader.showSuccess('nursery_success_updated'.tr);
        } else {
          Loader.showError('nursery_error_failed'.tr);
        }
      },
    );
  }

  // ─── Owner form (add / edit) ─────────────────────────────────────────────────

  void openAddOwner() => _openForm(null);
  void openEditOwner(UserModel owner) => _openForm(owner);

  void _openForm(UserModel? owner) {
    Get.bottomSheet(
      OwnerFormSheet(
        owner: owner,
        nurseryName: nursery.value.name,
        onSubmit: owner == null
            ? createOwner
            : (name, phone) => updateOwner(owner, name, phone),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
    ).then((_) {
      // Form closed — if a new owner was just created, show its login code now.
      final pending = _pendingActivation;
      _pendingActivation = null;
      if (pending != null) {
        openActivationSheet(
          code: pending.code,
          recipientName: pending.name,
          phone: pending.phone,
          nurseryName: nursery.value.name,
          nurseryLogoUrl: nursery.value.logo,
        );
      }
    });
  }

  /// Show (or lazily mint) an owner's durable activation code — the passwordless
  /// login credential — so the super admin can deliver it or rotate it.
  Future<void> showOwnerActivation(UserModel owner) async {
    final uid = owner.uid;
    if (uid == null) return;
    final svc = Get.find<ActivationParentService>();

    ActivationCodeModel? code;
    await svc.getAll(
      callBack: (list) {
        code = list
            .whereType<ActivationCodeModel>()
            .where((c) => c.targetId == uid)
            .firstOrNull;
      },
    );
    code ??= await svc.generate(
      role: 'owner',
      targetId: uid,
      nurseryId: nursery.value.key ?? '',
      createdBy: SessionService().userId ?? '',
      silent: true,
    );

    if (code == null) {
      Loader.showError('activation_regenerate_error'.tr);
      return;
    }
    await openActivationSheet(
      code: code!,
      recipientName: owner.name ?? '',
      phone: owner.phone,
      nurseryName: nursery.value.name,
      nurseryLogoUrl: nursery.value.logo,
    );
  }

  /// One-tap: deliver the owner's login code straight to their WhatsApp number.
  Future<void> sendOwnerActivationWhatsApp(UserModel owner) async {
    final uid = owner.uid;
    final phone = owner.phone ?? '';
    if (uid == null) return;
    if (phone.trim().isEmpty) {
      Loader.showError('activation_no_phone'.tr);
      return;
    }
    final svc = Get.find<ActivationParentService>();

    ActivationCodeModel? code;
    await svc.getAll(
      callBack: (list) {
        code = list
            .whereType<ActivationCodeModel>()
            .where((c) => c.targetId == uid)
            .firstOrNull;
      },
    );
    code ??= await svc.generate(
      role: 'owner',
      targetId: uid,
      nurseryId: nursery.value.key ?? '',
      createdBy: SessionService().userId ?? '',
      silent: true,
    );

    if (code == null) {
      Loader.showError('activation_regenerate_error'.tr);
      return;
    }
    launchWhatsApp(
      phone,
      message: buildActivationMessage(
        role: 'owner',
        name: owner.name ?? '',
        code: code!.code,
        nurseryName: nursery.value.name,
      ),
    );
  }

  Future<bool> createOwner(String ownerName, String ownerPhone) async {
    Loader.show();
    final nurseryId = nursery.value.key ?? '';

    try {
      // Reuse the identity if this phone already exists — one person can now own
      // more than one nursery (an owner membership per nursery) instead of
      // failing with "phone already registered".
      final identity = Get.find<IdentityService>();
      final resolved =
          await identity.resolveByPhone(phone: ownerPhone, name: ownerName);
      final ownerUid = resolved.uid;

      await identity.attachMembership(
        uid: ownerUid,
        role: 'owner',
        nurseryId: nurseryId,
        name: ownerName,
        phone: ownerPhone,
      );

      final updated = nursery.value.copyWith(
        ownerIds: [...nursery.value.allOwnerIds, ownerUid],
      );

      bool ok = false;
      await _service.update(
        item: updated,
        callBack: (status) async {
          if (status == ResponseStatus.success) {
            ok = true;
          } else {
            // Roll back the owner membership; drop the identity too only if we
            // created it fresh and it is now left with no memberships.
            await identity.removeMembership(
              uid: ownerUid,
              nurseryId: nurseryId,
              role: 'owner',
            );
            if (resolved.created &&
                (await identity.memberships(ownerUid)).isEmpty) {
              await FirebaseDatabase.instance.ref('users/$ownerUid').remove();
            }
          }
        },
      );

      Loader.dismiss();
      if (ok) {
        await _reloadNursery();
        await loadOwners();
        // Mint the owner's passwordless login code; shown once the form closes.
        final code = await Get.find<ActivationParentService>().generate(
          role: 'owner',
          targetId: ownerUid,
          nurseryId: nurseryId,
          createdBy: SessionService().userId ?? '',
          silent: true,
        );
        if (code != null) {
          _pendingActivation =
              (code: code, name: ownerName, phone: ownerPhone);
        }
        Loader.showSuccess('nursery_owner_added'.tr);
        return true;
      }
      Loader.showError('nursery_error_failed'.tr);
      return false;
    } catch (_) {
      Loader.dismiss();
      Loader.showError('nursery_error_failed'.tr);
      return false;
    }
  }

  /// Edits the owner's profile record only. Login credentials (the Auth email,
  /// derived from the original phone) are intentionally NOT changed here.
  Future<bool> updateOwner(UserModel owner, String name, String phone) async {
    final uid = owner.uid;
    if (uid == null) return false;
    Loader.show();
    try {
      await FirebaseDatabase.instance.ref('users/$uid').update({
        'name': name,
        'phone': phone,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });
      Loader.dismiss();
      await loadOwners();
      Loader.showSuccess('nursery_owner_updated'.tr);
      return true;
    } catch (_) {
      Loader.dismiss();
      Loader.showError('nursery_error_failed'.tr);
      return false;
    }
  }

  // ─── Delete owner (full account removal) ─────────────────────────────────────

  Future<void> confirmDeleteOwner(UserModel owner) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text('nursery_owner_delete_title'.tr),
        content: Text('nursery_owner_delete_msg'.trParams({
          'name': owner.name ?? 'nursery_owner_unknown'.tr,
        })),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('common_cancel'.tr),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(
              'common_delete'.tr,
              style: TextStyle(color: AppColors.errorForeground),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) await _deleteOwner(owner);
  }

  Future<void> _deleteOwner(UserModel owner) async {
    final uid = owner.uid;
    final key = nursery.value.key;
    if (uid == null || key == null) return;

    Loader.show();
    try {
      final remaining =
          nursery.value.allOwnerIds.where((id) => id != uid).toList();

      // Direct registry write: PATCH-merge can't drop keys, and copyWith can't
      // null the legacy ownerId, so we set both explicitly (null removes it).
      await FirebaseDatabase.instance.ref(_registryPath).update({
        'ownerIds': remaining,
        'ownerId': remaining.isNotEmpty ? remaining.first : null,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Drop this owner membership. Remove the global identity + auth account
      // only if this was the person's last nursery (they may own another).
      final identity = Get.find<IdentityService>();
      await identity.removeMembership(uid: uid, nurseryId: key, role: 'owner');
      if ((await identity.memberships(uid)).isEmpty) {
        await FirebaseDatabase.instance.ref('users/$uid').remove();
        await _deleteOwnerAuth(owner);
      }

      await _reloadNursery();
      await loadOwners();
      Loader.dismiss();
      Loader.showSuccess('nursery_owner_deleted'.tr);
    } catch (_) {
      Loader.dismiss();
      Loader.showError('nursery_error_failed'.tr);
    }
  }

  /// Best-effort deletion of the owner's Firebase Auth account. The client SDK
  /// can only delete the *currently signed-in* user, so we sign into a throwaway
  /// secondary app with their known credentials (password == phone at creation)
  /// and delete from there. If the password was changed it silently no-ops and
  /// the profile/registry cleanup above still stands.
  Future<void> _deleteOwnerAuth(UserModel owner) async {
    final phone = owner.phone ?? '';
    final email = (owner.email != null && owner.email!.isNotEmpty)
        ? owner.email!
        : '$phone@gmail.com';
    if (phone.isEmpty) return;

    final secondaryApp = await Firebase.initializeApp(
      name: 'owner_del_${DateTime.now().millisecondsSinceEpoch}',
      options: Firebase.app().options,
    );
    try {
      final auth = FirebaseAuth.instanceFor(app: secondaryApp);
      await auth.signInWithEmailAndPassword(email: email, password: phone);
      await auth.currentUser?.delete();
    } catch (_) {
      // Credentials changed or already removed — registry/profile already clean.
    } finally {
      await secondaryApp.delete();
    }
  }
}

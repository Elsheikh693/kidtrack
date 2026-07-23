import '../../index/index_main.dart';

class ParentAccountService {
  final GuardianParentService _guardianService =
      Get.find<GuardianParentService>();
  final ParentChildParentService _linkService =
      Get.find<ParentChildParentService>();
  final _session = SessionService();

  /// Creates (or reuses) the guardian's identity by phone and links them to the
  /// given children. If the phone already belongs to someone on the platform —
  /// e.g. a teacher who is also this child's mum — we reuse the SAME uid and add
  /// a guardian membership instead of failing on "phone already registered".
  ///
  /// [password] is retained only for call-site compatibility; the identity is now
  /// resolved server-side (see [IdentityService.resolveByPhone]).
  Future<bool> createAccount({
    required String name,
    required String phone,
    required String password,
    List<String> childIds = const [],
    String relationship = 'other',
    required Function(String) onError,
  }) async {
    final email = '$phone@gmail.com';
    final nurseryId = _session.nurseryId ?? '';

    try {
      // 1. Resolve the single identity for this phone (created only if brand-new).
      final String uid;
      try {
        final res = await Get.find<IdentityService>()
            .resolveByPhone(phone: phone, name: name);
        uid = res.uid;
      } catch (_) {
        onError('guardian_create_error_general'.tr);
        return false;
      }

      // 2. Attach a guardian membership + merge identity (backfills a prior staff
      //    hat, so a teacher who becomes a mum keeps both logins).
      await Get.find<IdentityService>().attachMembership(
        uid: uid,
        role: 'parent',
        nurseryId: nurseryId,
        name: name,
        phone: phone,
      );

      // 3. Write parent profile
      final parentDone = Completer<ResponseStatus>();
      await _guardianService.add(
        item: ParentModel(
          uid: uid,
          name: name,
          phone: phone,
          email: email,
          isActive: true,
        ),
        callBack: parentDone.complete,
      );
      if (await parentDone.future != ResponseStatus.success) {
        onError('guardian_create_error_db'.tr);
        return false;
      }

      // 4. Children that already have a primary guardian — a newly linked
      // guardian only becomes primary when the child has none yet.
      final hasPrimary = <String>{};
      await _linkService.getAll(callBack: (list) {
        for (final l in list.whereType<ParentChildModel>()) {
          if (l.isPrimary) hasPrimary.add(l.childId);
        }
      });

      // Link to each selected child
      for (final cid in childIds) {
        if (cid.isEmpty) continue;
        final isPrimary = !hasPrimary.contains(cid);
        final linkDone = Completer<ResponseStatus>();
        await _linkService.add(
          item: ParentChildModel(
            key: '${uid}_$cid',
            parentId: uid,
            childId: cid,
            nurseryId: nurseryId,
            relationship: relationship,
            isPrimary: isPrimary,
          ),
          callBack: linkDone.complete,
        );
      }

      return true;
    } catch (_) {
      onError('guardian_create_error_general'.tr);
      return false;
    }
  }

  /// Links an existing parent to a child without creating a new auth account.
  /// Becomes primary guardian only if the child has none yet.
  Future<bool> linkChildToExistingParent({
    required String parentId,
    required String childId,
    String relationship = 'other',
    required Function(String) onError,
  }) async {
    try {
      final nurseryId = _session.nurseryId ?? '';

      var alreadyLinked = false;
      var hasPrimary = false;
      await _linkService.getAll(callBack: (list) {
        for (final l in list.whereType<ParentChildModel>()) {
          if (l.childId != childId) continue;
          if (l.isPrimary) hasPrimary = true;
          if (l.parentId == parentId) alreadyLinked = true;
        }
      });

      if (alreadyLinked) {
        onError('rc_parent_assign_already_linked'.tr);
        return false;
      }

      final done = Completer<ResponseStatus>();
      await _linkService.add(
        item: ParentChildModel(
          key: '${parentId}_$childId',
          parentId: parentId,
          childId: childId,
          nurseryId: nurseryId,
          relationship: relationship,
          isPrimary: !hasPrimary,
        ),
        callBack: done.complete,
      );
      if (await done.future != ResponseStatus.success) {
        onError('guardian_create_error_db'.tr);
        return false;
      }
      return true;
    } catch (_) {
      onError('guardian_create_error_general'.tr);
      return false;
    }
  }
}

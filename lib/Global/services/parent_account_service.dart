import 'package:firebase_database/firebase_database.dart';
import '../../index/index_main.dart';

class ParentAccountService {
  final GuardianParentService _guardianService =
      Get.find<GuardianParentService>();
  final ParentChildParentService _linkService =
      Get.find<ParentChildParentService>();
  final _session = SessionService();

  Future<bool> createAccount({
    required String name,
    required String phone,
    required String password,
    List<String> childIds = const [],
    String relationship = 'other',
    required Function(String) onError,
  }) async {
    // Convert phone to Firebase-compatible email: 01xxxxxxxxx@gmail.com
    final email = '$phone@gmail.com';
    FirebaseApp? tempApp;

    try {
      tempApp = await Firebase.initializeApp(
        name: 'parentCreation_${DateTime.now().millisecondsSinceEpoch}',
        options: Firebase.app().options,
      );
      final auth = FirebaseAuth.instanceFor(app: tempApp);
      final credential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final nurseryId = _session.nurseryId ?? '';

      // Write user record
      await FirebaseDatabase.instance.ref('users/$uid').set({
        'uid': uid,
        'name': name,
        'phone': phone,
        'email': email,
        'userType': 'parent',
        'nurseryId': nurseryId,
        'isActive': true,
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'updatedAt': DateTime.now().millisecondsSinceEpoch,
      });

      // Write parent profile
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

      // Children that already have a primary guardian — a newly linked
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
    } on FirebaseAuthException catch (e) {
      onError(_authError(e.code));
      return false;
    } catch (_) {
      onError('guardian_create_error_general'.tr);
      return false;
    } finally {
      try {
        await tempApp?.delete();
      } catch (_) {}
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

  String _authError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'guardian_create_error_phone_exists'.tr;
      case 'invalid-email':
        return 'guardian_create_error_phone'.tr;
      case 'weak-password':
        return 'guardian_create_error_weak_password'.tr;
      default:
        return 'guardian_create_error_auth'.tr;
    }
  }
}

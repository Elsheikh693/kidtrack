import 'package:firebase_database/firebase_database.dart';
import '../../index/index_main.dart';

/// The single post-authentication bootstrap, shared by EVERY sign-in path:
/// password login AND activation-code login (custom token). Given a freshly
/// authenticated [uid] it resolves the account, restores the nursery/branch
/// scope, enforces staff active/branch/shift checks, seeds telemetry, and routes
/// to the correct landing (first-login setup or main).
///
/// Extracted from the login controller so the activation flow reuses the exact
/// same routing/guards instead of drifting a parallel copy.
class AuthBootstrapService {
  final SessionService _session = SessionService();

  /// Runs the full bootstrap. Returns true when navigation happened; false on an
  /// unauthorized/failed account (an error is surfaced via [Loader] and the
  /// Firebase session is signed out — the caller only needs to stop its spinner).
  Future<bool> bootstrap(String uid, {User? firebaseUser}) async {
    if (await _checkSuperAdmin(uid, firebaseUser)) return true;
    return _fetchUserAndNavigate(uid);
  }

  // ── Super Admin ─────────────────────────────────────────────────────────────
  Future<bool> _checkSuperAdmin(String uid, User? firebaseUser) async {
    try {
      final snap = await FirebaseDatabase.instance.ref('superAdmins/$uid').get();
      if (!snap.exists) return false;

      final raw = snap.value;
      final data = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};

      if ((data['name']?.toString() ?? '').isEmpty) {
        final name = firebaseUser?.displayName?.trim().isNotEmpty == true
            ? firebaseUser!.displayName!
            : (firebaseUser?.email ?? 'Super Admin');
        await FirebaseDatabase.instance.ref('superAdmins/$uid').update({
          'uid': uid,
          'name': name,
          'email': firebaseUser?.email ?? '',
          'createdAt': DateTime.now().millisecondsSinceEpoch,
        });
        data['name'] = name;
        data['email'] = firebaseUser?.email ?? '';
      }

      final user = UserModel(
        uid: uid,
        name: data['name']?.toString(),
        email: data['email']?.toString(),
        userType: UserType.superAdmin,
      );
      // SuperAdmin is platform-wide, not tenant-bound. Drop any nurseryId left in
      // storage by a previous owner/staff login so global writes never get scoped
      // under a stale tenant.
      await _session.clearNurseryScope();
      await _session.saveUser(user);

      Loader.showSuccess('${'login_success'.tr}${data['name'] ?? 'Super Admin'}');
      await Future.delayed(const Duration(milliseconds: 1200));
      Get.offAllNamed(mainView);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Staff / Parent ──────────────────────────────────────────────────────────
  Future<bool> _fetchUserAndNavigate(String uid) async {
    try {
      final snap = await FirebaseDatabase.instance.ref('users/$uid').get();
      if (!snap.exists) {
        Loader.showError('login_error_unauthorized'.tr);
        await FirebaseAuth.instance.signOut();
        return false;
      }

      final raw = snap.value;
      final data = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
      data['uid'] = uid;

      final user = UserModel.fromJson(data);

      // Restore nursery scope
      final nurseryId = data['nurseryId']?.toString() ?? '';
      if (nurseryId.isNotEmpty) {
        await _session.saveNurseryId(nurseryId);
      }

      final branchId = data['branchId']?.toString() ?? '';
      if (branchId.isNotEmpty) {
        await _session.saveBranchId(branchId);
      }

      // Staff active check + save branchId/shift from staff record
      if (user.userType?.hasStaffRecord == true && nurseryId.isNotEmpty) {
        final staffSnap = await FirebaseDatabase.instance
            .ref('platform/$nurseryId/staff/$uid')
            .get();
        if (staffSnap.exists) {
          final staffRaw = staffSnap.value;
          final staffData = staffRaw is Map
              ? Map<String, dynamic>.from(staffRaw)
              : <String, dynamic>{};
          final isActive = staffData['isActive'];
          if (isActive == false || isActive == 0 || isActive == '0') {
            Loader.showError('login_error_inactive'.tr);
            await FirebaseAuth.instance.signOut();
            return false;
          }
          final staffBranchId = staffData['branchId']?.toString() ?? '';
          if (staffBranchId.isNotEmpty) {
            await _session.saveBranchId(staffBranchId);
          }
          await _session.saveShift(staffData['shift']?.toString());
        }
      }

      await _session.saveUser(user);

      // Seed parent engagement telemetry (best-effort, never blocks login).
      if (user.userType == UserType.parent) {
        unawaited(ParentEngagementService().markLogin());
      }

      unawaited(FcmTokenService().attach(
        uid: uid,
        isStaff: user.userType?.hasStaffRecord ?? false,
        nurseryId: _session.nurseryId,
      ));

      Loader.showSuccess('${'login_success'.tr}${user.name ?? ''}');
      await Future.delayed(const Duration(milliseconds: 1200));

      final target = await _resolveFirstLoginTarget(uid, user);
      Get.delete<MainPageViewModel>(force: true);
      Get.offAllNamed(target);
      return true;
    } catch (_) {
      Loader.showError('login_error_general'.tr);
      await FirebaseAuth.instance.signOut();
      return false;
    }
  }

  // ── First-Login Target ──────────────────────────────────────────────────────
  // The setup checklist is now opened on demand from the "More" tab rather than
  // forced at first login, so every role lands on the main view after auth.
  Future<String> _resolveFirstLoginTarget(String uid, UserModel user) async {
    return mainView;
  }
}

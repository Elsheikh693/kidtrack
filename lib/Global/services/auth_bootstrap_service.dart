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

      // One identity can wear several hats (teacher + mum, or staff at two
      // nurseries). When it does, let the person choose which membership this
      // session runs as; the picker calls [finalizeMembership] with the choice.
      final memberships = await Get.find<IdentityService>().memberships(uid);
      await _session.saveMembershipCount(memberships.length);
      if (memberships.length >= 2) {
        Get.offAllNamed(membershipPickerView, arguments: {
          'uid': uid,
          'identity': data,
          'memberships': memberships.map((m) => m.toJson()).toList(),
        });
        return true;
      }

      // Single membership → that one. Legacy account (no memberships node yet) →
      // fall back to the scalar userType/nurseryId written on the users node.
      final String role;
      final String nurseryId;
      final String branchId;
      if (memberships.length == 1) {
        final m = memberships.first;
        role = m.role;
        nurseryId = m.nurseryId;
        branchId = m.branchId ?? (data['branchId']?.toString() ?? '');
      } else {
        role = data['userType']?.toString() ?? '';
        nurseryId = data['nurseryId']?.toString() ?? '';
        branchId = data['branchId']?.toString() ?? '';
      }

      return finalizeMembership(
        uid: uid,
        identity: data,
        role: role,
        nurseryId: nurseryId,
        branchId: branchId,
      );
    } catch (_) {
      Loader.showError('login_error_general'.tr);
      await FirebaseAuth.instance.signOut();
      return false;
    }
  }

  /// Applies a chosen membership (role × nursery × branch) to the session, runs
  /// the staff active/branch/shift guards, seeds telemetry and routes to main.
  /// Shared by the single/legacy path above AND the membership picker, so both
  /// go through the exact same guards. Returns true when navigation happened.
  Future<bool> finalizeMembership({
    required String uid,
    required Map<String, dynamic> identity,
    required String role,
    required String nurseryId,
    required String branchId,
  }) async {
    try {
      final user = UserModel(
        uid: uid,
        name: identity['name']?.toString(),
        phone: identity['phone']?.toString(),
        email: identity['email']?.toString(),
        userType: UserTypeExtension.fromString(role),
      );

      // Restore nursery/branch scope; reset staff-only scope (re-derived below).
      if (nurseryId.isNotEmpty) {
        await _session.saveNurseryId(nurseryId);
      } else {
        await _session.clearNurseryScope();
      }
      if (branchId.isNotEmpty) {
        await _session.saveBranchId(branchId);
      } else {
        _session.clearBranchId();
      }
      await _session.saveShifts(const []);
      await _session.saveReviewPhotos(false);

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
          await _session.saveShifts(_readShiftIds(staffData));
          await _session.saveReviewPhotos(
            await _readReviewPhotosPermission(nurseryId, uid),
          );
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

  /// Reads whether this staff member was granted the "review activity photos"
  /// permission from their permissionSets record. Owners/branch managers get it
  /// implicitly in [SessionService.canReviewPhotos], so this only matters for
  /// other staff (e.g. reception).
  Future<bool> _readReviewPhotosPermission(String nurseryId, String uid) async {
    try {
      // Read the whole `permissions` map and look the key up in Dart — the
      // permission key contains a '.', which Firebase forbids in a PATH segment.
      // Appending it to ref() throws a native NSException (SIGABRT) that Dart
      // can't catch, taking the whole app down on login for any staff-record
      // role (reception/teacher/…). Owners have no staff record so they skipped
      // this and never hit it. Indexing the map avoids the illegal path.
      final snap = await FirebaseDatabase.instance
          .ref('platform/$nurseryId/permissionSets/$uid/permissions')
          .get();
      final value = snap.value;
      if (value is! Map) return false;
      final granted = value[PermissionKeys.classroomReviewPhotos];
      return granted == true || granted == 1 || granted == '1';
    } catch (_) {
      return false;
    }
  }

  /// Reads the staff record's shift list, migrating the legacy single `shift`
  /// string ('both'/empty → no restriction) so old accounts keep resolving.
  List<String> _readShiftIds(Map<String, dynamic> data) {
    final raw = data['shiftIds'];
    if (raw is List) {
      return raw.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    if (raw is Map) {
      return raw.values.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
    }
    final legacy = data['shift']?.toString();
    if (legacy == null || legacy.isEmpty || legacy == 'both') return const [];
    return [legacy];
  }
}

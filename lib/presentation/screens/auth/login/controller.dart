import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';

class LoginController extends GetxController {
  // ── Observables ───────────────────────────────────────────────────────────
  final email = ''.obs;
  final password = ''.obs;
  final isEmailValid = false.obs;
  final isPasswordValid = false.obs;
  final showPassword = false.obs;
  final isLoading = false.obs;

  // ── Text Controllers ──────────────────────────────────────────────────────
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  StreamSubscription<String>? _tokenSub;

  late final SessionService _session;
  late final FirebaseCredentialsService _credentials;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    _session = SessionService();
    _credentials = Get.find<FirebaseCredentialsService>();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    _tokenSub?.cancel();
    super.onClose();
  }

  // ── Computed ──────────────────────────────────────────────────────────────
  bool get canSubmit => isEmailValid.value && isPasswordValid.value;

  // ── Clear form ────────────────────────────────────────────────────────────
  void clearForm() {
    emailController.clear();
    passwordController.clear();
    email.value = '';
    password.value = '';
    isEmailValid.value = false;
    isPasswordValid.value = false;
    showPassword.value = false;
  }

  // ── Validation ────────────────────────────────────────────────────────────
  void validateEmail(String value) {
    final v = value.trim();
    final isPhone = RegExp(r'^\d{9,15}$').hasMatch(v);
    final isEmail = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(v);
    email.value = isPhone ? '$v@gmail.com' : v;
    isEmailValid.value = v.isNotEmpty && (isPhone || isEmail);
  }

  void validatePassword(String value) {
    password.value = value;
    isPasswordValid.value = value.isNotEmpty && value.length >= 6;
  }

  void togglePassword() => showPassword.toggle();

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<void> login() async {
    if (isLoading.value) return;
    isLoading.value = true;
    Loader.show();

    final result = await _credentials.signIn(
      FirebaseAuthModel(email: email.value, password: passwordController.text),
    );

    result.fold(
      (error) {
        isLoading.value = false;
        Loader.showError(error.message);
      },
      (credential) async {
        final uid = credential.user?.uid;
        if (uid == null) {
          isLoading.value = false;
          Loader.showError('login_error_uid_null'.tr);
          return;
        }
        final handled = await _checkSuperAdmin(uid, credential.user);
        if (!handled) await _fetchUserAndNavigate(uid);
      },
    );
  }

  // ── Super Admin ───────────────────────────────────────────────────────────
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
      // SuperAdmin is platform-wide, not tenant-bound. Drop any nurseryId left
      // in storage by a previous owner/staff login so global writes (e.g. the
      // nursery registry) never get scoped under a stale tenant.
      await _session.clearNurseryScope();
      await _session.saveUser(user);

      isLoading.value = false;
      Loader.showSuccess('${'login_success'.tr}${data['name'] ?? 'Super Admin'}');
      await Future.delayed(const Duration(milliseconds: 1200));
      Get.offAllNamed(mainView);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Staff / Parent ────────────────────────────────────────────────────────
  Future<void> _fetchUserAndNavigate(String uid) async {
    try {
      final snap = await FirebaseDatabase.instance.ref('users/$uid').get();
      if (!snap.exists) {
        isLoading.value = false;
        Loader.showError('login_error_unauthorized'.tr);
        await FirebaseAuth.instance.signOut();
        return;
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

      // Staff active check + save branchId from staff record
      if (user.userType?.isStaffRole == true && nurseryId.isNotEmpty) {
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
            isLoading.value = false;
            Loader.showError('login_error_inactive'.tr);
            await FirebaseAuth.instance.signOut();
            return;
          }
          final staffBranchId = staffData['branchId']?.toString() ?? '';
          if (staffBranchId.isNotEmpty) {
            await _session.saveBranchId(staffBranchId);
          }
          // Bind the staff member to their shift (morning / evening / both).
          await _session.saveShift(staffData['shift']?.toString());
        }
      }

      await _session.saveUser(user);

      // Live access guard for all roles is started by the MainPage gate after
      // validateOnce() passes — see MainPageViewModel.

      // Seed parent engagement telemetry (best-effort, never blocks login).
      if (user.userType == UserType.parent) {
        unawaited(ParentEngagementService().markLogin());
      }

      unawaited(_updateFcmToken(uid, isStaff: user.userType?.isStaffRole ?? false));

      isLoading.value = false;
      Loader.showSuccess('${'login_success'.tr}${user.name ?? ''}');
      await Future.delayed(const Duration(milliseconds: 1200));

      // First-login setup check
      final target = await _resolveFirstLoginTarget(uid, user);
      Get.delete<MainPageViewModel>(force: true);
      Get.offAllNamed(target);
    } catch (_) {
      isLoading.value = false;
      Loader.showError('login_error_general'.tr);
      await FirebaseAuth.instance.signOut();
    }
  }

  // ── First-Login Target ────────────────────────────────────────────────────
  Future<String> _resolveFirstLoginTarget(String uid, UserModel user) async {
    final setupView = user.userType == UserType.owner
        ? ownerSetupView
        : user.userType == UserType.branchManager
            ? managerSetupView
            : null;
    if (setupView == null) return mainView;

    // Local marker is the reliable per-device gate: once a user finishes setup
    // it survives logout and never re-shows, even if the server flag is wiped.
    if (SetupLocalCheck.isDone(uid)) return mainView;

    try {
      final snap =
          await FirebaseDatabase.instance.ref('users/$uid/setupDone').get();
      if (snap.value == true) {
        // Backfill the local marker so subsequent logins skip the remote read.
        await SetupLocalCheck.markDone(uid);
        return mainView;
      }
      return setupView;
    } catch (_) {
      return mainView;
    }
  }

  // ── FCM Token ─────────────────────────────────────────────────────────────
  Future<void> _updateFcmToken(String uid, {required bool isStaff}) async {
    try {
      await NotificationService().initCore();
      String? token = NotificationService().token;
      token ??= await FirebaseMessaging.instance.getToken();
      if (token == null) return;
      _tokenSub?.cancel();
      _tokenSub = FirebaseMessaging.instance.onTokenRefresh.listen((t) {
        _saveToken(uid, t, isStaff: isStaff);
      });
      await _saveToken(uid, token, isStaff: isStaff);
    } catch (_) {}
  }

  Future<void> _saveToken(String uid, String token, {required bool isStaff}) async {
    final path = isStaff
        ? 'platform/${_session.nurseryId ?? ''}/staff/$uid'
        : 'users/$uid';
    try {
      await FirebaseDatabase.instance.ref(path).update({'fcmToken': token});
    } catch (_) {}
  }
}

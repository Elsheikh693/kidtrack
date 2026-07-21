import 'package:uuid/uuid.dart';
import '../../Data/models/user/user_model.dart';
import '../../Data/models/user/user_type.dart';
import '../../Global/constants/api_constants.dart';
import '../../Global/Utils/logger.dart';
import 'storage_service.dart';

class SessionService {
  SessionService._internal();

  static final SessionService _instance = SessionService._internal();

  factory SessionService() => _instance;

  // ─── Storage Keys ─────────────────────────────────────────────────────────
  static const _userKey = 'session_user';
  static const _nurseryIdKey = 'session_nursery_id';
  static const _branchIdKey = 'session_branch_id';
  static const _shiftKey = 'session_shift';
  static const _guestIdKey = 'session_guest_id';
  static const _viewModeKey = 'session_view_mode';
  static const _actingBranchKey = 'session_acting_branch';
  static const _reviewPhotosKey = 'session_review_photos';

  // ─── In-memory state ──────────────────────────────────────────────────────
  UserModel? _currentUser;
  String? _nurseryId;
  String? _branchId;
  List<String> _shiftIds = []; // ShiftModel keys — empty = sees all shifts
  // Granted permission to review/approve activity photos. Owners and branch
  // managers get it implicitly (see [canReviewPhotos]); other staff (e.g.
  // reception) only when the owner turns it on for them.
  bool _canReviewPhotos = false;

  // Temporary "act as" override. The real identity in [_currentUser] is never
  // touched — an owner stays `userType == owner` forever. [_viewMode] only
  // changes which app shell (owner vs manager) is rendered.
  UserType? _viewMode;
  String? _actingBranchId;

  // ─── Getters ──────────────────────────────────────────────────────────────

  UserModel? get currentUser => _currentUser;

  String? get nurseryId => _nurseryId;

  String? get branchId => _branchId;

  List<String> get shiftIds => _shiftIds;

  String? get userId => _currentUser?.uid ?? _currentUser?.guestId;

  UserType? get userType => _currentUser?.userType;

  // ─── View Mode (Acting As) ──────────────────────────────────────────────────

  UserType? get viewMode => _viewMode;

  String? get actingBranchId => _actingBranchId;

  /// The role the app shell should render. Falls back to the real role when no
  /// override is active.
  UserType get effectiveRole => _viewMode ?? userType ?? UserType.parent;

  bool get isViewingAsManager => _viewMode == UserType.branchManager;

  /// Only a real owner is allowed to switch into another view.
  bool get canSwitchRole => userType == UserType.owner;

  /// True when the current user is not bound to any shift (owner, or a staff
  /// member assigned to every shift) and therefore sees everything.
  bool get seesAllShifts => _shiftIds.isEmpty;

  /// Whether a single-shift entity tagged with [entityShift] is visible to the
  /// current user. Unassigned ('both'/null) entities are visible to everyone so
  /// legacy data is never hidden. A 'between' child spans both shifts, so it is
  /// also visible to morning and evening staff alike.
  bool seesShift(String? entityShift) {
    if (seesAllShifts) return true;
    if (entityShift == null ||
        entityShift.isEmpty ||
        entityShift == 'both' ||
        entityShift == 'between') {
      return true;
    }
    return _shiftIds.contains(entityShift);
  }

  /// Whether a multi-shift entity (e.g. a staff member) is visible: true when
  /// it shares at least one shift with the current user, or is unassigned.
  bool seesAnyShift(List<String> entityShiftIds) {
    if (seesAllShifts) return true;
    if (entityShiftIds.isEmpty) return true;
    return entityShiftIds.any(seesShift);
  }

  /// Whether an entity in [entityBranchId] is within the current user's branch
  /// scope. A user with no bound branch (owner/super-admin, or a staff record
  /// that lacks a branch) sees every branch; a branch-bound user (teacher,
  /// supervisor, reception) sees ONLY their own branch. Empty [entityBranchId]
  /// is treated as visible so legacy data is never hidden — mirrors [seesShift].
  ///
  /// This is the guard that keeps a teacher assigned to a shared/all-branches
  /// classroom from seeing children of a different branch: classroom rosters are
  /// queried by classroomId (which can span branches), so each child must also
  /// pass this branch check.
  bool seesBranch(String? entityBranchId) {
    final mine = branchId;
    if (mine == null || mine.isEmpty) return true;
    if (entityBranchId == null || entityBranchId.isEmpty) return true;
    return entityBranchId == mine;
  }

  bool get isLoggedIn => _currentUser != null && !(_currentUser!.isGuest);

  bool get isGuest => _currentUser == null || (_currentUser!.isGuest);

  bool get hasSession => _currentUser != null;

  bool get isSuperAdmin => userType == UserType.superAdmin;

  bool get isOwner => userType == UserType.owner;

  bool get isTeacher => userType == UserType.teacher;

  bool get isNanny => userType == UserType.nanny;

  bool get isReceptionist => userType == UserType.receptionist;

  bool get isParent => userType == UserType.parent;

  bool get isStaff => userType?.isStaffRole ?? false;

  /// True only for users with a real record under the `staff` node (excludes
  /// the owner, who lives in `users`). Use for anything scoped to the staff
  /// node — e.g. where to store the FCM token.
  bool get hasStaffRecord => userType?.hasStaffRecord ?? false;

  bool get isBusChaperone => userType == UserType.busChaperone;

  /// Whether the current user may review & approve activity photos. Owners and
  /// branch managers always can; other staff need the granted flag.
  bool get canReviewPhotos =>
      isOwner || userType == UserType.branchManager || _canReviewPhotos;

  // ─── Init ─────────────────────────────────────────────────────────────────

  Future<void> init() async {
    await _restoreUser();
    await _restoreNurseryId();
    await _restoreBranchId();
    await _restoreShift();
    await _restoreReviewPhotos();
    await _restoreViewMode();
    AppLogger.info(
      'SESSION',
      isLoggedIn
          ? '✅ uid: ${_currentUser?.uid} | role: ${userType?.name}'
          : '👤 Guest session',
    );
    // TEMP DEBUG — full session snapshot to diagnose branch/shift scoping.
  }

  // ─── Save User ────────────────────────────────────────────────────────────

  Future<void> saveUser(UserModel user) async {
    _currentUser = user;
    await StorageService().setData(_userKey, user.toJson());
    AppLogger.info('SESSION', 'User saved — uid: ${user.uid}');
  }

  // ─── Save Nursery ID ──────────────────────────────────────────────────────

  Future<void> saveNurseryId(String id) async {
    _nurseryId = id;
    ApiConstants.setNurseryId(id);
    await StorageService().setData(_nurseryIdKey, {'id': id});
    AppLogger.info('SESSION', 'Nursery ID saved: $id');
  }

  // ─── Save Branch ID ───────────────────────────────────────────────────────

  Future<void> saveBranchId(String id) async {
    _branchId = id;
    await StorageService().setData(_branchIdKey, {'id': id});
    AppLogger.info('SESSION', 'Branch ID saved: $id');
  }

  void clearBranchId() {
    _branchId = null;
    StorageService().remove(_branchIdKey);
  }

  /// Wipes the nursery scope from memory, ApiConstants AND persistent storage.
  /// Must be used by any session that is NOT tenant-bound (e.g. SuperAdmin) so a
  /// stale nurseryId left in storage by a prior owner/staff login can never leak
  /// into global writes.
  Future<void> clearNurseryScope() async {
    _nurseryId = null;
    ApiConstants.setNurseryId('');
    await StorageService().remove(_nurseryIdKey);
  }

  // ─── Save Shift ───────────────────────────────────────────────────────────

  Future<void> saveShifts(List<String> shiftIds) async {
    _shiftIds = shiftIds.where((s) => s.isNotEmpty).toList();
    if (_shiftIds.isNotEmpty) {
      await StorageService().setData(_shiftKey, {'ids': _shiftIds});
    } else {
      await StorageService().remove(_shiftKey);
    }
    AppLogger.info(
      'SESSION',
      'Shifts saved: ${_shiftIds.isEmpty ? '(all)' : _shiftIds.join(',')}',
    );
  }

  // ─── Save Review-Photos permission ──────────────────────────────────────────

  Future<void> saveReviewPhotos(bool granted) async {
    _canReviewPhotos = granted;
    if (granted) {
      await StorageService().setData(_reviewPhotosKey, {'v': true});
    } else {
      await StorageService().remove(_reviewPhotosKey);
    }
  }

  // ─── View Mode (Acting As) ──────────────────────────────────────────────────

  /// Owner enters "manager of [branchId]" view. No-op for non-owners. The real
  /// `userType` stays `owner`; only the rendered shell + branch scope change.
  Future<void> enterManagerMode(String branchId) async {
    if (userType != UserType.owner) return;
    _viewMode = UserType.branchManager;
    _actingBranchId = branchId;
    await saveBranchId(branchId);
    await StorageService().setData(_viewModeKey, {'role': _viewMode!.name});
    await StorageService().setData(_actingBranchKey, {'id': branchId});
    AppLogger.info('SESSION', 'Entered manager view — branch: $branchId');
  }

  /// Back to the owner shell (network scope).
  Future<void> exitManagerMode() async {
    _viewMode = null;
    _actingBranchId = null;
    clearBranchId();
    await StorageService().remove(_viewModeKey);
    await StorageService().remove(_actingBranchKey);
    AppLogger.info('SESSION', 'Exited manager view — back to owner');
  }

  // ─── Guest Mode ───────────────────────────────────────────────────────────

  Future<UserModel> getOrCreateGuest() async {
    final stored = StorageService().getData(_guestIdKey);
    final guestId = stored?['id'] as String? ?? const Uuid().v4();
    if (stored == null) {
      await StorageService().setData(_guestIdKey, {'id': guestId});
    }
    final guest = UserModel(guestId: guestId, isGuest: true);
    _currentUser = guest;
    return guest;
  }

  // ─── Update helpers ───────────────────────────────────────────────────────

  Future<void> updateFcmToken(String token) async {
    if (_currentUser == null) return;
    _currentUser = _currentUser!.copyWith(fcmToken: token);
    await StorageService().setData(_userKey, _currentUser!.toJson());
  }

  Future<void> updateUser(UserModel updated) async {
    _currentUser = updated;
    await StorageService().setData(_userKey, updated.toJson());
  }

  // ─── Clear (logout) ───────────────────────────────────────────────────────

  Future<void> clear() async {
    _currentUser = null;
    _nurseryId = null;
    _branchId = null;
    _shiftIds = [];
    _canReviewPhotos = false;
    _viewMode = null;
    _actingBranchId = null;
    ApiConstants.setNurseryId('');
    await StorageService().remove(_userKey);
    await StorageService().remove(_nurseryIdKey);
    await StorageService().remove(_branchIdKey);
    await StorageService().remove(_shiftKey);
    await StorageService().remove(_reviewPhotosKey);
    await StorageService().remove(_viewModeKey);
    await StorageService().remove(_actingBranchKey);
    AppLogger.info('SESSION', 'Session cleared — logged out');
  }

  // ─── Private Restore ──────────────────────────────────────────────────────

  Future<void> _restoreUser() async {
    try {
      final data = StorageService().getData(_userKey);
      if (data != null) _currentUser = UserModel.fromJson(data);
    } catch (e) {
      AppLogger.warning('SESSION', 'Could not restore user: $e');
    }
  }

  Future<void> _restoreNurseryId() async {
    try {
      final data = StorageService().getData(_nurseryIdKey);
      final id = data?['id'] as String?;
      if (id != null && id.isNotEmpty) {
        _nurseryId = id;
        ApiConstants.setNurseryId(id);
      }
    } catch (e) {
      AppLogger.warning('SESSION', 'Could not restore nurseryId: $e');
    }
  }

  Future<void> _restoreBranchId() async {
    try {
      final data = StorageService().getData(_branchIdKey);
      final id = data?['id'] as String?;
      if (id != null && id.isNotEmpty) _branchId = id;
    } catch (e) {
      AppLogger.warning('SESSION', 'Could not restore branchId: $e');
    }
  }

  Future<void> _restoreShift() async {
    try {
      final data = StorageService().getData(_shiftKey);
      if (data == null) return;
      final ids = data['ids'];
      if (ids is List) {
        _shiftIds = ids.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
      } else {
        // Legacy single-shift storage.
        final id = data['id'] as String?;
        if (id != null && id.isNotEmpty) _shiftIds = [id];
      }
    } catch (e) {
      AppLogger.warning('SESSION', 'Could not restore shift: $e');
    }
  }

  Future<void> _restoreReviewPhotos() async {
    try {
      final data = StorageService().getData(_reviewPhotosKey);
      _canReviewPhotos = data?['v'] == true;
    } catch (e) {
      AppLogger.warning('SESSION', 'Could not restore reviewPhotos: $e');
    }
  }

  Future<void> _restoreViewMode() async {
    // Only a real owner may persist a manager view; ignore otherwise.
    if (userType != UserType.owner) return;
    try {
      final role = StorageService().getData(_viewModeKey)?['role'] as String?;
      final branch =
          StorageService().getData(_actingBranchKey)?['id'] as String?;
      if (role == UserType.branchManager.name &&
          branch != null &&
          branch.isNotEmpty) {
        _viewMode = UserType.branchManager;
        _actingBranchId = branch;
        if (_branchId == null || _branchId!.isEmpty) _branchId = branch;
      }
    } catch (e) {
      AppLogger.warning('SESSION', 'Could not restore view mode: $e');
    }
  }
}

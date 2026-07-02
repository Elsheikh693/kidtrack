
import '../../index/index_main.dart';

class AuthenticationService {
  // ─── Singleton ────────────────────────────────────────────────────────────

  static final AuthenticationService _instance =
      AuthenticationService._internal();

  factory AuthenticationService() => _instance;

  AuthenticationService._internal();

  final AuthenticationUseCases useCase = initController(
    () => AuthenticationUseCases(Get.find()),
  );

  // ─── Realtime Callbacks ───────────────────────────────────────────────────

  Function(UserModel user)? onUserAdded;
  Function(UserModel user)? onUserUpdated;
  Function(String key)? onUserRemoved;

  StreamSubscription? _addedSub;
  StreamSubscription? _changedSub;
  StreamSubscription? _removedSub;

  bool _isListening = false;

  // ─── Realtime Sync ────────────────────────────────────────────────────────

  Future<void> startListening() async {
    if (_isListening) return;

    await useCase.startListening();

    _addedSub = useCase.onAdded.listen((user) {
      onUserAdded?.call(user);
    });

    _changedSub = useCase.onChanged.listen((user) {
      onUserUpdated?.call(user);
    });

    _removedSub = useCase.onRemoved.listen((key) {
      onUserRemoved?.call(key);
    });

    _isListening = true;
  }

  // ─── Add ──────────────────────────────────────────────────────────────────

  Future<void> addUserData({
    required UserModel user,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    final result = await useCase.addUser(user);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ─── Update ───────────────────────────────────────────────────────────────

  Future<void> updateUserData({
    required UserModel user,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    final result = await useCase.updateUser(user);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ─── Delete ───────────────────────────────────────────────────────────────

  Future<void> deleteUserData({
    required String uid,
    required Function(ResponseStatus) voidCallBack,
  }) async {
    final result = await useCase.deleteUser(uid);

    result.fold(
      (l) => voidCallBack(ResponseStatus.error),
      (r) => voidCallBack(ResponseStatus.success),
    );
  }

  // ─── Get All (Online) ─────────────────────────────────────────────────────

  Future<void> getUsersData({
    required FirebaseFilter firebaseFilter,
    required Function(List<UserModel>) voidCallBack,
  }) async {
    final result = await useCase.getUsers(firebaseFilter.toJson());

    result.fold(
      (l) => Loader.showError("Network error while loading users"),
      (r) => voidCallBack(r),
    );
  }

  // ─── Get By UID (Online) ──────────────────────────────────────────────────

  Future<void> getUserByUid({
    required String uid,
    required Function(UserModel? user) voidCallBack,
  }) async {
    final result = await useCase.getUserByUid(uid);

    result.fold(
      (l) {
        Loader.showError("Network error while fetching user");
        voidCallBack(null);
      },
      (user) => voidCallBack(user),
    );
  }

  // ─── Dispose ──────────────────────────────────────────────────────────────

  Future<void> dispose() async {
    _isListening = false;

    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();

    await useCase.dispose();
  }
}

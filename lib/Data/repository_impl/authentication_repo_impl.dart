
import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class AuthenticationRepositoryImpl implements AuthenticationRepository {
  final AuthenticationRemoteDataSource _remote;

  AuthenticationRepositoryImpl(this._remote);

  StreamSubscription? _addedSub;
  StreamSubscription? _changedSub;
  StreamSubscription? _removedSub;

  // ─── Stream Controllers ───────────────────────────────────────────────────

  final _addedController = StreamController<UserModel>.broadcast();
  final _changedController = StreamController<UserModel>.broadcast();
  final _removedController = StreamController<String>.broadcast();

  @override
  Stream<UserModel> get onAdded => _addedController.stream;

  @override
  Stream<UserModel> get onChanged => _changedController.stream;

  @override
  Stream<String> get onRemoved => _removedController.stream;

  // ─── Realtime ─────────────────────────────────────────────────────────────

  @override
  Future<void> startListening() async {
    await dispose();
    await _remote.startListening();

    _addedSub = _remote.onAdded.listen((json) {
      _addedController.add(UserModel.fromJson(json));
    });

    _changedSub = _remote.onChanged.listen((json) {
      _changedController.add(UserModel.fromJson(json));
    });

    _removedSub = _remote.onRemoved.listen((uid) {
      _removedController.add(uid);
    });
  }

  @override
  Future<void> dispose() async {
    await _addedSub?.cancel();
    await _changedSub?.cancel();
    await _removedSub?.cancel();
    await _remote.stopListening();

    if (!_addedController.isClosed) await _addedController.close();
    if (!_changedController.isClosed) await _changedController.close();
    if (!_removedController.isClosed) await _removedController.close();
  }

  // ─── Read ─────────────────────────────────────────────────────────────────

  @override
  Future<Either<AppError, List<UserModel>>> getUsersDomain(
    Map<String, dynamic> filters,
  ) async {
    try {
      final list = await _remote.fetchUsers(filters);
      return Right(list.map((e) => UserModel.fromJson(e)).toList());
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, UserModel?>> getUserByUidDomain(String uid) async {
    try {
      final json = await _remote.fetchUserByUid(uid);
      if (json == null) return const Right(null);
      return Right(UserModel.fromJson(json));
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  // ─── Write ────────────────────────────────────────────────────────────────

  @override
  Future<Either<AppError, Unit>> addUserDomain(UserModel user) async {
    try {
      await _remote.createUser(user.toJson());
      return const Right(unit);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, Unit>> updateUserDomain(UserModel user) async {
    try {
      await _remote.updateUser(user.toJson());
      return const Right(unit);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, Unit>> deleteUserDomain(String uid) async {
    try {
      await _remote.deleteUser(uid);
      return const Right(unit);
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}

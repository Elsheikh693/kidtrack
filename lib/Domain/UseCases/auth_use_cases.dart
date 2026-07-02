import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class AuthenticationUseCases {
  final AuthenticationRepository _repository;

  AuthenticationUseCases(this._repository);

  // ─── Realtime ─────────────────────────────────────────────────────────────

  Future<void> startListening() => _repository.startListening();

  Future<void> dispose() => _repository.dispose();

  Stream<UserModel> get onAdded => _repository.onAdded;
  Stream<UserModel> get onChanged => _repository.onChanged;
  Stream<String> get onRemoved => _repository.onRemoved;

  // ─── Read ─────────────────────────────────────────────────────────────────

  Future<Either<AppError, List<UserModel>>> getUsers(
    Map<String, dynamic> filters,
  ) {
    return _repository.getUsersDomain(filters);
  }

  Future<Either<AppError, UserModel?>> getUserByUid(String uid) {
    return _repository.getUserByUidDomain(uid);
  }

  // ─── Write ────────────────────────────────────────────────────────────────

  Future<Either<AppError, Unit>> addUser(UserModel user) {
    return _repository.addUserDomain(user);
  }

  Future<Either<AppError, Unit>> updateUser(UserModel user) {
    return _repository.updateUserDomain(user);
  }

  Future<Either<AppError, Unit>> deleteUser(String uid) {
    return _repository.deleteUserDomain(uid);
  }
}

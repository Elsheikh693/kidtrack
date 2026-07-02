import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class AuthenticationRepository {
  // ─── Realtime ─────────────────────────────────────────────────────────────
  Future<void> startListening();
  Future<void> dispose();

  Stream<UserModel> get onAdded;
  Stream<UserModel> get onChanged;
  Stream<String> get onRemoved;

  // ─── Read ─────────────────────────────────────────────────────────────────
  Future<Either<AppError, List<UserModel>>> getUsersDomain(
    Map<String, dynamic> filters,
  );

  Future<Either<AppError, UserModel?>> getUserByUidDomain(String uid);

  // ─── Write ────────────────────────────────────────────────────────────────
  Future<Either<AppError, Unit>> addUserDomain(UserModel user);

  Future<Either<AppError, Unit>> updateUserDomain(UserModel user);

  Future<Either<AppError, Unit>> deleteUserDomain(String uid);
}

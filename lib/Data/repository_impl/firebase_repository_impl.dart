import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class FirebaseRepositoryImpl extends FirebaseRepository {
  final FirebaseDataSource _remote;

  FirebaseRepositoryImpl(this._remote);

  @override
  Future<Either<AppError, UserCredential>> loginDomain(
    FirebaseAuthModel model,
  ) async {
    final result = await _remote.loginWithFirebase(model);
    return result is Success<UserCredential>
        ? right(result.data)
        : left(AppError((result as Failure).error.message));
  }

  @override
  Future<Either<AppError, UserCredential>> signupDomain(
    FirebaseAuthModel model,
  ) async {
    final result = await _remote.signupWithFirebase(model);
    return result is Success<UserCredential>
        ? right(result.data)
        : left(AppError((result as Failure).error.message));
  }

  @override
  Future<Either<AppError, String>> uploadImageDomain(
    String key,
    File image,
  ) async {
    final result = await _remote.uploadImage(key, image);
    return result is Success<String>
        ? right(result.data)
        : left(AppError((result as Failure).error.message));
  }
}

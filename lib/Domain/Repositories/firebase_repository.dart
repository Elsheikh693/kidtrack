import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class FirebaseRepository {
  Future<Either<AppError, UserCredential>> loginDomain(FirebaseAuthModel model);

  Future<Either<AppError, UserCredential>> signupDomain(FirebaseAuthModel model);

  Future<Either<AppError, String>> uploadImageDomain(String key, File image);
}

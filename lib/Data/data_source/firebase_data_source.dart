import 'dart:io';
import '../../index/index_main.dart';

abstract class FirebaseDataSource {
  Future<ApiResult<UserCredential>> loginWithFirebase(FirebaseAuthModel model);

  Future<ApiResult<UserCredential>> signupWithFirebase(FirebaseAuthModel model);

  Future<ApiResult<String>> uploadImage(String key, File image);
}

import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

/// Service يلف كل عمليات Firebase Auth (Sign In / Sign Up / Upload Image)
/// يتسجل في الـ Binding ويتجاب بـ Get.find()
class FirebaseCredentialsService {
  final FirebaseSignInUseCase _signIn;
  final FirebaseSignUpUseCase _signUp;
  final FirebaseUploadImageUseCase _uploadImage;

  FirebaseCredentialsService({
    required FirebaseSignInUseCase signIn,
    required FirebaseSignUpUseCase signUp,
    required FirebaseUploadImageUseCase uploadImage,
  })  : _signIn = signIn,
        _signUp = signUp,
        _uploadImage = uploadImage;

  // ─── Sign In ──────────────────────────────────────────────────────────────

  Future<Either<AppError, UserCredential>> signIn(
    FirebaseAuthModel model,
  ) => _signIn(model);

  // ─── Sign Up ──────────────────────────────────────────────────────────────

  Future<Either<AppError, UserCredential>> signUp(
    FirebaseAuthModel model,
  ) => _signUp(model);

  // ─── Upload Image ─────────────────────────────────────────────────────────

  Future<Either<AppError, String>> uploadImage(
    String key,
    File image,
  ) => _uploadImage(UploadImageParams(key: key, image: image));
}

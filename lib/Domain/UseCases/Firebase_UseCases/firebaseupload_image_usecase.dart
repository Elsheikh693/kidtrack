import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class UploadImageParams {
  final String key;
  final File image;
  const UploadImageParams({required this.key, required this.image});
}

class FirebaseUploadImageUseCase extends UseCase<String, UploadImageParams> {
  final FirebaseRepository _repository;

  FirebaseUploadImageUseCase(this._repository);

  @override
  Future<Either<AppError, String>> call(UploadImageParams input) {
    return _repository.uploadImageDomain(input.key, input.image);
  }
}

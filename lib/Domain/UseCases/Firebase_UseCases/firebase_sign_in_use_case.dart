import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class FirebaseSignInUseCase extends UseCase<UserCredential, FirebaseAuthModel> {
  final FirebaseRepository _repository;

  FirebaseSignInUseCase(this._repository);

  @override
  Future<Either<AppError, UserCredential>> call(FirebaseAuthModel input) {
    return _repository.loginDomain(input);
  }
}

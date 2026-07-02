import 'package:dartz/dartz.dart';
import '../../../index/index_main.dart';

class FirebaseSignUpUseCase extends UseCase<UserCredential, FirebaseAuthModel> {
  final FirebaseRepository _repository;

  FirebaseSignUpUseCase(this._repository);

  @override
  Future<Either<AppError, UserCredential>> call(FirebaseAuthModel input) {
    return _repository.signupDomain(input);
  }
}

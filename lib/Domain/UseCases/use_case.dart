import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class UseCase<Output, Input> {
  Future<Either<AppError, Output>> call(Input input);
}

abstract class UseCaseNoReturn<Input> {
  Future<Either<AppError, Unit>> call(Input input);
}

T initController<T>(T Function() createInstance) {
  if (!Get.isRegistered<T>()) {
    Get.lazyPut<T>(createInstance, fenix: true);
  }
  return Get.find<T>();
}

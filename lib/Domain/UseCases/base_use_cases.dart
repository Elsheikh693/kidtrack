import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class BaseUseCases<T> {
  final BaseRepository<T> repository;

  BaseUseCases(this.repository);

  Future<Either<AppError, List<T?>>> getItems(Map<String, dynamic> params) {
    return repository.getAllDomain(params);
  }

  Future<Either<AppError, SuccessModel>> addItem(
    Map<String, dynamic> data,
    String id,
  ) {
    return repository.addDomain(data, id);
  }

  Future<Either<AppError, SuccessModel>> updateItem(
    Map<String, dynamic> data,
    String id,
  ) {
    return repository.updateDomain(data, id);
  }

  Future<Either<AppError, SuccessModel>> deleteItem(String id) {
    return repository.deleteDomain({}, id);
  }
}

import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

class BaseRepositoryImpl<T> extends BaseRepository<T> {
  final BaseCrudRepo<T> repo;

  BaseRepositoryImpl(this.repo);

  @override
  Future<Either<AppError, List<T?>>> getAllDomain(
    Map<String, dynamic> params,
  ) async {
    try {
      return Right(await repo.getAll(params));
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> addDomain(
    Map<String, dynamic> data,
    String id,
  ) async {
    try {
      return Right(await repo.add(data, id));
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> updateDomain(
    Map<String, dynamic> data,
    String id,
  ) async {
    try {
      return Right(await repo.update(data, id));
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }

  @override
  Future<Either<AppError, SuccessModel>> deleteDomain(
    Map<String, dynamic> data,
    String id,
  ) async {
    try {
      return Right(await repo.delete(data, id));
    } catch (e) {
      return Left(AppError(e.toString()));
    }
  }
}

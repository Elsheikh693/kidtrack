import 'package:dartz/dartz.dart';
import '../../index/index_main.dart';

abstract class BaseRepository<T> {
  Future<Either<AppError, List<T?>>> getAllDomain(Map<String, dynamic> params);

  Future<Either<AppError, SuccessModel>> addDomain(Map<String, dynamic> data, String id);

  Future<Either<AppError, SuccessModel>> updateDomain(Map<String, dynamic> data, String id);

  Future<Either<AppError, SuccessModel>> deleteDomain(Map<String, dynamic> data, String id);
}

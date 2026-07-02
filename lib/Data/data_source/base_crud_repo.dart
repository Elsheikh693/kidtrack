import '../../index/index_main.dart';

abstract class BaseCrudRepo<T> {
  Future<List<T?>> getAll(Map<String, dynamic> params);

  Future<SuccessModel> add(Map<String, dynamic> data, String id);

  Future<SuccessModel> update(Map<String, dynamic> data, String id);

  Future<SuccessModel> delete(Map<String, dynamic> data, String id);
}

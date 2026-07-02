
import '../../index/index_main.dart';

class BaseBinding {
  static void bindCrud<T>({
    required String tag,
    required String Function() baseUrl,
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    /// =========================
    /// DATA SOURCE
    /// =========================
    Get.lazyPut<BaseCrudRepo<T>>(
      () => BaseCrudRepoImpl<T>(
        client: Get.find<ClientSourceRepo>(),
        fromJson: fromJson,
        endpoint: baseUrl,
      ),
      tag: tag,
      fenix: true,
    );

    /// =========================
    /// REPOSITORY
    /// =========================
    Get.lazyPut<BaseRepository<T>>(
      () => BaseRepositoryImpl<T>(Get.find<BaseCrudRepo<T>>(tag: tag)),
      tag: tag,
      fenix: true,
    );

    /// =========================
    /// USE CASES
    /// =========================
    Get.lazyPut<BaseUseCases<T>>(
      () => BaseUseCases<T>(Get.find<BaseRepository<T>>(tag: tag)),
      tag: tag,
      fenix: true,
    );

    /// =========================
    /// SERVICE
    /// =========================
    Get.lazyPut<BaseService<T>>(
      () => BaseService<T>(Get.find<BaseUseCases<T>>(tag: tag)),
      tag: tag,
      fenix: true,
    );
  }
}

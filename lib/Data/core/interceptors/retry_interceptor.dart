import 'package:dio/dio.dart';
import '../../../Global/Utils/logger.dart';

/// Automatically retries failed requests on network/timeout errors.
/// Uses exponential backoff: 1s → 2s → 3s
class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;

  static const _retryKey = '_retryCount';

  RetryInterceptor({required this.dio, this.maxRetries = 3});

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_shouldRetry(err)) {
      handler.next(err);
      return;
    }

    final retryCount = (err.requestOptions.extra[_retryKey] as int?) ?? 0;

    if (retryCount >= maxRetries) {
      AppLogger.warning(
        'RETRY',
        'Max retries ($maxRetries) reached for ${err.requestOptions.uri}',
      );
      handler.next(err);
      return;
    }

    final nextCount = retryCount + 1;
    err.requestOptions.extra[_retryKey] = nextCount;

    final delay = Duration(seconds: nextCount); // 1s, 2s, 3s
    AppLogger.warning(
      'RETRY',
      'Attempt $nextCount/$maxRetries — retrying in ${delay.inSeconds}s: ${err.requestOptions.uri}',
    );

    await Future.delayed(delay);

    try {
      final response = await dio.fetch(err.requestOptions);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  // ─── Retry only on transient network errors ───────────────────────────────

  bool _shouldRetry(DioException err) {
    if (err.requestOptions.extra[_retryKey] != null &&
        (err.requestOptions.extra[_retryKey] as int) >= maxRetries) {
      return false;
    }

    return err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError;
  }
}

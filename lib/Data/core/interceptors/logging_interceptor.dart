import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../Global/Utils/logger.dart';

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.info(
        'REQ',
        '➡️  ${options.method} ${options.uri}',
      );
      if (options.queryParameters.isNotEmpty) {
        AppLogger.debug('REQ', 'Query: ${options.queryParameters}');
      }
      if (options.data != null) {
        AppLogger.debug('REQ', 'Body: ${options.data}');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.success(
        'RES',
        '✅ ${response.statusCode} ${response.requestOptions.uri}',
      );
      AppLogger.debug('RES', 'Data: ${response.data}');
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      AppLogger.error(
        'ERR',
        '❌ ${err.response?.statusCode ?? err.type.name} ${err.requestOptions.uri}',
        err,
        err.stackTrace,
      );
      if (err.response?.data != null) {
        AppLogger.debug('ERR', 'Response body: ${err.response?.data}');
      }
    }
    handler.next(err);
  }
}

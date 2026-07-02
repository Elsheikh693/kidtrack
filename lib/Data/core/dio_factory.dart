import 'package:dio/dio.dart';
import '../../Global/constants/api_constants.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/retry_interceptor.dart';

class DioFactory {
  DioFactory._();

  static Dio create() {
    final dio = Dio(_baseOptions());

    dio.interceptors.addAll([
      // 1️⃣ Retry first — so retried requests also pass through auth+log
      RetryInterceptor(dio: dio, maxRetries: 3),

      // 2️⃣ Inject Firebase auth token
      AuthInterceptor(),

      // 3️⃣ Convert errors to ApiErrorModel
      ErrorInterceptor(),

      // 4️⃣ Log everything (last so it captures the final state)
      LoggingInterceptor(),
    ]);

    return dio;
  }

  static BaseOptions _baseOptions() {
    return BaseOptions(
      baseUrl: '${ApiConstants.baseUrl}/',
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      responseType: ResponseType.json,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) => status != null && status < 500,
    );
  }
}

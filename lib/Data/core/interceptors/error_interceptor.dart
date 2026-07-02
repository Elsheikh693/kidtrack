import 'package:dio/dio.dart';
import '../../models/core/api_error_model.dart';
import '../../../Global/Utils/logger.dart';

/// Converts every DioException into an ApiErrorModel and attaches it
/// to the exception's [error] field so upstream callers can read it cleanly.
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiError = ApiErrorModel.fromDio(err);

    AppLogger.error(
      'ERROR_INTERCEPTOR',
      '[${apiError.statusCode}] ${apiError.message}',
      err,
    );

    // Attach the structured error, keep original DioException type intact
    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: apiError,           // ← our ApiErrorModel lives here
        stackTrace: err.stackTrace,
        message: apiError.message,
      ),
    );
  }
}

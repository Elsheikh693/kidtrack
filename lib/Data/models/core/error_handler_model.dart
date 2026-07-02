import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'api_error_model.dart';

/// Utility to convert any error type to ApiErrorModel.
/// Used by non-Dio code paths (FirebaseDataSourceImpl, etc.)
class ErrorHandler {
  ErrorHandler._();

  static ApiErrorModel handle(dynamic error) {
    if (error is ApiErrorModel) return error;

    if (error is DioException) return ApiErrorModel.fromDio(error);

    if (error is TimeoutException) {
      return const ApiErrorModel(
        message: 'انتهت مدة الاتصال، حاول مرة أخرى.',
        statusCode: 408,
      );
    }

    if (error is SocketException) {
      return const ApiErrorModel(
        message: 'لا يوجد اتصال بالإنترنت.',
        statusCode: 503,
      );
    }

    if (error is HttpException) {
      return const ApiErrorModel(
        message: 'فشل طلب HTTP، حاول مرة أخرى.',
        statusCode: 500,
      );
    }

    if (error is FormatException) {
      return const ApiErrorModel(
        message: 'صيغة الاستجابة غير صحيحة.',
        statusCode: 400,
      );
    }

    return ApiErrorModel(message: error.toString());
  }
}

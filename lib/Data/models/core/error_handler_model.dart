import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'api_error_model.dart';

/// Utility to convert any error type to ApiErrorModel.
/// Used by non-Dio code paths (FirebaseDataSourceImpl, etc.)
class ErrorHandler {
  ErrorHandler._();

  static ApiErrorModel handle(dynamic error) {
    if (error is ApiErrorModel) return error;

    if (error is DioException) return ApiErrorModel.fromDio(error);

    if (error is TimeoutException) {
      return ApiErrorModel(
        message: 'datamodels2_error_timeout'.tr,
        statusCode: 408,
      );
    }

    if (error is SocketException) {
      return ApiErrorModel(
        message: 'datamodels2_error_no_internet'.tr,
        statusCode: 503,
      );
    }

    if (error is HttpException) {
      return ApiErrorModel(
        message: 'datamodels2_error_http'.tr,
        statusCode: 500,
      );
    }

    if (error is FormatException) {
      return ApiErrorModel(
        message: 'datamodels2_error_format'.tr,
        statusCode: 400,
      );
    }

    return ApiErrorModel(message: error.toString());
  }
}

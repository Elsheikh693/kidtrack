import 'package:dio/dio.dart';
import 'package:get/get.dart';

class ApiErrorModel {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiErrorModel({
    required this.message,
    this.statusCode,
    this.data,
  });

  // ─── From DioException ────────────────────────────────────────────────────

  factory ApiErrorModel.fromDio(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiErrorModel(
          message: 'datamodels2_error_timeout'.tr,
          statusCode: 408,
        );

      case DioExceptionType.connectionError:
        return ApiErrorModel(
          message: 'datamodels2_error_no_internet'.tr,
          statusCode: 503,
        );

      case DioExceptionType.badResponse:
        return ApiErrorModel._fromResponse(
          e.response?.data,
          e.response?.statusCode,
        );

      case DioExceptionType.cancel:
        return ApiErrorModel(
          message: 'datamodels2_error_cancelled'.tr,
          statusCode: 0,
        );

      default:
        return ApiErrorModel(
          message: e.message ?? 'datamodels2_error_unexpected'.tr,
          statusCode: e.response?.statusCode,
        );
    }
  }

  // ─── From Response Body ───────────────────────────────────────────────────

  factory ApiErrorModel._fromResponse(dynamic body, int? statusCode) {
    if (body == null) {
      return ApiErrorModel(
        message: _messageForStatus(statusCode),
        statusCode: statusCode,
      );
    }

    if (body is String && body.isNotEmpty) {
      return ApiErrorModel(message: body, statusCode: statusCode);
    }

    if (body is Map<String, dynamic>) {
      final msg = body['message'] ??
          body['error'] ??
          body['detail'] ??
          body['msg'];

      if (msg is String && msg.isNotEmpty) {
        return ApiErrorModel(message: msg, statusCode: statusCode, data: body);
      }

      if (body.containsKey('errors')) {
        final errors = body['errors'];
        final buffer = StringBuffer();

        if (errors is String) {
          buffer.write(errors);
        } else if (errors is Map<String, dynamic>) {
          errors.forEach((_, v) {
            if (v is List) buffer.writeln(v.join(', '));
          });
        } else if (errors is List) {
          buffer.write(errors.join(', '));
        }

        return ApiErrorModel(
          message: buffer.toString().trim(),
          statusCode: statusCode,
          data: body,
        );
      }
    }

    return ApiErrorModel(
      message: _messageForStatus(statusCode),
      statusCode: statusCode,
      data: body,
    );
  }

  // ─── Default HTTP status messages ─────────────────────────────────────────

  static String _messageForStatus(int? code) {
    switch (code) {
      case 400:
        return 'datamodels2_error_400'.tr;
      case 401:
        return 'datamodels2_error_401'.tr;
      case 403:
        return 'datamodels2_error_403'.tr;
      case 404:
        return 'datamodels2_error_404'.tr;
      case 409:
        return 'datamodels2_error_409'.tr;
      case 422:
        return 'datamodels2_error_422'.tr;
      case 429:
        return 'datamodels2_error_429'.tr;
      case 500:
        return 'datamodels2_error_500'.tr;
      case 502:
        return 'datamodels2_error_502'.tr;
      case 503:
        return 'datamodels2_error_503'.tr;
      default:
        return 'datamodels2_error_unexpected'.tr;
    }
  }

  @override
  String toString() => message;
}

import 'package:dio/dio.dart';

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
        return const ApiErrorModel(
          message: 'انتهت مدة الاتصال، حاول مرة أخرى.',
          statusCode: 408,
        );

      case DioExceptionType.connectionError:
        return const ApiErrorModel(
          message: 'لا يوجد اتصال بالإنترنت.',
          statusCode: 503,
        );

      case DioExceptionType.badResponse:
        return ApiErrorModel._fromResponse(
          e.response?.data,
          e.response?.statusCode,
        );

      case DioExceptionType.cancel:
        return const ApiErrorModel(
          message: 'تم إلغاء الطلب.',
          statusCode: 0,
        );

      default:
        return ApiErrorModel(
          message: e.message ?? 'حدث خطأ غير متوقع.',
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
        return 'طلب غير صالح.';
      case 401:
        return 'غير مصرح لك، سجّل دخولك مرة أخرى.';
      case 403:
        return 'ليس لديك صلاحية للوصول.';
      case 404:
        return 'المورد المطلوب غير موجود.';
      case 409:
        return 'تعارض في البيانات، حاول مرة أخرى.';
      case 422:
        return 'بيانات غير صحيحة.';
      case 429:
        return 'طلبات كثيرة جداً، انتظر قليلاً.';
      case 500:
        return 'خطأ في الخادم، حاول لاحقاً.';
      case 502:
        return 'الخادم لا يستجيب.';
      case 503:
        return 'الخدمة غير متاحة حالياً.';
      default:
        return 'حدث خطأ غير متوقع.';
    }
  }

  @override
  String toString() => message;
}

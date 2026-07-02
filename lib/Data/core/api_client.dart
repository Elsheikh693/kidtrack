import 'dart:io';
import 'package:dio/dio.dart';
import '../models/core/api_error_model.dart';
import 'dio_factory.dart';

// ─── HTTP Method Enum ──────────────────────────────────────────────────────
// Kept for backward compatibility with BaseCrudRepoImpl

enum HttpMethod { get, post, patch, put, delete }

// ─── Client ───────────────────────────────────────────────────────────────

class ClientSourceRepo {
  late final Dio _dio;

  ClientSourceRepo() {
    _dio = DioFactory.create();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔥 Main Request — used by BaseCrudRepoImpl
  // ═══════════════════════════════════════════════════════════════════════════

  Future<dynamic> request(
    HttpMethod method,
    String path, {
    Map<String, dynamic>? params,
    Map<String, String>? extraHeaders,
  }) async {
    try {
      final cleanedData = _clean(params);

      final options = Options(
        method: method.name,
        headers: extraHeaders,
      );

      // GET / DELETE → query params | others → body
      final isBodyless =
          method == HttpMethod.get || method == HttpMethod.delete;

      final response = await _dio.request(
        path,
        queryParameters: isBodyless ? cleanedData : null,
        data: isBodyless ? null : cleanedData,
        options: options,
      );

      return _parse(response);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📁 Upload — Single File
  // ═══════════════════════════════════════════════════════════════════════════

  Future<dynamic> uploadFile(
    String path,
    File file, {
    String field = 'file',
    Map<String, dynamic>? extraFields,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        field: await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        if (extraFields != null) ...extraFields,
      });

      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: onSendProgress,
      );

      return _parse(response);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 📦 Upload — Multiple Files (FormData)
  // ═══════════════════════════════════════════════════════════════════════════

  Future<dynamic> uploadMultipart(
    String path,
    FormData formData, {
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
        onSendProgress: onSendProgress,
      );

      return _parse(response);
    } on DioException catch (e) {
      throw _extractError(e);
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // 🌐 Shorthand Methods
  // ═══════════════════════════════════════════════════════════════════════════

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? params,
  }) => request(HttpMethod.get, path, params: params);

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? data,
  }) => request(HttpMethod.post, path, params: data);

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? data,
  }) => request(HttpMethod.patch, path, params: data);

  Future<dynamic> put(
    String path, {
    Map<String, dynamic>? data,
  }) => request(HttpMethod.put, path, params: data);

  Future<dynamic> delete(
    String path, {
    Map<String, dynamic>? params,
  }) => request(HttpMethod.delete, path, params: params);

  // ═══════════════════════════════════════════════════════════════════════════
  // 🔒 Private Helpers
  // ═══════════════════════════════════════════════════════════════════════════

  /// Parse response — return null for empty/null bodies
  dynamic _parse(Response response) {
    final data = response.data;
    if (data == null) return null;
    if (data is String && (data.isEmpty || data == 'null')) return null;
    return data;
  }

  /// Extract ApiErrorModel from DioException
  ApiErrorModel _extractError(DioException e) {
    if (e.error is ApiErrorModel) return e.error as ApiErrorModel;
    return ApiErrorModel.fromDio(e);
  }

  /// Remove null / empty values from maps
  Map<String, dynamic> _clean(Map<String, dynamic>? data) {
    if (data == null) return {};
    return Map.from(data)
      ..removeWhere((_, v) => v == null || v.toString().isEmpty);
  }
}

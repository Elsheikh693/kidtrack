import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  // ─────────────────────────────────────────────
  // 🔧 Config
  // ─────────────────────────────────────────────

  static bool get enableLogs => kDebugMode;

  static final Logger _prettyLogger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 120,
      colors: false,
      dateTimeFormat: DateTimeFormat.none,
    ),
  );

  // ─────────────────────────────────────────────
  // 🔹 Core Logger
  // ─────────────────────────────────────────────

  static void _log(
    String level,
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!enableLogs) return;

    final time = DateTime.now().toIso8601String();
    final formattedMessage = "[$time] [$level] [$tag] $message";

    if (kDebugMode) {
      // 🔥 Pretty logs for development
      switch (level) {
        case "INFO":
          _prettyLogger.i("[$tag] $message");
          break;
        case "SUCCESS":
          _prettyLogger.t("[$tag] $message");
          break;
        case "WARNING":
          _prettyLogger.w("[$tag] $message");
          break;
        case "ERROR":
          _prettyLogger.e(
            "[$tag] $message",
            error: error,
            stackTrace: stackTrace,
          );
          break;
        case "PERFORMANCE":
          _prettyLogger.d("[$tag] $message");
          break;
        default:
          _prettyLogger.d("[$tag] $message");
      }
    } else {
      // 🚀 Structured logs for production (DevTools / Crashlytics ready)
      developer.log(
        formattedMessage,
        name: "APP_LOGGER",
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  // ─────────────────────────────────────────────
  // 🔹 Levels
  // ─────────────────────────────────────────────

  static void info(String tag, String message) {
    _log("INFO", tag, message);
  }

  static void success(String tag, String message) {
    _log("SUCCESS", tag, message);
  }

  static void warning(String tag, String message) {
    _log("WARNING", tag, message);
  }

  static void error(
    String tag,
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    _log("ERROR", tag, message, error: error, stackTrace: stackTrace);
  }

  static void debug(String tag, String message) {
    _log("DEBUG", tag, message);
  }

  // ─────────────────────────────────────────────
  // 🔥 Performance Helpers
  // ─────────────────────────────────────────────

  static Stopwatch startTimer() {
    return Stopwatch()..start();
  }

  static void endTimer(String tag, String label, Stopwatch stopwatch) {
    stopwatch.stop();
    _log("PERFORMANCE", tag, "$label took ${stopwatch.elapsedMilliseconds} ms");
  }

  // ─────────────────────────────────────────────
  // 🌍 API Logger (جاهزة للـ requests)
  // ─────────────────────────────────────────────

  static void logRequest({
    required String url,
    required String method,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
  }) {
    _log("INFO", "API_REQUEST", "🌍 $method $url");
    if (params != null) {
      _log("DEBUG", "API_REQUEST", "Params: $params");
    }
    if (headers != null) {
      _log("DEBUG", "API_REQUEST", "Headers: $headers");
    }
  }

  static void logResponse({
    required String url,
    required int statusCode,
    required dynamic body,
    required Duration duration,
  }) {
    _log(
      "SUCCESS",
      "API_RESPONSE",
      "✅ [$statusCode] $url (${duration.inMilliseconds} ms)",
    );
    _log("DEBUG", "API_RESPONSE", "Body: $body");
  }

  static void logApiError({
    required String url,
    required Object error,
    StackTrace? stackTrace,
  }) {
    _log("ERROR", "API_ERROR", "❌ $url", error: error, stackTrace: stackTrace);
  }
}

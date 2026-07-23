import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../Global/Utils/logger.dart';

/// Injects the Firebase ID token into every request.
/// Firebase Realtime Database REST API requires: `?auth=<token>`
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Force refresh if token close to expiry. `getIdToken()` has NO
        // built-in timeout — on a flaky network its refresh call can hang
        // forever, and because that happens *before* the Dio request is
        // dispatched, Dio's own timeouts never engage. That leaves every
        // in-flight loader spinning until the app is killed. Bound it so the
        // request always proceeds (with a cached/absent token) within 10s.
        final token =
            await user.getIdToken().timeout(const Duration(seconds: 10));
        if (token != null && token.isNotEmpty) {
          options.queryParameters['auth'] = token;
        }
      }
    } catch (e) {
      // Never block the request due to token failure
      AppLogger.warning('AUTH_INTERCEPTOR', 'Could not attach token: $e');
    }

    handler.next(options);
  }
}

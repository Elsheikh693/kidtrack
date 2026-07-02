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
        // Force refresh if token close to expiry
        final token = await user.getIdToken();
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

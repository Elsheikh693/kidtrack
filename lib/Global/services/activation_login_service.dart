import 'package:cloud_functions/cloud_functions.dart';
import '../../index/index_main.dart';

/// Client wrapper for the public `activate` Cloud Function — the login endpoint
/// of the activation engine. Exchanges an activation code for a Firebase custom
/// token and signs the holder in AS the target account (no password).
///
/// The token mint + code resolution run server-side (Admin SDK) because minting
/// a token for another uid requires elevated privileges; this wrapper just calls
/// it and completes the Firebase sign-in.
class ActivationLoginService {
  /// Pulls the bare activation code out of whatever a scan / deep link yields:
  /// a raw code (`SGJ6-G54Y`), a hosting URL (`https://host/a/SGJ6-G54Y`), or the
  /// custom scheme (`kidtrack://a/SGJ6-G54Y`). Falls back to the trimmed input.
  static String extractCode(String raw) {
    var value = raw.trim();
    final uri = Uri.tryParse(value);
    if (uri != null && uri.hasScheme) {
      if (uri.pathSegments.isNotEmpty && uri.pathSegments.last.isNotEmpty) {
        value = uri.pathSegments.last;
      } else if ((uri.queryParameters['code'] ?? '').isNotEmpty) {
        value = uri.queryParameters['code']!;
      }
    }
    return Uri.decodeComponent(value).trim();
  }

  /// Resolves [code] and signs in. Returns the authenticated uid on success, or
  /// null if the code is invalid / the call failed.
  Future<String?> activate(String code) async {
    final trimmed = code.trim().toUpperCase();
    if (trimmed.isEmpty) return null;

    final callable = FirebaseFunctions.instance.httpsCallable('activate');
    final result = await callable.call<dynamic>({'code': trimmed});

    // The native layer hands back a Map<Object?, Object?>; casting it straight to
    // Map<String, dynamic> throws. Rebuild it key-by-key instead.
    final raw = result.data;
    final data = raw is Map ? Map<String, dynamic>.from(raw) : const <String, dynamic>{};

    final token = data['token']?.toString() ?? '';
    if (token.isEmpty) return null;

    final cred = await FirebaseAuth.instance.signInWithCustomToken(token);
    return cred.user?.uid;
  }
}

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

  /// SharedPreferences key holding the last activation code that successfully
  /// signed in. It is the app's durable "refresh credential": the activation
  /// code never expires server-side, so re-running [activate] with it re-mints a
  /// fresh Firebase session whenever the device's Firebase Auth session is lost.
  static const _codeKey = 'activation_code';

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
    final uid = cred.user?.uid;

    // Persist the code so a dropped Firebase session can self-heal (see
    // [silentReactivate]). Kept OUTSIDE the SessionService so the access gate's
    // session-clear doesn't wipe it; only an explicit logout (StorageService
    // clearAll) removes it.
    if (uid != null) {
      await StorageService().setData(_codeKey, {'code': trimmed});
    }
    return uid;
  }

  /// The activation code last used to sign in, if any.
  String? get storedCode =>
      StorageService().getData(_codeKey)?['code'] as String?;

  /// Re-mints a Firebase session from the stored activation code when the local
  /// login state survives but the Firebase Auth session was lost (keychain wipe,
  /// token-refresh failure, cleared app data). Returns the authenticated uid on
  /// success, or null if there is no stored code / the re-activation failed.
  ///
  /// Never throws: a transient network failure here must fall back to the normal
  /// gate decision, not crash the launch. It deliberately does NOT clear the
  /// stored code on failure — the failure may be transient, and a genuinely
  /// revoked code just lands the user on the login screen as before.
  Future<String?> silentReactivate() async {
    final code = storedCode;
    if (code == null || code.trim().isEmpty) return null;
    try {
      return await activate(code);
    } catch (_) {
      return null;
    }
  }
}

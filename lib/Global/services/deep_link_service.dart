import 'package:app_links/app_links.dart';

import '../../index/index_main.dart';

/// Handles activation deep links — the QR "scan → open app → auto-login" path.
///
/// A scanned QR points at the hosting page `https://<host>/a/<code>`; when the
/// app is installed the OS hands us either that verified App/Universal Link or
/// the custom-scheme fallback `kidtrack://a/<code>`. Either way we pull the code
/// out and run the SAME activation login as the manual sheet (activate → shared
/// bootstrap). No password, no extra taps.
class DeepLinkService extends GetxService {
  final AppLinks _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;
  bool _busy = false;

  @override
  void onReady() {
    super.onReady();
    _init();
  }

  Future<void> _init() async {
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) await _handle(initial);
    } catch (_) {
      // No launch link — normal cold start.
    }
    _sub = _appLinks.uriLinkStream.listen(_handle, onError: (_) {});
  }

  Future<void> _handle(Uri uri) async {
    if (_busy) return;

    // Only our activation links: .../a/<code> or kidtrack://a/<code>.
    final isActivation =
        uri.pathSegments.contains('a') || uri.host == 'a';
    if (!isActivation) return;

    final code = ActivationLoginService.extractCode(uri.toString());
    if (code.replaceAll('-', '').trim().length < 8) return;

    // Never hijack an already-signed-in session; they can log out first.
    if (SessionService().isLoggedIn) return;

    _busy = true;
    Loader.show();
    try {
      final uid = await Get.find<ActivationLoginService>().activate(code);
      if (uid == null) {
        Loader.showError('activation_invalid_code'.tr);
        return;
      }
      // Navigates + surfaces its own success/error, same as the login sheet.
      await Get.find<AuthBootstrapService>().bootstrap(uid);
    } catch (_) {
      Loader.showError('activation_invalid_code'.tr);
    } finally {
      _busy = false;
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }
}

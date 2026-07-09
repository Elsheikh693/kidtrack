import '../../../../index/index_main.dart';
import 'widgets/activation_scanner_sheet.dart';

/// Drives the pre-login activation screen: the holder types the activation code
/// (delivered on WhatsApp or printed under the child's QR), we exchange it for a
/// Firebase custom token via the `activate` Cloud Function, sign in, and hand
/// off to the shared post-auth bootstrap — the same landing/guards as password
/// login. No username, no password.
class ActivationCodeController extends GetxController {
  final code = ''.obs;
  final isLoading = false.obs;

  final codeController = TextEditingController();
  final codeFocus = FocusNode();

  late final ActivationLoginService _activation;
  late final AuthBootstrapService _bootstrap;

  @override
  void onInit() {
    super.onInit();
    _activation = Get.find<ActivationLoginService>();
    _bootstrap = Get.find<AuthBootstrapService>();
  }

  // A code is 8 chars grouped as XXXX-XXXX; accept with or without the hyphen.
  bool get canSubmit =>
      code.value.replaceAll('-', '').trim().length >= 8;

  void onCodeChanged(String value) => code.value = value;

  /// Open the camera scanner; on a successful scan fill the field and submit.
  Future<void> scanCode() async {
    final scanned = await openActivationScanner();
    if (scanned == null || scanned.trim().isEmpty) return;
    // A scanned QR now carries the deep-link URL, not the bare code.
    final value = ActivationLoginService.extractCode(scanned);
    codeController.text = value;
    code.value = value;
    await submit();
  }

  Future<void> submit() async {
    if (isLoading.value || !canSubmit) return;
    isLoading.value = true;
    Loader.show();

    try {
      final uid = await _activation.activate(code.value);
      if (uid == null) {
        isLoading.value = false;
        Loader.showError('activation_invalid_code'.tr);
        return;
      }
      // On success the bootstrap navigates; on failure it surfaces its own error
      // and signs out.
      await _bootstrap.bootstrap(uid);
      isLoading.value = false;
    } catch (_) {
      isLoading.value = false;
      Loader.showError('activation_invalid_code'.tr);
    }
  }

  @override
  void onClose() {
    codeController.dispose();
    codeFocus.dispose();
    super.onClose();
  }
}

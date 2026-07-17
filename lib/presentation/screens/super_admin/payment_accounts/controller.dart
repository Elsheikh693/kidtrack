import '../../../../index/index_main.dart';

/// SuperAdmin editor for the platform's subscription-collection accounts
/// (InstaPay number / wallet number / InstaPay link). Single global record.
class PlatformPaymentAccountsController extends GetxController {
  late final PlatformPaymentService _service;

  final instapayCtrl = TextEditingController();
  final walletCtrl = TextEditingController();
  final linkCtrl = TextEditingController();

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<PlatformPaymentService>();
    load();
  }

  @override
  void onClose() {
    instapayCtrl.dispose();
    walletCtrl.dispose();
    linkCtrl.dispose();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    final info = await _service.get();
    instapayCtrl.text = info.instapayNumber;
    walletCtrl.text = info.walletNumber;
    linkCtrl.text = info.instapayLink;
    isLoading.value = false;
  }

  Future<void> save() async {
    isSaving.value = true;
    Loader.show();

    final info = PlatformPaymentInfoModel(
      instapayNumber: instapayCtrl.text.trim(),
      walletNumber: walletCtrl.text.trim(),
      instapayLink: linkCtrl.text.trim(),
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    try {
      await _service.save(info);
      isSaving.value = false;
      Loader.showSuccess('pay_accounts_saved'.tr);
      Get.back();
    } catch (_) {
      isSaving.value = false;
      Loader.showError('pay_accounts_save_error'.tr);
    }
  }
}

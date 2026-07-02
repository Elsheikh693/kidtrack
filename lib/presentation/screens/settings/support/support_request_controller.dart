import '../../../../index/index_main.dart';

class SupportRequestController extends GetxController {
  late final SupportRequestParentService _service;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final subjectCtrl = TextEditingController();
  final messageCtrl = TextEditingController();

  final formKey = GlobalKey<FormState>();
  final RxBool isSubmitting = false.obs;

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    emailCtrl.dispose();
    subjectCtrl.dispose();
    messageCtrl.dispose();
    super.onClose();
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isSubmitting.value = true;
    Loader.show();

    final model = SupportRequestModel(
      key: const Uuid().v4(),
      name: nameCtrl.text.trim(),
      phone: phoneCtrl.text.trim(),
      email: emailCtrl.text.trim().isEmpty ? null : emailCtrl.text.trim(),
      subject: subjectCtrl.text.trim(),
      message: messageCtrl.text.trim(),
    );

    await _service.add(
      item: model,
      callBack: (status) {
        isSubmitting.value = false;
        if (status == ResponseStatus.success) {
          Loader.showSuccess('support_success'.tr);
          Get.back();
        } else {
          Loader.showError('support_error'.tr);
        }
      },
    );
  }

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<SupportRequestParentService>();
  }
}

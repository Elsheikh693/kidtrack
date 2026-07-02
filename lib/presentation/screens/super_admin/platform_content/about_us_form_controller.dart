import 'dart:io';
import '../../../../index/index_main.dart';

class AboutUsFormController extends GetxController {
  late final AboutUsParentService _service;
  late final FirebaseCredentialsService _credentials;

  static const String _fixedKey = 'main';

  final titleCtrl = TextEditingController();
  final descriptionCtrl = TextEditingController();
  final missionCtrl = TextEditingController();
  final visionCtrl = TextEditingController();

  final RxnString imageUrl = RxnString();
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool isUploading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<AboutUsParentService>();
    _credentials = Get.find<FirebaseCredentialsService>();
    load();
  }

  @override
  void onClose() {
    titleCtrl.dispose();
    descriptionCtrl.dispose();
    missionCtrl.dispose();
    visionCtrl.dispose();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        final items = list.whereType<AboutUsModel>().toList();
        if (items.isEmpty) return;
        final m = items.first;
        titleCtrl.text = m.title;
        descriptionCtrl.text = m.description;
        missionCtrl.text = m.mission ?? '';
        visionCtrl.text = m.vision ?? '';
        imageUrl.value = m.imageUrl;
      },
    );
    isLoading.value = false;
  }

  Future<void> pickImage() async {
    await PickedImage().pickImage(callBack: (file) async {
      if (file == null) return;
      isUploading.value = true;
      final url = await _upload(file);
      isUploading.value = false;
      if (url != null) imageUrl.value = url;
    });
  }

  void removeImage() => imageUrl.value = null;

  Future<String?> _upload(File file) async {
    final key = 'aboutUs/main_${DateTime.now().millisecondsSinceEpoch}';
    final result = await _credentials.uploadImage(key, file);
    return result.fold((_) {
      Loader.showError('pcontent_upload_error'.tr);
      return null;
    }, (url) => url);
  }

  Future<void> save() async {
    if (titleCtrl.text.trim().isEmpty) {
      Loader.showError('pcontent_title_required'.tr);
      return;
    }
    isSaving.value = true;
    Loader.show();

    final model = AboutUsModel(
      key: _fixedKey,
      title: titleCtrl.text.trim(),
      description: descriptionCtrl.text.trim(),
      mission: _orNull(missionCtrl.text),
      vision: _orNull(visionCtrl.text),
      imageUrl: imageUrl.value,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );

    await _service.save(
      item: model,
      callBack: (status) {
        isSaving.value = false;
        if (status == ResponseStatus.success) {
          Loader.showSuccess('pcontent_saved'.tr);
          Get.back();
        } else {
          Loader.showError('pcontent_save_error'.tr);
        }
      },
    );
  }

  String? _orNull(String value) {
    final v = value.trim();
    return v.isEmpty ? null : v;
  }
}

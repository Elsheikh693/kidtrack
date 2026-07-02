import '../../../../index/index_main.dart';

class ContactInfoFormController extends GetxController {
  late final ContactInfoParentService _service;

  static const String _fixedKey = 'main';

  final phoneCtrl = TextEditingController();
  final whatsappCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final latCtrl = TextEditingController();
  final lngCtrl = TextEditingController();
  final workingHoursCtrl = TextEditingController();
  final facebookCtrl = TextEditingController();
  final instagramCtrl = TextEditingController();
  final tiktokCtrl = TextEditingController();
  final youtubeCtrl = TextEditingController();
  final websiteCtrl = TextEditingController();

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<ContactInfoParentService>();
    load();
  }

  @override
  void onClose() {
    phoneCtrl.dispose();
    whatsappCtrl.dispose();
    emailCtrl.dispose();
    addressCtrl.dispose();
    latCtrl.dispose();
    lngCtrl.dispose();
    workingHoursCtrl.dispose();
    facebookCtrl.dispose();
    instagramCtrl.dispose();
    tiktokCtrl.dispose();
    youtubeCtrl.dispose();
    websiteCtrl.dispose();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        final items = list.whereType<ContactInfoModel>().toList();
        if (items.isEmpty) return;
        final m = items.first;
        phoneCtrl.text = m.phone ?? '';
        whatsappCtrl.text = m.whatsapp ?? '';
        emailCtrl.text = m.email ?? '';
        addressCtrl.text = m.address ?? '';
        latCtrl.text = m.lat?.toString() ?? '';
        lngCtrl.text = m.lng?.toString() ?? '';
        workingHoursCtrl.text = m.workingHours ?? '';
        facebookCtrl.text = m.facebook ?? '';
        instagramCtrl.text = m.instagram ?? '';
        tiktokCtrl.text = m.tiktok ?? '';
        youtubeCtrl.text = m.youtube ?? '';
        websiteCtrl.text = m.website ?? '';
      },
    );
    isLoading.value = false;
  }

  Future<void> save() async {
    isSaving.value = true;
    Loader.show();

    final model = ContactInfoModel(
      key: _fixedKey,
      phone: _orNull(phoneCtrl.text),
      whatsapp: _orNull(whatsappCtrl.text),
      email: _orNull(emailCtrl.text),
      address: _orNull(addressCtrl.text),
      lat: double.tryParse(latCtrl.text.trim()),
      lng: double.tryParse(lngCtrl.text.trim()),
      workingHours: _orNull(workingHoursCtrl.text),
      facebook: _orNull(facebookCtrl.text),
      instagram: _orNull(instagramCtrl.text),
      tiktok: _orNull(tiktokCtrl.text),
      youtube: _orNull(youtubeCtrl.text),
      website: _orNull(websiteCtrl.text),
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

import '../../../../index/index_main.dart';

class ContactUsController extends GetxController {
  late final ContactInfoParentService _service;

  final Rxn<ContactInfoModel> info = Rxn<ContactInfoModel>();
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<ContactInfoParentService>();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    await _service.getAll(
      callBack: (list) {
        final items = list.whereType<ContactInfoModel>().toList();
        info.value = items.isNotEmpty ? items.first : null;
      },
    );
    isLoading.value = false;
  }

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Loader.showError('contact_launch_error'.tr);
    }
  }

  void call(String phone) => _launch(Uri.parse('tel:$phone'));

  void whatsapp(String number) {
    final digits = number.replaceAll(RegExp(r'[^0-9+]'), '');
    _launch(Uri.parse('https://wa.me/$digits'));
  }

  void email(String address) => _launch(Uri.parse('mailto:$address'));

  void openMap(double lat, double lng) => _launch(
        Uri.parse(
          'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
        ),
      );

  void openLink(String url) {
    var u = url.trim();
    if (!u.startsWith('http')) u = 'https://$u';
    _launch(Uri.parse(u));
  }
}

import '../../../../index/index_main.dart';

/// Marketing/landing controller for the "Join Us" page.
/// Contact number is fixed in code for the call / WhatsApp CTAs.
class JoinUsController extends GetxController {
  /// Local Egyptian contact number used for both call and WhatsApp.
  static const String contactPhone = '01551061194';

  void call() {
    _launch(Uri.parse('tel:$contactPhone'));
  }

  void whatsapp() {
    final text = Uri.encodeComponent('join_us_wa_message'.tr);
    _launch(Uri.parse('https://wa.me/${_whatsappDigits(contactPhone)}?text=$text'));
  }

  /// wa.me needs an international number: drop the leading 0 and prefix
  /// Egypt's country code (20). e.g. 01551061194 -> 201551061194
  String _whatsappDigits(String raw) {
    var d = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (d.startsWith('0')) d = '20${d.substring(1)}';
    return d;
  }

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Loader.showError('contact_launch_error'.tr);
    }
  }
}

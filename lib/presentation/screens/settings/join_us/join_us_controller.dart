import '../../../../index/index_main.dart';

/// Marketing/landing controller for the "Join Us" page.
/// Contact number is fixed in code for the call / WhatsApp CTAs.
class JoinUsController extends GetxController {
  /// Local Egyptian contact number used for both call and WhatsApp.
  static const String contactPhone = '01551061194';

  void call() {
    _launch(Uri.parse('tel:$contactPhone'));
  }

  void whatsapp() =>
      MakeCall.openWhatsApp(contactPhone, message: 'join_us_wa_message'.tr);

  Future<void> _launch(Uri uri) async {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Loader.showError('contact_launch_error'.tr);
    }
  }
}

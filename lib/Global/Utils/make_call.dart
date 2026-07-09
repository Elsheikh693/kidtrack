import '../../index/index_main.dart';

class MakeCall {
  /// **📞 Make a Direct Call**
  static void makePhoneCall(String phoneNumber) async {
    String phone = convertToEnglishNumbers(phoneNumber);
    final Uri url = Uri.parse('tel:$phone');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      
    }
  }

  /// **🟢 Open a WhatsApp chat (WhatsApp or WhatsApp Business).**
  /// Tries the `whatsapp://` scheme first so the installed WhatsApp app opens
  /// directly, then falls back to the `https://wa.me` link (which lets the OS
  /// pick WhatsApp / WhatsApp Business, or the browser as a last resort).
  static Future<void> openWhatsApp(String phone, {String? message}) async {
    final number = formatForWhatsApp(phone);
    if (number.isEmpty) {
      Loader.showError('contact_launch_error'.tr);
      return;
    }
    final hasText = message != null && message.trim().isNotEmpty;
    final encoded = hasText ? Uri.encodeComponent(message) : '';

    // 1) Native scheme — opens the installed WhatsApp / WhatsApp Business app.
    final appUri = Uri.parse(
      'whatsapp://send?phone=$number${hasText ? '&text=$encoded' : ''}',
    );
    try {
      if (await canLaunchUrl(appUri)) {
        if (await launchUrl(appUri, mode: LaunchMode.externalApplication)) {
          return;
        }
      }
    } catch (_) {
      // fall through to the https link
    }

    // 2) Universal link — no canLaunchUrl gate (https is always launchable).
    final webUri = Uri.parse(
      'https://wa.me/$number${hasText ? '?text=$encoded' : ''}',
    );
    try {
      if (await launchUrl(webUri, mode: LaunchMode.externalApplication)) {
        return;
      }
    } catch (_) {
      // fall through to the error toast
    }

    Loader.showError('contact_launch_error'.tr);
  }

  /// **🟢 Normalize a phone number to WhatsApp's required international format.**
  /// WhatsApp (`wa.me`) only accepts a full international number with no `+`,
  /// spaces or leading `0`. Egyptian local numbers like `01551061194` must be
  /// sent as `201551061194` (country code `20` instead of the leading `0`).
  static String formatForWhatsApp(String input, {String countryCode = '20'}) {
    // Convert Arabic-Indic digits, then keep digits only (drop +, spaces, etc.)
    var n = convertToEnglishNumbers(input).replaceAll(RegExp(r'[^0-9]'), '');
    if (n.isEmpty) return n;
    // International dialing prefix (00) → strip it.
    if (n.startsWith('00')) n = n.substring(2);
    // Already carries the country code.
    if (n.startsWith(countryCode)) return n;
    // Local format with a leading 0 → swap the 0 for the country code.
    if (n.startsWith('0')) return '$countryCode${n.substring(1)}';
    // Bare local number (e.g. 1551061194) → prepend the country code.
    return '$countryCode$n';
  }

  static String convertToEnglishNumbers(String input) {
    final arabicToEnglish = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };

    return input.split('').map((char) => arabicToEnglish[char] ?? char).join();
  }
}

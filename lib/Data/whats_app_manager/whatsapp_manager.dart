import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WhatsAppManager {
  // 🔹 Replace with your actual UltraMsg instance ID and API token
  static const String _instanceId = "instance86174";
  static const String _token = "zi9hxnjprdgdayfg";

  static const String _baseUrl = "https://api.ultramsg.com";


  static String normalizeEgyptPhone(String phone) {
    // شيل أي مسافات
    phone = phone.trim();

    // شيل +
    if (phone.startsWith("+")) {
      phone = phone.substring(1);
    }

    // شيل 00 لو موجودة
    if (phone.startsWith("00")) {
      phone = phone.substring(2);
    }

    // لو الرقم مصري وبيبدأ بـ 0
    if (phone.startsWith("0")) {
      phone = "20${phone.substring(1)}";
    }

    // لو مش بيبدأ بـ 20 خالص (احتياطي)
    if (!phone.startsWith("20")) {
      phone = "20$phone";
    }

    return phone;
  }


  /// 🔹 Send a simple WhatsApp text message
  static Future<bool> sendMessage({
    required String to,
    required String body,
  }) async {
    final url = Uri.parse("$_baseUrl/$_instanceId/messages/chat");

    final headers = {'Content-Type': 'application/x-www-form-urlencoded'};


    final normalizedPhone = normalizeEgyptPhone(to);

    final bodyFields = {
      'token': _token,
      'to': normalizedPhone,
      'body': body,
    };



    try {
      final response = await http.post(url, headers: headers, body: bodyFields);

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint(
          "❌ WhatsApp API Error: ${response.statusCode} → ${response.body}",
        );
        return false;
      }
    } catch (e) {

      return false;
    }
  }

  /// 🔹 Send a message to multiple contacts sequentially
  static Future<void> sendToMultiple({
    required List<String> numbers,
    required String message,
  }) async {
    for (final number in numbers) {
      final formattedNumber = formatNumber(number);
      await sendMessage(to: formattedNumber, body: message);
      await Future.delayed(
        const Duration(milliseconds: 400),
      ); // slight delay to avoid rate limit
    }
  }

  /// 🔹 Format numbers automatically to WhatsApp standard
  static String formatNumber(String number) {
    // Example: Ensure it starts with country code like "20" for Egypt
    if (!number.startsWith("20") && number.startsWith("0")) {
      return number.replaceFirst("0", "20");
    }
    return number;
  }

  /// 🔹 Send message with template
  static Future<bool> sendTemplate({
    required String to,
    required String title,
    required String message,
  }) async {
    final formatted = "*$title*\n\n$message";
    return await sendMessage(to: to, body: formatted);
  }
}

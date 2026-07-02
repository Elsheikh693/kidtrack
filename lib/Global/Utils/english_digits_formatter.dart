import 'package:flutter/services.dart';

/// Converts Arabic-Indic (٠-٩) and Persian/Urdu (۰-۹) digits to Western
/// digits (0-9) live as the user types.
///
/// The mapping is 1:1 and length-preserving, so the cursor/selection stays
/// in place. Non-digit characters (Arabic letters, symbols, spaces) are left
/// untouched — making it safe to attach to *any* text field, not just numeric
/// ones.
class EnglishDigitsFormatter extends TextInputFormatter {
  const EnglishDigitsFormatter();

  static const Map<String, String> _digitMap = {
    // Arabic-Indic
    '٠': '0', '١': '1', '٢': '2', '٣': '3', '٤': '4',
    '٥': '5', '٦': '6', '٧': '7', '٨': '8', '٩': '9',
    // Persian / Urdu
    '۰': '0', '۱': '1', '۲': '2', '۳': '3', '۴': '4',
    '۵': '5', '۶': '6', '۷': '7', '۸': '8', '۹': '9',
  };

  /// Converts every Arabic/Persian digit in [input] to its Western counterpart.
  static String convert(String input) {
    if (input.isEmpty) return input;
    final buffer = StringBuffer();
    for (final ch in input.split('')) {
      buffer.write(_digitMap[ch] ?? ch);
    }
    return buffer.toString();
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final converted = convert(newValue.text);
    if (converted == newValue.text) return newValue;
    // Length is preserved by the 1:1 mapping, so the incoming selection is
    // still valid against the converted text.
    return TextEditingValue(
      text: converted,
      selection: newValue.selection,
      composing: TextRange.empty,
    );
  }
}

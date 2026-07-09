import 'package:flutter/services.dart';

/// Live-formats the activation code as the user types: upper-cases, keeps only
/// A–Z/0–9, caps at 8 chars, and inserts the hyphen automatically →
/// `abcd1234` becomes `ABCD-1234`. The user never types the dash.
class ActivationCodeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var raw = newValue.text.toUpperCase().replaceAll(RegExp('[^A-Z0-9]'), '');
    if (raw.length > 8) raw = raw.substring(0, 8);

    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i == 4) buffer.write('-');
      buffer.write(raw[i]);
    }
    final text = buffer.toString();

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

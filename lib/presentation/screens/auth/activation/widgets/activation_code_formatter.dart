import 'package:flutter/services.dart';

/// Live-formats the activation code as the user types: upper-cases, keeps only
/// A–Z/0–9, caps at 8 chars, and inserts the hyphen automatically →
/// `abcd1234` becomes `ABCD-1234`. The user never types the dash.
///
/// It also survives a paste of the WHOLE WhatsApp invite: the code is delivered
/// embedded in a long message, and the recipient can rarely copy just the code,
/// so they copy the entire text. When a long blob comes in we lift the
/// `XXXX-XXXX` code out of it instead of truncating to the first 8 letters
/// (which would grab `KIDTRACK`).
class ActivationCodeFormatter extends TextInputFormatter {
  /// The code as it appears inside a message: two 4-char groups of the
  /// unambiguous code alphabet (no I/L/O/0/1), hyphen-separated.
  static final RegExp _embedded =
      RegExp(r'[A-HJKMNP-Z2-9]{4}-[A-HJKMNP-Z2-9]{4}');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = _format(newValue.text);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  /// Cleans arbitrary text down to a hyphen-grouped code. Used by the formatter
  /// and by the "paste code" affordance, which hands it the full clipboard blob.
  static String extractFromText(String input) => _format(input);

  static String _format(String input) {
    final upper = input.toUpperCase();

    // A pasted blob (whole message) → pull the embedded code. Short/incremental
    // input keeps the plain char-by-char path so normal typing is untouched.
    String raw;
    final match = upper.length > 9 ? _embedded.firstMatch(upper) : null;
    if (match != null) {
      raw = match.group(0)!.replaceAll('-', '');
    } else {
      raw = upper.replaceAll(RegExp('[^A-Z0-9]'), '');
      if (raw.length > 8) raw = raw.substring(0, 8);
    }

    final buffer = StringBuffer();
    for (var i = 0; i < raw.length; i++) {
      if (i == 4) buffer.write('-');
      buffer.write(raw[i]);
    }
    return buffer.toString();
  }
}

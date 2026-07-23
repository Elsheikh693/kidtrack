/// Country + phone helpers for the international guardian-phone field.
///
/// The phone IS the platform identity key (login email is `${phone}@gmail.com`
/// and `resolveByPhone` de-dupes on it), so the stored form must stay stable and
/// backward compatible:
///   • Egypt  → local 11-digit form WITH the leading zero, NO dial code
///              (e.g. "01012345678") — exactly how every existing record is
///              stored, so returning Egyptian identities keep resolving.
///   • Others → dial code + national number WITHOUT the leading zero
///              (e.g. Saudi "966501234567") — still inside the backend's
///              6–15 digit rule (`functions/auth/resolveAccount.js`), and there
///              are no legacy records for these countries to collide with.
class PhoneCountry {
  final String iso; // ISO-3166 alpha-2, e.g. 'EG'
  final String dialCode; // international dial code without '+', e.g. '20'
  final String flag; // emoji flag
  final String nameKey; // localization key, e.g. 'country_eg'
  final int localMin; // national significant number length bounds
  final int localMax;

  const PhoneCountry({
    required this.iso,
    required this.dialCode,
    required this.flag,
    required this.nameKey,
    required this.localMin,
    required this.localMax,
  });
}

class PhoneUtils {
  const PhoneUtils._();

  static const PhoneCountry egypt = PhoneCountry(
    iso: 'EG',
    dialCode: '20',
    flag: '🇪🇬',
    nameKey: 'country_eg',
    localMin: 10,
    localMax: 10,
  );

  /// Curated list (Egypt first = default). Extend as needed.
  static const List<PhoneCountry> countries = [
    egypt,
    PhoneCountry(iso: 'SA', dialCode: '966', flag: '🇸🇦', nameKey: 'country_sa', localMin: 9, localMax: 9),
    PhoneCountry(iso: 'AE', dialCode: '971', flag: '🇦🇪', nameKey: 'country_ae', localMin: 9, localMax: 9),
    PhoneCountry(iso: 'KW', dialCode: '965', flag: '🇰🇼', nameKey: 'country_kw', localMin: 8, localMax: 8),
    PhoneCountry(iso: 'QA', dialCode: '974', flag: '🇶🇦', nameKey: 'country_qa', localMin: 8, localMax: 8),
    PhoneCountry(iso: 'BH', dialCode: '973', flag: '🇧🇭', nameKey: 'country_bh', localMin: 8, localMax: 8),
    PhoneCountry(iso: 'OM', dialCode: '968', flag: '🇴🇲', nameKey: 'country_om', localMin: 8, localMax: 8),
    PhoneCountry(iso: 'JO', dialCode: '962', flag: '🇯🇴', nameKey: 'country_jo', localMin: 9, localMax: 9),
  ];

  /// Strip everything that is not a Western digit.
  static String digitsOnly(String raw) => raw.replaceAll(RegExp(r'[^0-9]'), '');

  /// National significant number: digits with any leading zeros removed.
  static String _national(String raw) =>
      digitsOnly(raw).replaceFirst(RegExp(r'^0+'), '');

  /// Canonical stored phone for [country] + the user-typed [raw]. Empty when the
  /// input has no digits.
  static String normalize(PhoneCountry country, String raw) {
    final national = _national(raw);
    if (national.isEmpty) return '';
    if (country.iso == 'EG') return '0$national'; // e.g. 01012345678
    return '${country.dialCode}$national'; // e.g. 966501234567
  }

  /// Best-effort reverse of [normalize] for prefilling an edit form: given a
  /// stored phone, return the country to preselect and the local digits to show.
  ///   • "01012345678"   → (Egypt, "01012345678")
  ///   • "966501234567"  → (Saudi, "501234567")
  /// Falls back to Egypt with the digits unchanged when nothing matches.
  static ({PhoneCountry country, String local}) detect(String? stored) {
    final digits = digitsOnly(stored ?? '');
    if (digits.isEmpty) return (country: egypt, local: '');
    if (digits.startsWith('0')) return (country: egypt, local: digits);
    // Longest dial code first so e.g. a 3-digit code wins over a 2-digit one.
    final sorted = [...countries.where((c) => c.iso != 'EG')]
      ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));
    for (final c in sorted) {
      if (digits.startsWith(c.dialCode)) {
        return (country: c, local: digits.substring(c.dialCode.length));
      }
    }
    return (country: egypt, local: digits);
  }

  /// Whether [raw] is a valid number for the selected [country].
  static bool isValid(PhoneCountry country, String raw) {
    final national = _national(raw);
    if (country.iso == 'EG') {
      // 10-digit national starting 10/11/12/15 → 01[0125]xxxxxxxx once stored.
      return RegExp(r'^1[0125]\d{8}$').hasMatch(national);
    }
    if (national.length < country.localMin || national.length > country.localMax) {
      return false;
    }
    final full = '${country.dialCode}$national';
    return full.length >= 6 && full.length <= 15; // backend PHONE_RE bound
  }
}

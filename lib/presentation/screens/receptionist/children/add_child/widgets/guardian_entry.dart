import '../../../../../../index/index_main.dart';

/// Mutable state for one guardian input on the add-child form. The form keeps a
/// list of these (father + mother by default, plus any extra added guardians).
class GuardianEntry {
  String relationship; // 'father' | 'mother' | 'other'
  // Father/mother slots have a fixed relationship (shown as a header); extra
  // guardians expose a relationship toggle instead.
  final bool fixedRelationship;
  PhoneCountry country;
  final TextEditingController phoneCtrl = TextEditingController();
  final TextEditingController nameCtrl = TextEditingController();
  ParentModel? selected; // set when an existing guardian is picked

  GuardianEntry({
    required this.relationship,
    this.fixedRelationship = false,
    PhoneCountry? country,
  }) : country = country ?? PhoneUtils.egypt;

  /// Whether the receptionist typed/picked anything for this guardian.
  bool get hasInput => selected != null || phoneCtrl.text.trim().isNotEmpty;

  void dispose() {
    phoneCtrl.dispose();
    nameCtrl.dispose();
  }
}

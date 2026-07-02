import '../../../../index/index_main.dart';

enum HealthEventType { temperature, injury, medication, contact, general }

class HealthHistoryEvent {
  final String title;
  final String description;
  final String dateTime;
  final HealthEventType type;

  const HealthHistoryEvent({
    required this.title,
    required this.description,
    required this.dateTime,
    required this.type,
  });

  Color get color {
    switch (type) {
      case HealthEventType.temperature: return AppColors.errorForeground;
      case HealthEventType.injury:      return AppColors.yellowForeground;
      case HealthEventType.medication:  return AppColors.blueForeground;
      case HealthEventType.contact:     return AppColors.successForeground;
      case HealthEventType.general:     return AppColors.grayMedium;
    }
  }

  IconData get icon {
    switch (type) {
      case HealthEventType.temperature: return Icons.thermostat_rounded;
      case HealthEventType.injury:      return Icons.healing_rounded;
      case HealthEventType.medication:  return Icons.medication_outlined;
      case HealthEventType.contact:     return Icons.phone_in_talk_rounded;
      case HealthEventType.general:     return Icons.info_outline_rounded;
    }
  }
}

class DoctorNote {
  final String note;
  final String date;
  final String doctorName;

  const DoctorNote({
    required this.note,
    required this.date,
    required this.doctorName,
  });
}

class ParentMedicalController extends GetxController {
  final SessionService _session = SessionService();
  String get childName => _session.currentUser?.displayName ?? 'parent_default_name'.tr;
  String get childStatus => 'inside';
  String? get childImage => null;

  final String bloodType = 'A+';

  final List<String> allergies = const [
    'حساسية من البيض',
    'حساسية من المكسرات',
  ];
  final List<String> conditions = const [];
  final List<String> specialNotes = const [];
  final List<String> medications = const [
    'فيتامين د — قطرة يومياً',
    'أوميجا 3 — كبسولة يومياً',
  ];
  final String? emergencyNotes = null;

  final List<HealthHistoryEvent> healthHistory = const [
    HealthHistoryEvent(
      title: 'حرارة مرتفعة (38.5°C)',
      description: 'رُصدت حرارة مرتفعة أثناء وقت القيلولة، تم إبلاغ ولي الأمر فوراً',
      dateTime: '10 يونيو 2026 — 11:30 ص',
      type: HealthEventType.temperature,
    ),
    HealthHistoryEvent(
      title: 'إصابة بسيطة أثناء اللعب',
      description: 'خدش خفيف في الركبة، تم تنظيفه ووضع ضماد بشكل مناسب',
      dateTime: '5 مايو 2026 — 10:15 ص',
      type: HealthEventType.injury,
    ),
    HealthHistoryEvent(
      title: 'إعطاء دواء',
      description: 'أُعطيت جرعة فيتامين د اليومية حسب تعليمات ولي الأمر',
      dateTime: '1 مايو 2026 — 9:00 ص',
      type: HealthEventType.medication,
    ),
    HealthHistoryEvent(
      title: 'تم التواصل مع ولي الأمر',
      description: 'تم الاتصال بالأم بسبب ظهور احمرار خفيف في الجلد',
      dateTime: '15 أبريل 2026 — 2:45 م',
      type: HealthEventType.contact,
    ),
  ];

  final DoctorNote? latestDoctorNote = const DoctorNote(
    note: 'الطفل بصحة جيدة. يُنصح بالاستمرار في شرب الماء بانتظام وتناول الإفطار الصحي.',
    date: '1 يونيو 2026',
    doctorName: 'د. سارة أحمد',
  );

  bool get hasAlerts =>
      allergies.isNotEmpty || conditions.isNotEmpty || specialNotes.isNotEmpty;
}

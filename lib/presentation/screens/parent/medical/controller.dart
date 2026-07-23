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

  final List<String> allergies = [
    'parentlink25_allergy_eggs'.tr,
    'parentlink25_allergy_nuts'.tr,
  ];
  final List<String> conditions = const [];
  final List<String> specialNotes = const [];
  final List<String> medications = [
    'parentlink25_med_vitd'.tr,
    'parentlink25_med_omega3'.tr,
  ];
  final String? emergencyNotes = null;

  final List<HealthHistoryEvent> healthHistory = [
    HealthHistoryEvent(
      title: 'parentlink25_health_temp_title'.tr,
      description: 'parentlink25_health_temp_desc'.tr,
      dateTime: '10 يونيو 2026 — 11:30 ص',
      type: HealthEventType.temperature,
    ),
    HealthHistoryEvent(
      title: 'parentlink25_health_injury_title'.tr,
      description: 'parentlink25_health_injury_desc'.tr,
      dateTime: '5 مايو 2026 — 10:15 ص',
      type: HealthEventType.injury,
    ),
    HealthHistoryEvent(
      title: 'parentlink25_health_med_title'.tr,
      description: 'parentlink25_health_med_desc'.tr,
      dateTime: '1 مايو 2026 — 9:00 ص',
      type: HealthEventType.medication,
    ),
    HealthHistoryEvent(
      title: 'parentlink25_health_contact_title'.tr,
      description: 'parentlink25_health_contact_desc'.tr,
      dateTime: '15 أبريل 2026 — 2:45 م',
      type: HealthEventType.contact,
    ),
  ];

  final DoctorNote? latestDoctorNote = DoctorNote(
    note: 'parentlink25_doctor_note_text'.tr,
    date: '1 يونيو 2026',
    doctorName: 'parentlink25_doctor_name_sample'.tr,
  );

  bool get hasAlerts =>
      allergies.isNotEmpty || conditions.isNotEmpty || specialNotes.isNotEmpty;
}

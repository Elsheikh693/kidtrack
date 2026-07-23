import '../../../../index/index_main.dart';
import '../../shared/logout_helper.dart';

class StaffAccountController extends GetxController {
  final _session = SessionService();

  String get staffName => _session.currentUser?.displayName ?? '';
  String get staffPhone => _session.currentUser?.phone ?? '';
  String get staffRole => _session.userType?.name ?? '';
  bool get isTeacher => _session.isTeacher;
  bool get isOwner => _session.isOwner;

  String get roleLabel {
    switch (_session.userType) {
      case UserType.teacher:      return 'shared30_role_teacher'.tr;
      case UserType.nanny:        return 'shared30_role_nanny'.tr;
      case UserType.receptionist: return 'shared30_role_receptionist'.tr;
      case UserType.busChaperone: return 'shared30_role_bus_chaperone'.tr;
      default:                    return staffRole;
    }
  }

  IconData get roleIcon {
    switch (_session.userType) {
      case UserType.teacher:      return Icons.school_rounded;
      case UserType.nanny:        return Icons.child_care_rounded;
      case UserType.receptionist: return Icons.support_agent_rounded;
      case UserType.busChaperone: return Icons.directions_bus_rounded;
      default:                    return Icons.badge_rounded;
    }
  }

  void logout() => showLogoutConfirm();
}

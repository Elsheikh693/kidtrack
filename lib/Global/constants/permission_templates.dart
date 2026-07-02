import '../../Data/models/staff/staff_template.dart';
import 'permission_keys.dart';

abstract class PermissionTemplates {
  static Map<String, bool> forTemplate(StaffTemplate template) {
    switch (template) {
      case StaffTemplate.owner:         return owner();
      case StaffTemplate.branchManager: return owner();
      case StaffTemplate.receptionist:  return receptionist();
      case StaffTemplate.teacher:       return teacher();
      case StaffTemplate.nanny:         return nanny();
      case StaffTemplate.busChaperone:  return _base({});
    }
  }

  static Map<String, bool> owner() => {
    for (final p in PermissionKeys.all) p: true,
  };

  static Map<String, bool> receptionist() => _base({
    PermissionKeys.childrenView:    true,
    PermissionKeys.childrenAdd:     true,
    PermissionKeys.childrenEdit:    true,
    PermissionKeys.parentsView:     true,
    PermissionKeys.parentsAdd:      true,
    PermissionKeys.parentsEdit:     true,
    PermissionKeys.attendanceView:  true,
    PermissionKeys.attendanceCheckIn:  true,
    PermissionKeys.attendanceCheckOut: true,
    PermissionKeys.pickupView:      true,
    PermissionKeys.pickupManage:    true,
    PermissionKeys.pickupApprove:   true,
    PermissionKeys.waitingListView:   true,
    PermissionKeys.waitingListManage: true,
  });

  static Map<String, bool> teacher() => _base({
    PermissionKeys.childrenView:       true,
    PermissionKeys.attendanceView:     true,
    PermissionKeys.attendanceCheckIn:  true,
    PermissionKeys.classroomView:      true,
    PermissionKeys.classroomPosts:     true,
    PermissionKeys.dailyCareView:      true,
    PermissionKeys.announcementsView:  true,
  });

  static Map<String, bool> nanny() => _base({
    PermissionKeys.childrenView:      true,
    PermissionKeys.attendanceCheckIn: true,
    PermissionKeys.dailyCareView:     true,
    PermissionKeys.dailyCareLog:      true,
  });

  /// Start with every permission = false, then apply [overrides].
  /// New permissions added to PermissionKeys.all auto-default to false.
  static Map<String, bool> _base(Map<String, bool> overrides) => {
    for (final p in PermissionKeys.all) p: false,
    ...overrides,
  };
}

import 'package:get/get.dart';

abstract class PermissionLabels {
  // Values are translation keys, resolved via `.tr` in [label] / [groupOf].
  static const Map<String, String> _labels = {
    // الأطفال
    'children.view':            'globalutil6_perm_children_view',
    'children.add':             'globalutil6_perm_children_add',
    'children.edit':            'globalutil6_perm_children_edit',
    'children.delete':          'globalutil6_perm_children_delete',
    'children.transfer_class':  'globalutil6_perm_children_transfer_class',
    'children.transfer_branch': 'globalutil6_perm_children_transfer_branch',
    // أولياء الأمور
    'parents.view': 'globalutil6_perm_parents_view',
    'parents.add':  'globalutil6_perm_parents_add',
    'parents.edit': 'globalutil6_perm_parents_edit',
    // الحضور
    'attendance.view':      'globalutil6_perm_attendance_view',
    'attendance.check_in':  'globalutil6_perm_attendance_check_in',
    'attendance.check_out': 'globalutil6_perm_attendance_check_out',
    'attendance.edit':      'globalutil6_perm_attendance_edit',
    // الفصول
    'classroom.view':          'globalutil6_perm_classroom_view',
    'classroom.manage':        'globalutil6_perm_classroom_manage',
    'classroom.posts':         'globalutil6_perm_classroom_posts',
    'classroom.review_photos': 'globalutil6_perm_classroom_review_photos',
    // الرعاية اليومية
    'daily_care.view': 'globalutil6_perm_daily_care_view',
    'daily_care.log':  'globalutil6_perm_daily_care_log',
    // الموظفون
    'staff.view':        'globalutil6_perm_staff_view',
    'staff.add':         'globalutil6_perm_staff_add',
    'staff.edit':        'globalutil6_perm_staff_edit',
    'staff.deactivate':  'globalutil6_perm_staff_deactivate',
    'staff.permissions': 'globalutil6_perm_manage_permissions',
    // الاستلام
    'pickup.view':    'globalutil6_perm_pickup_view',
    'pickup.manage':  'globalutil6_perm_pickup_manage',
    'pickup.approve': 'globalutil6_perm_pickup_approve',
    // قائمة الانتظار
    'waiting_list.view':   'globalutil6_perm_waiting_list_view',
    'waiting_list.manage': 'globalutil6_perm_waiting_list_manage',
    // الإعلانات
    'announcements.view':        'globalutil6_perm_announcements_view',
    'announcements.send_class':  'globalutil6_perm_announcements_send_class',
    'announcements.send_branch': 'globalutil6_perm_announcements_send_branch',
    'announcements.send_all':    'globalutil6_perm_announcements_send_all',
    // التقارير
    'reports.attendance': 'globalutil6_perm_reports_attendance',
    'reports.children':   'globalutil6_perm_reports_children',
    'reports.staff':      'globalutil6_perm_reports_staff',
    'reports.finance':    'globalutil6_perm_reports_finance',
    // المالية
    'finance.view':   'globalutil6_perm_finance_view',
    'finance.manage': 'globalutil6_perm_finance_manage',
    // الإعدادات
    'settings.nursery':     'globalutil6_perm_settings_nursery',
    'settings.branches':    'globalutil6_perm_settings_branches',
    'settings.permissions': 'globalutil6_perm_manage_permissions',
  };

  static const Map<String, String> _groups = {
    'children':     'globalutil6_permgroup_children',
    'parents':      'globalutil6_permgroup_parents',
    'attendance':   'globalutil6_permgroup_attendance',
    'classroom':    'globalutil6_permgroup_classroom',
    'daily_care':   'globalutil6_permgroup_daily_care',
    'staff':        'globalutil6_permgroup_staff',
    'pickup':       'globalutil6_permgroup_pickup',
    'waiting_list': 'globalutil6_permgroup_waiting_list',
    'announcements':'globalutil6_permgroup_announcements',
    'reports':      'globalutil6_permgroup_reports',
    'finance':      'globalutil6_permgroup_finance',
    'settings':     'globalutil6_permgroup_settings',
  };

  static String label(String key) {
    final k = _labels[key];
    return k != null ? k.tr : key;
  }

  static String groupOf(String key) {
    final prefix = key.contains('.') ? key.split('.').first : key;
    final g = _groups[prefix];
    return g != null ? g.tr : prefix;
  }

  /// Groups a flat list of keys by their section prefix.
  /// Preserves the natural order of PermissionKeys.all.
  static Map<String, List<String>> grouped(List<String> keys) {
    final result = <String, List<String>>{};
    for (final key in keys) {
      final prefix = key.contains('.') ? key.split('.').first : key;
      result.putIfAbsent(prefix, () => []).add(key);
    }
    return result;
  }
}

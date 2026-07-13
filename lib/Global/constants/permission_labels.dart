abstract class PermissionLabels {
  static const Map<String, String> _labels = {
    // الأطفال
    'children.view':            'عرض الأطفال',
    'children.add':             'إضافة طفل',
    'children.edit':            'تعديل بيانات طفل',
    'children.delete':          'حذف طفل',
    'children.transfer_class':  'نقل طفل بين الفصول',
    'children.transfer_branch': 'نقل طفل بين الفروع',
    // أولياء الأمور
    'parents.view': 'عرض أولياء الأمور',
    'parents.add':  'إضافة ولي أمر',
    'parents.edit': 'تعديل بيانات ولي الأمر',
    // الحضور
    'attendance.view':      'عرض سجل الحضور',
    'attendance.check_in':  'تسجيل الحضور',
    'attendance.check_out': 'تسجيل الانصراف',
    'attendance.edit':      'تعديل سجل الحضور',
    // الفصول
    'classroom.view':          'عرض الفصول',
    'classroom.manage':        'إدارة الفصول',
    'classroom.posts':         'النشر في الفصل',
    'classroom.review_photos': 'مراجعة صور الأنشطة',
    // الرعاية اليومية
    'daily_care.view': 'عرض الرعاية اليومية',
    'daily_care.log':  'تسجيل الرعاية اليومية',
    // الموظفون
    'staff.view':        'عرض الموظفين',
    'staff.add':         'إضافة موظف',
    'staff.edit':        'تعديل بيانات موظف',
    'staff.deactivate':  'إيقاف موظف',
    'staff.permissions': 'إدارة الصلاحيات',
    // الاستلام
    'pickup.view':    'عرض قائمة الاستلام',
    'pickup.manage':  'إدارة الاستلام',
    'pickup.approve': 'الموافقة على الاستلام',
    // قائمة الانتظار
    'waiting_list.view':   'عرض قائمة الانتظار',
    'waiting_list.manage': 'إدارة قائمة الانتظار',
    // الإعلانات
    'announcements.view':        'عرض الإعلانات',
    'announcements.send_class':  'إرسال إعلان للفصل',
    'announcements.send_branch': 'إرسال إعلان للفرع',
    'announcements.send_all':    'إرسال إعلان لجميع أولياء الأمور',
    // التقارير
    'reports.attendance': 'تقارير الحضور',
    'reports.children':   'تقارير الأطفال',
    'reports.staff':      'تقارير الموظفين',
    'reports.finance':    'التقارير المالية',
    // المالية
    'finance.view':   'عرض الحسابات',
    'finance.manage': 'إدارة الحسابات',
    // الإعدادات
    'settings.nursery':     'إعدادات الحضانة',
    'settings.branches':    'إدارة الفروع',
    'settings.permissions': 'إدارة الصلاحيات',
  };

  static const Map<String, String> _groups = {
    'children':     'الأطفال',
    'parents':      'أولياء الأمور',
    'attendance':   'الحضور والغياب',
    'classroom':    'الفصول الدراسية',
    'daily_care':   'الرعاية اليومية',
    'staff':        'الموظفون',
    'pickup':       'الاستلام',
    'waiting_list': 'قائمة الانتظار',
    'announcements':'الإعلانات',
    'reports':      'التقارير',
    'finance':      'المالية',
    'settings':     'الإعدادات',
  };

  static String label(String key) => _labels[key] ?? key;

  static String groupOf(String key) {
    final prefix = key.contains('.') ? key.split('.').first : key;
    return _groups[prefix] ?? prefix;
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

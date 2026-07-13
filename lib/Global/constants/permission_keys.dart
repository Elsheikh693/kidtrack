abstract class PermissionKeys {
  // ── Children ─────────────────────────────────────────────
  static const childrenView = 'children.view';
  static const childrenAdd = 'children.add';
  static const childrenEdit = 'children.edit';
  static const childrenDelete = 'children.delete';
  static const childrenTransferClass = 'children.transfer_class';
  static const childrenTransferBranch = 'children.transfer_branch';

  // ── Parents ───────────────────────────────────────────────
  static const parentsView = 'parents.view';
  static const parentsAdd = 'parents.add';
  static const parentsEdit = 'parents.edit';

  // ── Attendance ────────────────────────────────────────────
  static const attendanceView = 'attendance.view';
  static const attendanceCheckIn = 'attendance.check_in';
  static const attendanceCheckOut = 'attendance.check_out';
  static const attendanceEdit = 'attendance.edit';

  // ── Classroom ─────────────────────────────────────────────
  static const classroomView = 'classroom.view';
  static const classroomManage = 'classroom.manage';
  static const classroomPosts = 'classroom.posts';
  static const classroomReviewPhotos = 'classroom.review_photos';

  // ── Daily Care ────────────────────────────────────────────
  static const dailyCareView = 'daily_care.view';
  static const dailyCareLog = 'daily_care.log';

  // ── Staff ─────────────────────────────────────────────────
  static const staffView = 'staff.view';
  static const staffAdd = 'staff.add';
  static const staffEdit = 'staff.edit';
  static const staffDeactivate = 'staff.deactivate';
  static const staffPermissions = 'staff.permissions';

  // ── Pickup ────────────────────────────────────────────────
  static const pickupView = 'pickup.view';
  static const pickupManage = 'pickup.manage';
  static const pickupApprove = 'pickup.approve';

  // ── Waiting List ──────────────────────────────────────────
  static const waitingListView = 'waiting_list.view';
  static const waitingListManage = 'waiting_list.manage';

  // ── Announcements ─────────────────────────────────────────
  static const announcementsView = 'announcements.view';
  static const announcementsSendClass = 'announcements.send_class';
  static const announcementsSendBranch = 'announcements.send_branch';
  static const announcementsSendAll = 'announcements.send_all';

  // ── Reports ───────────────────────────────────────────────
  static const reportsAttendance = 'reports.attendance';
  static const reportsChildren = 'reports.children';
  static const reportsStaff = 'reports.staff';
  static const reportsFinance = 'reports.finance';

  // ── Finance ───────────────────────────────────────────────
  static const financeView = 'finance.view';
  static const financeManage = 'finance.manage';

  // ── Settings ──────────────────────────────────────────────
  static const settingsNursery = 'settings.nursery';
  static const settingsBranches = 'settings.branches';
  static const settingsPermissions = 'settings.permissions';

  // ── Master list ───────────────────────────────────────────
  static const List<String> all = [
    childrenView,
    childrenAdd,
    childrenEdit,
    childrenDelete,
    childrenTransferClass,
    childrenTransferBranch,
    parentsView,
    parentsAdd,
    parentsEdit,
    attendanceView,
    attendanceCheckIn,
    attendanceCheckOut,
    attendanceEdit,
    classroomView,
    classroomManage,
    classroomPosts,
    classroomReviewPhotos,
    dailyCareView,
    dailyCareLog,
    staffView,
    staffAdd,
    staffEdit,
    staffDeactivate,
    staffPermissions,
    pickupView,
    pickupManage,
    pickupApprove,
    waitingListView,
    waitingListManage,
    announcementsView,
    announcementsSendClass,
    announcementsSendBranch,
    announcementsSendAll,
    reportsAttendance,
    reportsChildren,
    reportsStaff,
    reportsFinance,
    financeView,
    financeManage,
    settingsNursery,
    settingsBranches,
    settingsPermissions,
  ];
}

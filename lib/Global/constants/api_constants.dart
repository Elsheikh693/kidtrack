class ApiConstants {
  ApiConstants._();

  static const String baseUrl = "https://kidtrack-bed28-default-rtdb.firebaseio.com/";

  static const Map<String, String> header = {
    "Content-Type": "application/json",
  };

  // ─── Nursery ID (set after login) ─────────────────────────────────────────
  static String? _nurseryId;

  static String get nurseryId => _nurseryId ?? '';

  static void setNurseryId(String id) => _nurseryId = id;

  // ─── Base scoped path ─────────────────────────────────────────────────────
  static String get _n => 'platform/$nurseryId';

  // ─── Nursery-scoped Endpoints ─────────────────────────────────────────────
  static String get packages => '$_n/packages';

  static String get branches => '$_n/branches';

  static String get branchTargets => '$_n/branchTargets';

  static String get staff => '$_n/staff';

  static String get permissionSets => '$_n/permissionSets';

  static String get classrooms => '$_n/classrooms';

  static String get programs => '$_n/programs';

  static String get subjects => '$_n/subjects';

  static String get children => '$_n/children';

  static String get enrollments => '$_n/enrollments';

  static String get medicalProfiles => '$_n/medicalProfiles';

  static String get documents => '$_n/documents';

  static String get authorizedPickups => '$_n/authorizedPickups';

  static String get waitingList => '$_n/waitingList';

  static String get parents => '$_n/parents';

  static String get parentChildren => '$_n/parentChildren';

  static String get childAttendance => '$_n/childAttendance';

  static String get staffAttendance => '$_n/staffAttendance';

  static String get staffLeaves => '$_n/staffLeaves';

  static String get childLeaveRequests => '$_n/childLeaveRequests';

  static String get childReports => '$_n/childReports';

  static String get assessments => '$_n/assessments';

  static String get incidents => '$_n/incidents';

  static String get notes => '$_n/notes';

  static String get lessonPlans => '$_n/lessonPlans';

  static String get classroomPosts => '$_n/classroomPosts';

  static String get announcements => '$_n/announcements';

  static String get schedules => '$_n/schedules';

  static String get dailyCareLogs => '$_n/dailyCareLogs';

  static String get invoices => '$_n/invoices';

  static String get payments => '$_n/payments';

  static String get paymentCategories => '$_n/paymentCategories';

  static String get expenses => '$_n/expenses';

  static String get classroomActivities => '$_n/classroomActivities';

  static String get feed => '$_n/feed';

  /// Parent → nursery ratings, keyed by parentId: `feedback/{parentId}`.
  /// Read by owner/manager to see how families rate the nursery.
  static String get nurseryFeedback => '$_n/feedback';

  /// Per-child manager↔parent conversations: `chats/{childId}/meta` +
  /// `chats/{childId}/messages/{messageId}`. Real-time RTDB (not 4-layer CRUD).
  static String get chats => '$_n/chats';

  static String get pickupRequests => '$_n/pickupRequests';

  static String get homework => '$_n/homework';

  /// Parent completion events, keyed by homework then child:
  /// `homeworkSubmissions/{homeworkId}/{childId}`.
  static String get homeworkSubmissions => '$_n/homeworkSubmissions';

  /// Teacher review/assessment of a homework, keyed by homework then child:
  /// `homeworkStatus/{homeworkId}/{childId}`.
  static String get homeworkStatus => '$_n/homeworkStatus';

  static String get careEvents => '$_n/careEvents';

  static String get courses => '$_n/courses';

  static String courseLessons(String courseId) => '$_n/courseLessons/$courseId';

  static String get events => '$_n/events';

  static String eventAttendees(String eventId) => '$_n/eventAttendees/$eventId';

  static String courseProgress(String uid) => '$_n/courseProgress/$uid';

  static String get childCurrentStatus => '$_n/childCurrentStatus';

  static String childDailyEvents(String date) => '$_n/childDailyEvents/$date';

  static String get academicTopics => '$_n/academicTopics';

  static String get topicProgress => '$_n/topicProgress';

  static String get teacherAssignments => '$_n/teacherAssignments';

  static String get dailyAssessments => '$_n/dailyAssessments';

  static String get childStateTemplates => '$_n/childStateTemplates';

  static String get nurseryContacts => '$_n/nurseryContacts';

  static String get onlineApplications => '$_n/onlineApplications';

  /// Pre-login scoped path for a specific nursery (used when the global
  /// [nurseryId] is not yet set — e.g. a guest submitting an admission form).
  static String onlineApplicationsFor(String nurseryId) =>
      'platform/$nurseryId/onlineApplications';

  /// Pre-login scoped branches list for a specific nursery (guest browsing the
  /// admission form before having an account).
  static String branchesFor(String nurseryId) =>
      'platform/$nurseryId/branches';

  /// Pre-login scoped packages/fees list for a specific nursery.
  static String packagesFor(String nurseryId) =>
      'platform/$nurseryId/packages';

  // ─── Global Endpoints ─────────────────────────────────────────────────────
  static const String users = 'users';
  static const String superAdmins = 'superAdmins';
  static const String auditLogs = 'auditLogs';
  static const String supportTickets = 'supportTickets';

  // ─── Platform content (global, readable pre-login) ─────────────────────────
  static const String contactInfo = 'contactInfo';
  static const String aboutUs = 'aboutUs';
  static const String supportRequests = 'supportRequests';

  // ─── Platform billing (SuperAdmin → nursery subscription) ──────────────────
  /// Global root. Monthly subscription bills the platform charges each nursery,
  /// keyed by nursery then month: `platformBilling/{nurseryId}/{YYYYMM}`.
  static const String platformBilling = 'platformBilling';

  static String platformBillingFor(String nurseryId) =>
      'platformBilling/$nurseryId';

  /// A specific nursery's children subtree, addressed by explicit id (used by
  /// SuperAdmin billing to recount active children per branch, outside session
  /// scope).
  static String childrenFor(String nurseryId) => 'platform/$nurseryId/children';

  static String notifications(String userId) => 'notifications/$userId';

  // Bus tracking is branch-scoped (not nursery), real-time RTDB
  static String busTracking(String branchId) => 'busTracking/$branchId';
}

/// Nursery path resolver.
///
/// Two DIFFERENT concepts that must never share a path or a constant:
///   • [globalNurseries] — the platform-wide registry of every nursery. Read by
///     SuperAdmin and pre-login Discovery. NOT bound to any session.
///   • [nurseryInfo] — a single nursery's own scoped data container, addressed
///     by an explicit id. Bound to one tenant.
class ApiPaths {
  ApiPaths._();

  /// `platform/info` — the global registry of all nurseries.
  static const String globalNurseries = 'platform/info';

  /// `platform/{id}/info` — one nursery's scoped info node.
  static String nurseryInfo(String id) => 'platform/$id/info';
}

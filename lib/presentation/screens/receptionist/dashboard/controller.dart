import '../../../../index/index_main.dart';

/// A pending pickup request resolved with display names + a formatted time.
class PendingPickupData {
  final String key;
  final String childName;
  final String parentName;
  final String time;

  const PendingPickupData({
    required this.key,
    required this.childName,
    required this.parentName,
    required this.time,
  });
}

class ClassOccupancyData {
  final String classroomId;
  final String name;
  final int capacity;
  final int enrolled;

  const ClassOccupancyData({
    required this.classroomId,
    required this.name,
    required this.capacity,
    required this.enrolled,
  });

  double get fillRate => capacity > 0 ? enrolled / capacity : 0;
  bool get isFull => enrolled >= capacity;
  bool get isAlmostFull => !isFull && fillRate >= 0.85;
}

class ReceptionistDashboardController extends GetxController {
  // Stats
  final totalStudents = 0.obs;
  final presentToday = 0.obs;
  final absentToday = 0.obs;
  final checkedOutToday = 0.obs;
  final insideNow = 0.obs;
  final totalClasses = 0.obs;
  final totalParents = 0.obs;
  final pendingEnrollments = 0.obs;
  final pendingPickupRequests = 0.obs;
  final overdueInvoices = 0.obs;
  final unassignedStudents = 0.obs;
  final waitingListCount = 0.obs;

  final classOccupancy = <ClassOccupancyData>[].obs;
  final activityItems = <ChildAttendanceModel>[].obs;
  final pendingPickups = <PendingPickupData>[].obs;
  final activeEvents = <NurseryEventModel>[].obs;
  final isLoading = true.obs;

  late final ChildAttendanceParentService _attendanceSvc;
  late final ChildParentService _childSvc;
  late final ClassroomParentService _classroomSvc;
  late final EnrollmentParentService _enrollmentSvc;
  late final PickupRequestParentService _pickupSvc;
  late final InvoiceParentService _invoiceSvc;
  late final GuardianParentService _guardianSvc;
  late final WaitingListParentService _waitingListSvc;

  final _eventSvc = EventService();
  StreamSubscription<List<NurseryEventModel>>? _eventsSub;

  // Resolved-name lookups, filled as data loads.
  final _childNames = <String, String>{};
  final _parentNames = <String, String>{};
  List<PickupRequestModel> _rawPendingPickups = const [];

  final _session = SessionService();

  String get branchId => _session.branchId ?? '';

  static String get _today {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    _attendanceSvc = Get.find<ChildAttendanceParentService>();
    _childSvc = Get.find<ChildParentService>();
    _classroomSvc = Get.find<ClassroomParentService>();
    _enrollmentSvc = Get.find<EnrollmentParentService>();
    _pickupSvc = Get.find<PickupRequestParentService>();
    _invoiceSvc = Get.find<InvoiceParentService>();
    _guardianSvc = Get.find<GuardianParentService>();
    _waitingListSvc = Get.find<WaitingListParentService>();
    _subscribeEvents();
    loadDashboard();
  }

  @override
  void onClose() {
    _eventsSub?.cancel();
    super.onClose();
  }

  void _subscribeEvents() {
    _eventsSub?.cancel();
    _eventsSub = _eventSvc.watchAllEvents().listen((list) {
      final startOfToday =
          DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .millisecondsSinceEpoch;
      activeEvents.value = list
          .where((e) =>
              e.isActive &&
              e.date >= startOfToday &&
              (e.branchId == null || e.branchId == branchId))
          .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
    }, onError: (_) {});
  }

  /// Is this event happening today? → render a "live" badge.
  bool isEventLive(NurseryEventModel e) {
    final now = DateTime.now();
    final d = e.dateTime;
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  Future<void> loadDashboard() async {
    isLoading.value = true;
    await _loadAttendanceStats();
    await _loadChildrenAndClassrooms();
    await _loadPickupAndInvoice();
    await _loadParentsAndWaiting();
    _buildPendingPickups();
    isLoading.value = false;
  }

  Future<void> _loadAttendanceStats() async {
    await _attendanceSvc.getAll(callBack: (list) {
      final records = list
          .whereType<ChildAttendanceModel>()
          .where((a) => a.branchId == branchId && a.date == _today)
          .toList();

      final present =
          records.where((a) => a.status == 'present' || a.status == 'late').length;
      final checkedOut = records.where((a) => a.checkOutTime != null).length;

      presentToday.value = present;
      checkedOutToday.value = checkedOut;
      insideNow.value = (present - checkedOut).clamp(0, present);

      final sorted = records.where((a) => a.checkInTime != null).toList()
        ..sort((a, b) => (b.checkInTime ?? 0).compareTo(a.checkInTime ?? 0));
      activityItems.value = sorted.take(15).toList();
    });
  }

  Future<void> _loadChildrenAndClassrooms() async {
    late List<ClassroomModel> rooms;
    late List<EnrollmentModel> enrolls;

    await _childSvc.getAll(callBack: (list) {
      final branch = list
          .whereType<ChildModel>()
          .where((c) => c.branchId == branchId && c.status == 'active')
          .toList();
      _childNames
        ..clear()
        ..addEntries(branch
            .where((c) => c.key != null)
            .map((c) => MapEntry(c.key!, c.fullName)));
      totalStudents.value = branch.length;
      absentToday.value = (branch.length - presentToday.value).clamp(0, branch.length);
      unassignedStudents.value =
          branch.where((c) => c.classroomId == null || c.classroomId!.isEmpty).length;
    });

    await _classroomSvc.getAll(callBack: (list) {
      rooms = list
          .whereType<ClassroomModel>()
          .where((c) => (c.isAllBranches || c.branchIds.contains(branchId)) && c.isActive)
          .toList();
      totalClasses.value = rooms.length;
    });

    await _enrollmentSvc.getAll(callBack: (list) {
      enrolls = list
          .whereType<EnrollmentModel>()
          .where((e) => e.branchId == branchId)
          .toList();
      pendingEnrollments.value =
          enrolls.where((e) => e.status == 'pending').length;

      final enrolled = enrolls.where((e) => e.status == 'enrolled').toList();
      classOccupancy.value = rooms.map((cls) {
        final count = enrolled.where((e) => e.classroomId == cls.key).length;
        return ClassOccupancyData(
          classroomId: cls.key ?? '',
          name: cls.name,
          capacity: cls.capacity ?? 20,
          enrolled: count,
        );
      }).toList();
    });
  }

  Future<void> _loadPickupAndInvoice() async {
    await _pickupSvc.getAll(callBack: (list) {
      _rawPendingPickups = list
          .whereType<PickupRequestModel>()
          .where((p) => p.branchId == branchId && p.status == 'requested')
          .toList()
        ..sort((a, b) => (a.requestedPickupTime ?? a.createdAt ?? 0)
            .compareTo(b.requestedPickupTime ?? b.createdAt ?? 0));
      pendingPickupRequests.value = _rawPendingPickups.length;
    });

    await _invoiceSvc.getAll(callBack: (list) {
      final now = DateTime.now().millisecondsSinceEpoch;
      overdueInvoices.value = list
          .whereType<InvoiceModel>()
          .where((inv) =>
              inv.status == 'overdue' ||
              (inv.status == 'pending' &&
                  inv.dueDate != null &&
                  inv.dueDate! < now))
          .length;
    });
  }

  Future<void> _loadParentsAndWaiting() async {
    await _guardianSvc.getAll(callBack: (list) {
      final parents = list.whereType<ParentModel>().toList();
      _parentNames
        ..clear()
        ..addEntries(parents.map((p) => MapEntry(p.uid, p.name)));
      totalParents.value = parents.length;
    });

    await _waitingListSvc.getAll(callBack: (list) {
      waitingListCount.value = list
          .whereType<WaitingListModel>()
          .where((w) => (w.branchId ?? '') == branchId && w.status == 'pending')
          .length;
    });
  }

  void _buildPendingPickups() {
    pendingPickups.value = _rawPendingPickups.map((p) {
      return PendingPickupData(
        key: p.key ?? '',
        childName: _childNames[p.childId] ?? 'reception_unknown_child'.tr,
        parentName: _parentNames[p.parentId] ?? 'reception_unknown_parent'.tr,
        time: _formatPickupTime(p.requestedPickupTime ?? p.createdAt),
      );
    }).toList();
  }

  /// Formats an epoch-ms timestamp into a 12-hour Arabic-friendly time (e.g. 1:45 م).
  String _formatPickupTime(int? ms) {
    if (ms == null) return '--';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final isAr = Get.locale?.languageCode == 'ar';
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final suffix = dt.hour < 12
        ? (isAr ? 'ص' : 'AM')
        : (isAr ? 'م' : 'PM');
    return '$hour12:$minute $suffix';
  }
}

import '../../../../index/index_main.dart';
import '../../../../Global/services/child_status_service.dart';

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
  // Parent onboarding funnel (WhatsApp invitation → activation).
  final parentsActivated = 0.obs;
  final parentsAwaiting = 0.obs;
  final parentsNotSent = 0.obs;
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

  late final ChildParentService _childSvc;
  late final ClassroomParentService _classroomSvc;
  late final EnrollmentParentService _enrollmentSvc;
  late final PickupRequestParentService _pickupSvc;
  late final InvoiceParentService _invoiceSvc;
  late final GuardianParentService _guardianSvc;
  late final WaitingListParentService _waitingListSvc;

  final _eventSvc = EventService();
  StreamSubscription<List<NurseryEventModel>>? _eventsSub;

  // Live "present today" — the dated childAttendance node is the single source
  // of truth (same stream the teacher home reads), so a check-in / check-out
  // reflects on the dashboard instantly instead of only on pull-to-refresh.
  final _statusSvc = ChildStatusService();
  StreamSubscription<List<ChildAttendanceModel>>? _attendanceSub;

  // Live nursery↔parent conversations, for the unread badge on the home chat
  // icon: sum of unreadManager across this branch's children.
  final _chatService = ChatService();
  final _convos = <String, ChatConversationModel>{}.obs;
  StreamSubscription<List<ChatConversationModel>>? _convoSub;

  // Resolved-name lookups, filled as data loads.
  final _childNames = <String, String>{};
  final _parentNames = <String, String>{};
  List<PickupRequestModel> _rawPendingPickups = const [];

  final _session = SessionService();

  String get branchId => _session.branchId ?? '';
  String get _nurseryId => _session.nurseryId ?? '';

  static String get _today {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  @override
  void onInit() {
    super.onInit();
    _childSvc = Get.find<ChildParentService>();
    _classroomSvc = Get.find<ClassroomParentService>();
    _enrollmentSvc = Get.find<EnrollmentParentService>();
    _pickupSvc = Get.find<PickupRequestParentService>();
    _invoiceSvc = Get.find<InvoiceParentService>();
    _guardianSvc = Get.find<GuardianParentService>();
    _waitingListSvc = Get.find<WaitingListParentService>();
    _subscribeEvents();
    _subscribeAttendance();
    _convoSub = _chatService.watchConversations().listen((list) {
      _convos.value = {for (final c in list) c.childId: c};
    }, onError: (_) {});
    loadDashboard();
  }

  @override
  void onClose() {
    _eventsSub?.cancel();
    _attendanceSub?.cancel();
    _convoSub?.cancel();
    super.onClose();
  }

  /// Total unread guardian messages across this branch's children — drives the
  /// badge on the home chat icon (matches what the chat inbox shows).
  int get chatUnread {
    var total = 0;
    // Touch the reactive map first so a surrounding Obx always registers it as a
    // dependency — even before any child names have loaded (empty loop below),
    // otherwise GetX throws "improper use of GetX" for reading no observable.
    if (_convos.isNotEmpty) {
      for (final key in _childNames.keys) {
        total += _convos[key]?.unreadManager ?? 0;
      }
    }
    return total;
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
    await _loadChildrenAndClassrooms();
    await _loadPickupAndInvoice();
    await _loadParentsAndWaiting();
    _buildPendingPickups();
    // Children scope is now loaded — recompute the chat badge against it.
    _convos.refresh();
    isLoading.value = false;
  }

  /// Live presence: recomputes the today counters + activity feed on every
  /// write to the childAttendance node, so the dashboard never shows stale
  /// presence and no manual refresh is needed.
  void _subscribeAttendance() {
    _attendanceSub?.cancel();
    _attendanceSub =
        _statusSvc.watchAttendanceForDay(_nurseryId).listen(_applyAttendance,
            onError: (_) {});
  }

  void _applyAttendance(List<ChildAttendanceModel> list) {
    final records = list
        .where((a) => a.branchId == branchId && a.date == _today)
        .toList();

    final present =
        records.where((a) => a.status == 'present' || a.status == 'late').length;
    final checkedOut = records.where((a) => a.checkOutTime != null).length;

    presentToday.value = present;
    checkedOutToday.value = checkedOut;
    insideNow.value = (present - checkedOut).clamp(0, present);
    absentToday.value =
        (totalStudents.value - present).clamp(0, totalStudents.value);

    final sorted = records.where((a) => a.checkInTime != null).toList()
      ..sort((a, b) => (b.checkInTime ?? 0).compareTo(a.checkInTime ?? 0));
    activityItems.value = sorted.take(15).toList();
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
              inv.hasOutstanding &&
              (inv.status == 'overdue' ||
                  (inv.dueDate != null && inv.dueDate! < now)))
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

      var activated = 0, awaiting = 0, notSent = 0;
      for (final p in parents) {
        switch (p.onboardingStatus) {
          case ParentOnboardingStatus.activated:
            activated++;
          case ParentOnboardingStatus.sent:
            awaiting++;
          case ParentOnboardingStatus.notSent:
            notSent++;
        }
      }
      parentsActivated.value = activated;
      parentsAwaiting.value = awaiting;
      parentsNotSent.value = notSent;
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

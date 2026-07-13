import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';
import '../../../../Global/services/child_status_service.dart';
import 'models/class_health_data.dart';
import 'models/child_risk_data.dart';
import 'models/long_absence_data.dart';
import 'models/overdue_family_data.dart';
import 'models/presence_entry.dart';

class ManagerChildrenController extends GetxController {
  static const int longAbsenceThresholdDays = 5;

  // ─── Overview KPIs ──────────────────────────────────────────────────────
  final activeChildren = 0.obs;
  final presentNow = 0.obs;
  final newThisMonth = 0.obs;
  final leftThisMonth = 0.obs;

  /// This month's withdrawals for this branch, newest first — the surviving log
  /// of hard-deleted children (name + reason + date) shown when the manager taps
  /// the "withdrawn" movement stat.
  final withdrawnThisMonth = <WithdrawalLogModel>[].obs;
  final occupancyRate = 0.obs;
  final unassignedCount = 0.obs;

  /// Net enrollment movement for the current month (arrivals − departures).
  int get netThisMonth => newThisMonth.value - leftThisMonth.value;

  // ─── Live Presence (today) ──────────────────────────────────────────────
  /// Children checked in today and still on-site (not yet picked up).
  final insideNow = <PresenceEntry>[].obs;
  /// Children who attended today and have already been checked out.
  final leftToday = <PresenceEntry>[].obs;

  // ─── Classroom Health ───────────────────────────────────────────────────
  final classHealth = <ClassHealthData>[].obs;

  // ─── Attention Required ─────────────────────────────────────────────────
  final riskChildren = <ChildRiskData>[].obs;
  final longAbsence = <LongAbsenceData>[].obs;
  final overdueFamilies = <OverdueFamilyData>[].obs;

  // ─── Directory ──────────────────────────────────────────────────────────
  final directory = <ChildModel>[].obs;
  final filteredDirectory = <ChildModel>[].obs;
  final searchQuery = ''.obs;
  final searchActive = false.obs;

  final isLoading = true.obs;

  late final ChildParentService _childSvc;
  late final ClassroomParentService _classroomSvc;
  late final EnrollmentParentService _enrollmentSvc;
  late final ChildAttendanceParentService _attendanceSvc;
  late final NoteParentService _noteSvc;
  late final IncidentParentService _incidentSvc;
  late final AssessmentParentService _assessmentSvc;
  late final InvoiceParentService _invoiceSvc;
  late final GuardianParentService _guardianSvc;
  late final ParentChildParentService _linkSvc;
  late final StaffParentService _staffSvc;
  late final WithdrawalParentService _withdrawalSvc;

  late Worker _searchWorker;

  final _session = SessionService();
  final _db = FirebaseDatabase.instance;
  StreamSubscription<DatabaseEvent>? _activitySub;

  // Live "present today". Presence (presentNow / insideNow / leftToday) is
  // derived from the dated childAttendance node in real time, so a check-in or
  // check-out reflects on the manager overview instantly — the one-shot getAll
  // stays only for the multi-day long-absence signal, which needs full history.
  final _statusSvc = ChildStatusService();
  StreamSubscription<List<ChildAttendanceModel>>? _presenceSub;
  List<ChildAttendanceModel> _todayAttendance = const [];

  // Live nursery↔parent conversations (per child) for the chat entry point on
  // each directory tile: drives the unread badge and lets the manager message
  // the guardian directly from the child list.
  final _chatService = ChatService();
  final RxMap<String, ChatConversationModel> chatConvos =
      <String, ChatConversationModel>{}.obs;
  StreamSubscription<List<ChatConversationModel>>? _convoSub;

  final _parentNames = <String, String>{};
  final _parentIds = <String, String>{};

  final _classroomNames = <String, String>{};
  final _teacherNames = <String, String>{};
  final _childNames = <String, String>{};
  final _childImages = <String, String>{};
  final _childClassroom = <String, String?>{};
  final _branchChildKeys = <String>{};
  final _riskReasons = <String, Set<String>>{};

  // Cached per-classroom counts + live-activity set, so classroom health can be
  // rebuilt whenever either enrollments OR the live activity stream changes.
  final _enrolledByRoom = <String, int>{};
  final _pendingByRoom = <String, int>{};
  final _activeClassroomIds = <String>{};

  String get branchId => _session.branchId ?? '';
  String get _nurseryId => _session.nurseryId ?? '';


  bool get hasAttention =>
      riskChildren.isNotEmpty ||
      longAbsence.isNotEmpty ||
      overdueFamilies.isNotEmpty ||
      unassignedCount.value > 0;

  @override
  void onInit() {
    super.onInit();
    _childSvc = Get.find<ChildParentService>();
    _classroomSvc = Get.find<ClassroomParentService>();
    _enrollmentSvc = Get.find<EnrollmentParentService>();
    _attendanceSvc = Get.find<ChildAttendanceParentService>();
    _noteSvc = Get.find<NoteParentService>();
    _incidentSvc = Get.find<IncidentParentService>();
    _assessmentSvc = Get.find<AssessmentParentService>();
    _invoiceSvc = Get.find<InvoiceParentService>();
    _guardianSvc = Get.find<GuardianParentService>();
    _linkSvc = Get.find<ParentChildParentService>();
    _staffSvc = Get.find<StaffParentService>();
    _withdrawalSvc = Get.find<WithdrawalParentService>();
    _searchWorker = debounce(
      searchQuery,
      (_) => _filter(),
      time: const Duration(milliseconds: 300),
    );
    loadData();
    _watchActiveActivities();
    _subscribePresence();
    _convoSub = _chatService.watchConversations().listen((list) {
      chatConvos.value = {for (final c in list) c.childId: c};
    });
  }

  @override
  void onClose() {
    _searchWorker.dispose();
    _activitySub?.cancel();
    _presenceSub?.cancel();
    _convoSub?.cancel();
    super.onClose();
  }

  /// Unread messages from the guardian for [childId] (nursery/staff side).
  int chatUnread(String? childId) =>
      childId == null ? 0 : (chatConvos[childId]?.unreadManager ?? 0);

  String parentName(String? childId) =>
      childId == null ? '' : (_parentNames[childId] ?? '');

  /// Opens the nursery↔guardian conversation for [child] (staff side).
  Future<void> openChat(ChildModel child) => openStaffChat(
        child: child,
        parentId: _parentIds[child.key] ?? child.parentId ?? '',
        parentName: parentName(child.key),
      );

  /// Live stream of every classroom's activities. Keeps [_activeClassroomIds]
  /// in sync so the health cards can flag classes with a running activity in
  /// real time (a teacher started an activity → badge appears immediately).
  void _watchActiveActivities() {
    _activitySub?.cancel();
    _activitySub =
        _db.ref(ApiConstants.classroomActivities).onValue.listen((event) {
      final active = <String>{};
      final root = event.snapshot.value;
      if (root is Map) {
        root.forEach((classroomId, activities) {
          if (activities is Map &&
              activities.values.any((a) =>
                  a is Map && a['status']?.toString() == 'active')) {
            active.add(classroomId.toString());
          }
        });
      }
      _activeClassroomIds
        ..clear()
        ..addAll(active);
      _rebuildClassHealth();
    });
  }

  String classroomName(String? id) =>
      (id == null || _classroomNames[id] == null)
          ? 'manager_children_no_class'.tr
          : _classroomNames[id]!;

  void onSearch(String value) => searchQuery.value = value;

  void toggleSearch() {
    searchActive.toggle();
    if (!searchActive.value) {
      searchQuery.value = '';
      _filter();
    }
  }

  void openSearch() => searchActive.value = true;

  Future<void> openChild(String childId) async {
    if (childId.isEmpty) return;
    await Get.toNamed(childProfileView, arguments: {'childId': childId});
    // The child may have been withdrawn (hard-deleted) from the profile —
    // reload so the directory and KPIs reflect the departure.
    await loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    _riskReasons.clear();
    // Phase 1: children, classrooms, staff and parents are independent.
    await Future.wait(
        [_loadChildren(), _loadClassrooms(), _loadStaff(), _loadParents()]);
    // Phase 2: these all depend on phase 1's data but not on each other.
    await Future.wait([
      _loadEnrollments(),
      _loadAttendance(),
      _loadRiskSources(),
      _loadOverdueFamilies(),
      _loadWithdrawals(),
    ]);
    _buildRiskChildren();
    // The roster (_branchChildKeys / names / images) is now fresh — fold in
    // whatever the live attendance stream has already delivered.
    _recomputePresence();
    _filter();
    isLoading.value = false;
  }

  /// Maps each child to its primary guardian (name + id) so the chat entry
  /// point on a directory tile can address the right parent.
  Future<void> _loadParents() async {
    final parentById = <String, String>{};
    await _guardianSvc.getAll(callBack: (list) {
      for (final p in list.whereType<ParentModel>()) {
        parentById[p.uid] = p.name;
      }
    });
    await _linkSvc.getAll(callBack: (list) {
      _parentNames.clear();
      _parentIds.clear();
      for (final link in list.whereType<ParentChildModel>()) {
        final name = parentById[link.parentId];
        if (name == null) continue;
        if (link.isPrimary || !_parentNames.containsKey(link.childId)) {
          _parentNames[link.childId] = name;
          _parentIds[link.childId] = link.parentId;
        }
      }
    });
  }

  Future<void> _loadChildren() async {
    await _childSvc.getAll(callBack: (list) {
      // Active roster for this branch/shift. Withdrawn children are hard-deleted
      // server-side, so departures are counted from the withdrawals log instead
      // (see [_loadWithdrawals]).
      final branch = list
          .whereType<ChildModel>()
          .where((c) => c.branchId == branchId && _session.seesShift(c.shift))
          .where((c) => c.status == 'active')
          .toList()
        ..sort((a, b) => a.fullName.compareTo(b.fullName));

      _childNames
        ..clear()
        ..addEntries(
            branch.where((c) => c.key != null).map((c) => MapEntry(c.key!, c.fullName)));
      _childImages
        ..clear()
        ..addEntries(branch
            .where((c) => c.key != null && c.hasImage)
            .map((c) => MapEntry(c.key!, c.profileImage!)));
      _childClassroom
        ..clear()
        ..addEntries(branch
            .where((c) => c.key != null)
            .map((c) => MapEntry(c.key!, c.classroomId)));
      _branchChildKeys
        ..clear()
        ..addAll(branch.where((c) => c.key != null).map((c) => c.key!));

      final now = DateTime.now();
      bool inThisMonth(int? ms) {
        if (ms == null) return false;
        final d = DateTime.fromMillisecondsSinceEpoch(ms);
        return d.year == now.year && d.month == now.month;
      }

      activeChildren.value = branch.length;
      newThisMonth.value =
          branch.where((c) => inThisMonth(c.createdAt)).length;
      unassignedCount.value = branch
          .where((c) => c.classroomId == null || c.classroomId!.isEmpty)
          .length;
      directory.assignAll(branch);
    });
  }

  /// Departures for the current month, read from the withdrawal log (children
  /// are hard-deleted on withdrawal, so we can't count them off the roster).
  /// Keeps this branch's entries for this month (newest first) so the manager
  /// can tap the "withdrawn" stat to see who left and why.
  Future<void> _loadWithdrawals() async {
    final now = DateTime.now();
    await _withdrawalSvc.getAll(
      callBack: (list) {
        final entries = list
            .whereType<WithdrawalLogModel>()
            .where((w) => branchId.isEmpty || w.branchId == branchId)
            .where((w) {
          final d = w.withdrawnDate;
          return d != null && d.year == now.year && d.month == now.month;
        }).toList()
          ..sort((a, b) => (b.withdrawnAt ?? 0).compareTo(a.withdrawnAt ?? 0));
        withdrawnThisMonth.assignAll(entries);
        leftThisMonth.value = entries.length;
      },
    );
  }

  /// Opens the read-only list of this month's withdrawn children with reasons.
  void openWithdrawnList() {
    Get.bottomSheet(
      WithdrawnChildrenSheet(entries: withdrawnThisMonth.toList()),
      isScrollControlled: true,
    );
  }

  Future<void> _loadClassrooms() async {
    await _classroomSvc.getAll(callBack: (list) {
      final rooms = list
          .whereType<ClassroomModel>()
          .where((c) => (c.isAllBranches || c.branchIds.contains(branchId)) && c.isActive)
          .toList();
      _classroomNames
        ..clear()
        ..addEntries(
            rooms.where((c) => c.key != null).map((c) => MapEntry(c.key!, c.name)));
      _rooms = rooms;
    });
  }

  Future<void> _loadStaff() async {
    await _staffSvc.getAll(callBack: (list) {
      _teacherNames
        ..clear()
        ..addEntries(list
            .whereType<StaffModel>()
            .where((s) => s.key != null)
            .map((s) => MapEntry(s.key!, s.name)));
    });
  }

  Future<void> _loadEnrollments() async {
    await _enrollmentSvc.getAll(callBack: (list) {
      final pending = list
          .whereType<EnrollmentModel>()
          .where((e) => e.branchId == branchId && e.status == 'pending')
          .toList();

      // Roster size = children actually assigned to each room via
      // child.classroomId. Formal EnrollmentModel records aren't always
      // present in the data, so counting them showed 0.
      _enrolledByRoom
        ..clear()
        ..addEntries(_rooms.map((cls) => MapEntry(cls.key ?? '',
            _childClassroom.values.where((cid) => cid == cls.key).length)));
      _pendingByRoom
        ..clear()
        ..addEntries(_rooms.map((cls) => MapEntry(cls.key ?? '',
            pending.where((e) => e.classroomId == cls.key).length)));

      _rebuildClassHealth();
    });
  }

  /// Rebuilds the classroom health list from the cached counts + live activity
  /// set. Called whenever enrollments reload or the activity stream fires.
  void _rebuildClassHealth() {
    classHealth.assignAll(_rooms.map((cls) {
      final id = cls.key ?? '';
      return ClassHealthData(
        classroomId: id,
        name: cls.name,
        capacity: cls.capacity,
        enrolled: _enrolledByRoom[id] ?? 0,
        pending: _pendingByRoom[id] ?? 0,
        hasTeacher: (cls.teacherId ?? '').isNotEmpty,
        teacherName: _teacherNames[cls.teacherId] ?? '',
        hasActiveActivity: _activeClassroomIds.contains(id),
      );
    }).toList()
      ..sort((a, b) {
        // Live classes first (manager wants to see what's running now),
        // then classes needing attention, then by how full they are.
        if (a.hasActiveActivity != b.hasActiveActivity) {
          return a.hasActiveActivity ? -1 : 1;
        }
        if (a.hasIssue != b.hasIssue) return a.hasIssue ? -1 : 1;
        return b.fillRate.compareTo(a.fillRate);
      }));

    final totalCap = classHealth.fold<int>(0, (acc, c) => acc + (c.capacity ?? 0));
    final totalEnrolled = classHealth.fold<int>(0, (acc, c) => acc + c.enrolled);
    occupancyRate.value =
        totalCap > 0 ? ((totalEnrolled / totalCap) * 100).round() : 0;
  }

  /// History-only load: the long-absence signal spans many days, so it still
  /// reads the full attendance set once per refresh. Today's presence is no
  /// longer computed here — it flows live through [_recomputePresence].
  Future<void> _loadAttendance() async {
    await _attendanceSvc.getAll(callBack: (list) {
      // Scope by the branch roster (childId) rather than the record's stored
      // branchId. A teacher check-in can land with an empty branchId (their
      // staff record may lack one), so filtering on the record's branch would
      // silently drop those present children. Roster membership is the
      // authoritative branch scope and a child belongs to exactly one branch.
      final records = list
          .whereType<ChildAttendanceModel>()
          .where((a) => _branchChildKeys.contains(a.childId))
          .toList();
      _buildLongAbsence(records);
    });
  }

  /// Live presence stream — one write to childAttendance re-emits the whole
  /// day, so the overview's present/inside/left figures update without a
  /// refresh. Recompute is roster-dependent, so it also runs at the end of
  /// [loadData] once the branch roster is known.
  void _subscribePresence() {
    _presenceSub?.cancel();
    _presenceSub =
        _statusSvc.watchAttendanceForDay(_nurseryId).listen((records) {
      _todayAttendance = records;
      _recomputePresence();
    }, onError: (_) {});
  }

  void _recomputePresence() {
    final today = _todayAttendance
        .where((a) =>
            _branchChildKeys.contains(a.childId) &&
            (a.status == 'present' || a.status == 'late'))
        .toList();
    final checkedOut = today.where((a) => a.checkOutTime != null).length;
    presentNow.value = (today.length - checkedOut).clamp(0, today.length);
    _buildPresence(today);
  }

  Future<void> _loadRiskSources() async {
    await Future.wait([
      _noteSvc.getAll(callBack: (list) {
        for (final n in list.whereType<NoteModel>()) {
          if (n.category == 'needs_follow' &&
              n.childId != null &&
              _branchChildKeys.contains(n.childId)) {
            _addRisk(n.childId!, 'manager_children_risk_followup');
          }
        }
      }),
      _incidentSvc.getAll(callBack: (list) {
        for (final i in list.whereType<IncidentModel>()) {
          if (i.severity == 'high' &&
              i.childId != null &&
              _branchChildKeys.contains(i.childId)) {
            _addRisk(i.childId!, 'manager_children_risk_incident');
          }
        }
      }),
      _assessmentSvc.getAll(callBack: (list) {
        for (final a in list.whereType<AssessmentModel>()) {
          if (a.level == 'needs_improvement' &&
              _branchChildKeys.contains(a.childId)) {
            _addRisk(a.childId, 'manager_children_risk_assessment');
          }
        }
      }),
    ]);
  }

  Future<void> _loadOverdueFamilies() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    late List<InvoiceModel> overdue;
    final names = <String, String>{};
    // Invoices and guardian names are independent — fetch together.
    await Future.wait([
      _invoiceSvc.getAll(callBack: (list) {
        overdue = list
            .whereType<InvoiceModel>()
            .where((inv) => _branchChildKeys.contains(inv.childId))
            .where((inv) =>
                inv.hasOutstanding &&
                (inv.status == 'overdue' ||
                    (inv.dueDate != null && inv.dueDate! < now)))
            .toList();
      }),
      _guardianSvc.getAll(callBack: (list) {
        names.addEntries(
            list.whereType<ParentModel>().map((p) => MapEntry(p.uid, p.name)));
      }),
    ]);

    final byParent = <String, List<InvoiceModel>>{};
    for (final inv in overdue) {
      final pid = inv.parentId ?? '';
      if (pid.isEmpty) continue;
      byParent.putIfAbsent(pid, () => []).add(inv);
    }

    overdueFamilies.assignAll(byParent.entries.map((e) {
      final total = e.value.fold<double>(0, (s, inv) => s + inv.remaining);
      return OverdueFamilyData(
        parentId: e.key,
        parentName: names[e.key] ?? 'manager_children_unknown_family'.tr,
        invoiceCount: e.value.length,
        totalAmount: total,
      );
    }).toList()
      ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount)));
  }

  /// Splits today's present/late records into who is still on-site vs. who has
  /// already been picked up, newest action first within each group.
  void _buildPresence(List<ChildAttendanceModel> today) {
    final inside = <PresenceEntry>[];
    final left = <PresenceEntry>[];
    for (final a in today) {
      final entry = PresenceEntry(
        childId: a.childId,
        name: _childNames[a.childId] ?? 'manager_children_unknown_child'.tr,
        classroomName: classroomName(_childClassroom[a.childId]),
        imageUrl: _childImages[a.childId],
        checkInMs: a.checkInTime,
        checkOutMs: a.checkOutTime,
      );
      (a.checkOutTime != null ? left : inside).add(entry);
    }
    inside.sort((a, b) => (b.checkInMs ?? 0).compareTo(a.checkInMs ?? 0));
    left.sort((a, b) => (b.checkOutMs ?? 0).compareTo(a.checkOutMs ?? 0));
    insideNow.assignAll(inside);
    leftToday.assignAll(left);
  }

  void _buildLongAbsence(List<ChildAttendanceModel> records) {
    final lastPresent = <String, DateTime>{};
    for (final a in records) {
      if (a.status != 'present' && a.status != 'late') continue;
      final d = _parseDate(a.date);
      if (d == null) continue;
      final cur = lastPresent[a.childId];
      if (cur == null || d.isAfter(cur)) lastPresent[a.childId] = d;
    }

    final today = DateTime.now();
    final result = <LongAbsenceData>[];
    for (final childId in _branchChildKeys) {
      final last = lastPresent[childId];
      if (last == null) continue; // no history → skip (avoid false positives)
      final days = DateTime(today.year, today.month, today.day)
          .difference(DateTime(last.year, last.month, last.day))
          .inDays;
      if (days >= longAbsenceThresholdDays) {
        result.add(LongAbsenceData(
          childId: childId,
          name: _childNames[childId] ?? '',
          classroomName: classroomName(_childClassroom[childId]),
          days: days,
        ));
      }
    }
    result.sort((a, b) => b.days.compareTo(a.days));
    longAbsence.assignAll(result);
  }

  void _buildRiskChildren() {
    final result = _riskReasons.entries.map((e) {
      return ChildRiskData(
        childId: e.key,
        name: _childNames[e.key] ?? '',
        classroomName: classroomName(_childClassroom[e.key]),
        reasonKeys: e.value.toList(),
      );
    }).toList()
      ..sort((a, b) => b.severity.compareTo(a.severity));
    riskChildren.assignAll(result);
  }

  void _filter() {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) {
      filteredDirectory.assignAll(directory);
      return;
    }
    filteredDirectory.assignAll(
        directory.where((c) => c.fullName.toLowerCase().contains(q)));
  }

  void _addRisk(String childId, String reasonKey) =>
      _riskReasons.putIfAbsent(childId, () => <String>{}).add(reasonKey);

  List<ClassroomModel> _rooms = const [];

  DateTime? _parseDate(String value) {
    final p = value.split('-');
    if (p.length != 3) return null;
    final y = int.tryParse(p[0]);
    final m = int.tryParse(p[1]);
    final d = int.tryParse(p[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }
}

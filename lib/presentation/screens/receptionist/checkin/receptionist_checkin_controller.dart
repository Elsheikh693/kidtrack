import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';
import '../../../../Data/models/child_current_status/child_current_status_model.dart';
import '../../../../Global/services/child_status_service.dart';

class CheckInChildEntry {
  final ChildModel child;
  final ChildCurrentStatusModel? currentStatus;

  const CheckInChildEntry({required this.child, this.currentStatus});

  // Status is only valid if it was set today. Yesterday's data = not arrived.
  bool get _isToday {
    if (currentStatus == null) return false;
    final updated = currentStatus!.updatedAt;
    final now = DateTime.now();
    return updated.year == now.year &&
        updated.month == now.month &&
        updated.day == now.day;
  }

  String get _effectiveStatus {
    if (!_isToday) return ChildStatus.notArrived;
    return currentStatus?.status ?? ChildStatus.notArrived;
  }

  bool get isPresent =>
      _isToday &&
      currentStatus != null &&
      currentStatus!.status != ChildStatus.notArrived &&
      currentStatus!.status != ChildStatus.checkedOut;

  // انصرف اليوم فعلاً (مش مجرد بيانات قديمة من يوم تاني)
  bool get isCheckedOutToday =>
      _isToday && currentStatus?.status == ChildStatus.checkedOut;

  String get statusLabel {
    switch (_effectiveStatus) {
      case ChildStatus.checkedIn:    return 'programssu27_status_checked_in'.tr;
      case ChildStatus.havingMeal:   return 'programssu27_status_having_meal'.tr;
      case ChildStatus.sleeping:     return 'programssu27_status_sleeping'.tr;
      case ChildStatus.onBus:        return 'programssu27_status_on_bus'.tr;
      case ChildStatus.checkedOut:   return 'programssu27_status_checked_out'.tr;
      default:                       return 'programssu27_status_not_arrived'.tr;
    }
  }

  Color get statusColor {
    switch (_effectiveStatus) {
      case ChildStatus.checkedIn:    return const Color(0xFF059669);
      case ChildStatus.havingMeal:   return const Color(0xFFDC2626);
      case ChildStatus.sleeping:     return const Color(0xFF7C3AED);
      case ChildStatus.onBus:        return const Color(0xFFD97706);
      case ChildStatus.checkedOut:   return const Color(0xFF64748B);
      default:                       return const Color(0xFF94A3B8);
    }
  }

  IconData get statusIcon {
    switch (_effectiveStatus) {
      case ChildStatus.checkedIn:    return Icons.home_work_rounded;
      case ChildStatus.havingMeal:   return Icons.restaurant_rounded;
      case ChildStatus.sleeping:     return Icons.bedtime_rounded;
      case ChildStatus.onBus:        return Icons.directions_bus_rounded;
      case ChildStatus.checkedOut:   return Icons.logout_rounded;
      default:                       return Icons.schedule_rounded;
    }
  }
}

class ReceptionistCheckInController extends GetxController {
  final _db = FirebaseDatabase.instance;
  final _statusSvc = ChildStatusService();
  late final SessionService _session;
  late final AuthorizedPickupParentService _pickupSvc;

  // Valid authorized-pickup persons grouped by childId, for the per-child badge.
  final _pickupsByChild = <String, List<AuthorizedPickupModel>>{};

  final children = <CheckInChildEntry>[].obs;
  final isLoading = true.obs;
  final searchQuery = ''.obs;
  final filterStatus = 'all'.obs; // all | present | absent

  final Map<String, StreamSubscription<ChildCurrentStatusModel?>> _subs = {};
  final _statuses = <String, ChildCurrentStatusModel?>{};
  List<ChildModel> _allChildren = [];

  @override
  void onInit() {
    super.onInit();
    _session = SessionService();
    _pickupSvc = Get.find<AuthorizedPickupParentService>();
    _loadChildren();
  }

  Future<void> _loadPickups() async {
    await _pickupSvc.getAll(callBack: (list) {
      final map = <String, List<AuthorizedPickupModel>>{};
      for (final p in list.whereType<AuthorizedPickupModel>()) {
        if (!p.isCurrentlyValid) continue;
        map.putIfAbsent(p.childId, () => []).add(p);
      }
      _pickupsByChild
        ..clear()
        ..addAll(map);
    });
    _rebuild();
  }

  /// Valid authorized-pickup persons for a child (empty if none registered).
  List<AuthorizedPickupModel> pickupsFor(String? childId) =>
      childId == null ? const [] : (_pickupsByChild[childId] ?? const []);

  @override
  void onClose() {
    for (final sub in _subs.values) {
      sub.cancel();
    }
    _subs.clear();
    super.onClose();
  }

  Future<void> _loadChildren() async {
    isLoading.value = true;
    final nurseryId = _session.nurseryId ?? '';
    final branchId = _session.branchId ?? '';
    if (nurseryId.isEmpty || branchId.isEmpty) {
      isLoading.value = false;
      return;
    }

    try {
      // Read the whole children node and filter client-side (branch + active),
      // mirroring the receptionist dashboard. Avoids depending on a deployed
      // `.indexOn: branchId` rule, whose absence would throw and silently empty
      // the list.
      final snap = await _db.ref('platform/$nurseryId/children').get();

      if (snap.exists && snap.value != null) {
        final map = Map<String, dynamic>.from(snap.value as Map);
        _allChildren = map.entries
            .where((e) => e.value is Map)
            .map((e) => ChildModel.fromJson(
                Map<String, dynamic>.from(e.value as Map),
                key: e.key))
            .where((c) => c.branchId == branchId && c.status == 'active')
            .toList()
          ..sort((a, b) => a.fullName.compareTo(b.fullName));
      }
    } catch (e) {
      AppLogger.error('CHECKIN', 'loadChildren: $e');
    }

    // Subscribe to each child's live status.
    final nurseryId2 = _session.nurseryId ?? '';
    for (final child in _allChildren) {
      final id = child.key!;
      _statuses[id] = null;
      _subs[id] = _statusSvc.watchStatus(nurseryId2, id).listen((s) {
        _statuses[id] = s;
        _rebuild();
      });
    }

    isLoading.value = false;
    _rebuild();

    // Load authorized-pickup persons in the background; the list rebuilds once
    // ready so each child card can show its badge.
    _loadPickups();
  }

  void _rebuild() {
    final q = searchQuery.value.toLowerCase();
    final f = filterStatus.value;

    final entries = _allChildren.map((c) {
      return CheckInChildEntry(child: c, currentStatus: _statuses[c.key]);
    }).where((e) {
      if (q.isNotEmpty && !e.child.fullName.toLowerCase().contains(q)) {
        return false;
      }
      if (f == 'present' && !e.isPresent) return false;
      if (f == 'absent' && (e.isPresent || e.isCheckedOutToday)) return false;
      return true;
    }).toList();

    children.assignAll(entries);
  }

  void setSearch(String q) {
    searchQuery.value = q;
    _rebuild();
  }

  void setFilter(String f) {
    filterStatus.value = f;
    _rebuild();
  }

  // ── Actions ──────────────────────────────────────────────────────────────────

  Future<void> checkIn(CheckInChildEntry entry) async {
    final nurseryId = _session.nurseryId ?? '';
    final branchId = _session.branchId ?? '';
    final uid = _session.userId ?? '';
    final childId = entry.child.key!;
    if (nurseryId.isEmpty || uid.isEmpty) return;

    Loader.show();
    final ok = await _statusSvc.checkInChild(
      nurseryId: nurseryId,
      branchId: branchId,
      childId: childId,
      receptionistId: uid,
    );
    Loader.dismiss();

    if (!ok) Loader.showError('checkin_error_failed'.tr);
    // Stream update will trigger _rebuild automatically.
  }

  Future<void> checkOut(CheckInChildEntry entry) async {
    final nurseryId = _session.nurseryId ?? '';
    final branchId = _session.branchId ?? '';
    final uid = _session.userId ?? '';
    final childId = entry.child.key!;
    final current = entry.currentStatus;
    if (nurseryId.isEmpty || uid.isEmpty || current == null) return;

    Loader.show();
    final ok = await _statusSvc.checkOutChild(
      nurseryId: nurseryId,
      branchId: branchId,
      childId: childId,
      receptionistId: uid,
      current: current,
    );
    Loader.dismiss();

    if (!ok) Loader.showError('checkin_error_failed'.tr);
  }

  // ── Summary ──────────────────────────────────────────────────────────────────

  int get totalCount => _allChildren.length;
  int get presentCount =>
      _allChildren.where((c) => CheckInChildEntry(
            child: c,
            currentStatus: _statuses[c.key],
          ).isPresent).length;
  int get absentCount =>
      _allChildren.where((c) {
        final e = CheckInChildEntry(child: c, currentStatus: _statuses[c.key]);
        return !e.isPresent && !e.isCheckedOutToday;
      }).length;
}

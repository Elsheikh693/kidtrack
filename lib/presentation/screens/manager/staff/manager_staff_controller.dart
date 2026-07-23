import '../../../../index/index_main.dart';
import 'models/coverage_gap_data.dart';
import 'models/pending_leave_data.dart';
import 'models/salary_band_data.dart';
import 'models/staff_signal_data.dart';

class ManagerStaffController extends GetxController {
  // ─── Overview KPIs ──────────────────────────────────────────────────────
  final totalStaff = 0.obs;
  final presentToday = 0.obs;
  final onLeaveToday = 0.obs;
  final coverageGapCount = 0.obs;

  // ─── Workforce Signals (problems first) ─────────────────────────────────
  final absentToday = <StaffSignalData>[].obs;
  final unassignedTeachers = <StaffSignalData>[].obs;
  final pendingLeaves = <PendingLeaveData>[].obs;
  final coverageGaps = <CoverageGapData>[].obs;

  // ─── Salary Center ──────────────────────────────────────────────────────
  final totalPayroll = 0.0.obs;
  final missingSalaryCount = 0.obs;
  final salaryBands = <SalaryBandData>[].obs;

  // ─── Directory ──────────────────────────────────────────────────────────
  final directory = <StaffModel>[].obs;
  final filteredDirectory = <StaffModel>[].obs;
  final searchQuery = ''.obs;
  final roleFilter = Rxn<StaffTemplate>();
  final roleOptions = <StaffTemplate>[].obs;

  final isLoading = true.obs;

  late final StaffParentService _staffSvc;
  late final StaffAttendanceParentService _attendanceSvc;
  late final StaffLeaveParentService _leaveSvc;
  late final ClassroomParentService _classroomSvc;

  late Worker _searchWorker;

  final _session = SessionService();
  final _staffNames = <String, String>{};
  final _staffRoleKey = <String, String>{};
  final _branchStaffKeys = <String>{};
  final _todayStatus = <String, String>{};

  String get branchId => _session.branchId ?? '';

  static String get _todayStr {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }

  bool get hasSignals =>
      absentToday.isNotEmpty ||
      pendingLeaves.isNotEmpty ||
      coverageGaps.isNotEmpty ||
      unassignedTeachers.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _staffSvc = Get.find<StaffParentService>();
    _attendanceSvc = Get.find<StaffAttendanceParentService>();
    _leaveSvc = Get.find<StaffLeaveParentService>();
    _classroomSvc = Get.find<ClassroomParentService>();
    _searchWorker = debounce(
      searchQuery,
      (_) => _filter(),
      time: const Duration(milliseconds: 300),
    );
    loadData();
  }

  @override
  void onClose() {
    _searchWorker.dispose();
    super.onClose();
  }

  String roleLabelKey(String staffId) =>
      _staffRoleKey[staffId] ?? StaffTemplate.teacher.labelKey;

  String attendanceStatus(String staffId) => _todayStatus[staffId] ?? '';

  void onSearch(String value) => searchQuery.value = value;

  void onRoleFilter(StaffTemplate? template) {
    roleFilter.value = template;
    _filter();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      // Classrooms is independent. The staff → leaves → attendance chain stays
      // ordered (attendance reads the approved-leave set built in leaves), but
      // runs in parallel with the classrooms fetch.
      await Future.wait([
        _loadStaff().then((_) async {
          await _loadLeaves();
          await _loadAttendance();
        }),
        _loadClassrooms(),
      ]);
      _filter();
    } finally {
      // Never leave the loader stuck if any step throws.
      isLoading.value = false;
    }
  }

  Future<void> _loadStaff() async {
    await _staffSvc.getAll(callBack: (list) {
      final branch = list
          .whereType<StaffModel>()
          .where((s) =>
              s.branchId == branchId &&
              s.isActive &&
              _session.seesAnyShift(s.shiftIds))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));

      _staffNames
        ..clear()
        ..addEntries(branch
            .where((s) => s.key != null)
            .map((s) => MapEntry(s.key!, s.name)));
      _staffRoleKey
        ..clear()
        ..addEntries(branch
            .where((s) => s.key != null)
            .map((s) => MapEntry(s.key!, s.template.labelKey)));
      _branchStaffKeys
        ..clear()
        ..addAll(branch.where((s) => s.key != null).map((s) => s.key!));

      totalStaff.value = branch.length;
      unassignedTeachers.assignAll(branch
          .where((s) =>
              s.template == StaffTemplate.teacher &&
              (s.classroomId == null || s.classroomId!.isEmpty))
          .map((s) => StaffSignalData(
                staffId: s.key ?? '',
                name: s.name,
                roleKey: s.template.labelKey,
              )));

      _buildSalary(branch);
      directory.assignAll(branch);
      roleOptions.assignAll(
          branch.map((s) => s.template).toSet().toList()
            ..sort((a, b) => a.index.compareTo(b.index)));
    });
  }

  void _buildSalary(List<StaffModel> branch) {
    final withSalary =
        branch.where((s) => s.salary != null && s.salary! > 0).toList();
    totalPayroll.value =
        withSalary.fold<double>(0, (acc, s) => acc + s.salary!);
    missingSalaryCount.value = branch.length - withSalary.length;

    final byRole = <StaffTemplate, List<StaffModel>>{};
    for (final s in withSalary) {
      byRole.putIfAbsent(s.template, () => []).add(s);
    }
    salaryBands.assignAll(byRole.entries.map((e) {
      final total = e.value.fold<double>(0, (acc, s) => acc + s.salary!);
      return SalaryBandData(
        roleKey: e.key.labelKey,
        count: e.value.length,
        total: total,
      );
    }).toList()
      ..sort((a, b) => b.total.compareTo(a.total)));
  }

  Future<void> _loadClassrooms() async {
    await _classroomSvc.getAll(callBack: (list) {
      final gaps = list
          .whereType<ClassroomModel>()
          .where((c) => (c.isAllBranches || c.branchIds.contains(branchId)) && c.isActive)
          .where((c) => (c.teacherId ?? '').isEmpty)
          .map((c) => CoverageGapData(classroomId: c.key ?? '', name: c.name))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name));
      coverageGaps.assignAll(gaps);
      coverageGapCount.value = gaps.length;
    });
  }

  Future<void> _loadLeaves() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    final todayEnd =
        todayStart + const Duration(days: 1).inMilliseconds - 1;
    _approvedLeaveToday.clear();

    await _leaveSvc.getAll(callBack: (list) {
      final mine = list
          .whereType<StaffLeaveModel>()
          .where((l) => _branchStaffKeys.contains(l.staffId))
          .toList();

      for (final l in mine) {
        if (l.status == 'approved' &&
            l.startDate <= todayEnd &&
            l.endDate >= todayStart) {
          _approvedLeaveToday.add(l.staffId);
        }
      }

      final pending = mine.where((l) => l.status == 'pending').toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));
      pendingLeaves.assignAll(pending.map((l) {
        final days = ((l.endDate - l.startDate) / 86400000).floor() + 1;
        return PendingLeaveData(
          leaveId: l.key ?? '',
          staffId: l.staffId,
          staffName: _staffNames[l.staffId] ?? '',
          roleKey: roleLabelKey(l.staffId),
          typeKey: 'manager_staff_leave_${l.type}',
          startDate: l.startDate,
          endDate: l.endDate,
          days: days < 1 ? 1 : days,
        );
      }));
    });
  }

  Future<void> _loadAttendance() async {
    _todayStatus.clear();
    await _attendanceSvc.getAll(callBack: (list) {
      final today = list
          .whereType<StaffAttendanceModel>()
          .where((a) => a.branchId == branchId && a.date == _todayStr)
          .toList();

      for (final a in today) {
        _todayStatus[a.staffId] = a.status;
      }

      presentToday.value = today
          .where((a) => a.status == 'present' || a.status == 'late')
          .length;

      final onLeave = <String>{..._approvedLeaveToday};
      for (final a in today) {
        if (a.status == 'on_leave') onLeave.add(a.staffId);
      }
      onLeaveToday.value = onLeave.length;

      absentToday.assignAll(today
          .where((a) =>
              a.status == 'absent' && !_approvedLeaveToday.contains(a.staffId))
          .map((a) => StaffSignalData(
                staffId: a.staffId,
                name: _staffNames[a.staffId] ?? '',
                roleKey: roleLabelKey(a.staffId),
              ))
          .toList()
        ..sort((a, b) => a.name.compareTo(b.name)));
    });
  }

  void _filter() {
    final q = searchQuery.value.trim().toLowerCase();
    final role = roleFilter.value;
    filteredDirectory.assignAll(directory.where((s) {
      final matchesRole = role == null || s.template == role;
      final matchesQuery = q.isEmpty || s.name.toLowerCase().contains(q);
      return matchesRole && matchesQuery;
    }));
  }

  final _approvedLeaveToday = <String>{};
}

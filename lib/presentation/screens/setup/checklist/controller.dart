import 'package:firebase_database/firebase_database.dart';
import '../../../../index/index_main.dart';
import 'models/setup_step.dart';
import 'models/setup_group.dart';

/// First-login "checklist hub" for owners and branch managers.
///
/// Instead of a rigid step-by-step wizard, this presents every required setup
/// task as a card that opens the real management screen. Completion is probed
/// from live data on return, and the flow is only marked finished
/// (`users/{uid}/setupDone`) once every task has data.
class SetupChecklistController extends GetxController {
  final isLoading = true.obs;
  final groups = <SetupGroup>[].obs;
  final doneIds = <String>{}.obs;

  late final BranchParentService _branchService;
  late final NurseryContactParentService _contactService;
  late final StaffParentService _staffService;
  late final ShiftParentService _shiftService;
  late final ProgramParentService _programService;
  late final ClassroomParentService _classroomService;
  late final SubjectParentService _subjectService;
  late final PackageParentService _packageService;
  late final SessionService _session;

  @override
  void onInit() {
    super.onInit();
    _branchService = Get.find<BranchParentService>();
    _contactService = Get.find<NurseryContactParentService>();
    _staffService = Get.find<StaffParentService>();
    _shiftService = Get.find<ShiftParentService>();
    _programService = Get.find<ProgramParentService>();
    _classroomService = Get.find<ClassroomParentService>();
    _subjectService = Get.find<SubjectParentService>();
    _packageService = Get.find<PackageParentService>();
    _session = Get.find<SessionService>();
    _buildGroups();
    recompute();
  }

  // ── Computed ────────────────────────────────────────────────────────────────

  bool get _isOwner => _session.userType == UserType.owner;

  bool isDone(String id) => doneIds.contains(id);

  int get totalCount => groups.fold(0, (n, g) => n + g.steps.length);

  int get doneCount =>
      groups.fold(0, (n, g) => n + g.steps.where((s) => isDone(s.id)).length);

  double get progress => totalCount == 0 ? 0 : doneCount / totalCount;

  bool get allDone => totalCount > 0 && doneCount >= totalCount;

  // ── Structure ───────────────────────────────────────────────────────────────

  void _buildGroups() {
    groups.value = [
      SetupGroup(
        titleKey: 'setup_hub_group_branches',
        steps: [
          _stepBranches,
          _stepContacts,
          _stepStaff,
          _stepShifts,
        ],
      ),
      SetupGroup(
        titleKey: 'setup_hub_group_education',
        steps: [_stepPrograms, _stepClassrooms, _stepSubjects],
      ),
      SetupGroup(
        titleKey: 'setup_hub_group_finance',
        steps: [_stepPackages],
      ),
    ];
  }

  SetupStep get _stepBranches => const SetupStep(
        id: 'branches',
        titleKey: 'setup_hub_step_branches_title',
        subtitleKey: 'setup_hub_step_branches_sub',
        icon: Icons.account_tree_rounded,
        route: branchesView,
      );

  SetupStep get _stepContacts => const SetupStep(
        id: 'contacts',
        titleKey: 'setup_hub_step_contacts_title',
        subtitleKey: 'setup_hub_step_contacts_sub',
        icon: Icons.contact_phone_rounded,
        route: nurseryContactsView,
      );

  SetupStep get _stepStaff => const SetupStep(
        id: 'staff',
        titleKey: 'setup_hub_step_staff_title',
        subtitleKey: 'setup_hub_step_staff_sub',
        icon: Icons.groups_rounded,
        route: staffView,
      );

  SetupStep get _stepShifts => const SetupStep(
        id: 'shifts',
        titleKey: 'setup_hub_step_shifts_title',
        subtitleKey: 'setup_hub_step_shifts_sub',
        icon: Icons.schedule_rounded,
        route: shiftsView,
      );

  SetupStep get _stepPrograms => const SetupStep(
        id: 'programs',
        titleKey: 'setup_hub_step_programs_title',
        subtitleKey: 'setup_hub_step_programs_sub',
        icon: Icons.school_rounded,
        route: programsView,
      );

  SetupStep get _stepClassrooms => const SetupStep(
        id: 'classrooms',
        titleKey: 'setup_hub_step_classrooms_title',
        subtitleKey: 'setup_hub_step_classrooms_sub',
        icon: Icons.meeting_room_rounded,
        route: classroomsView,
      );

  SetupStep get _stepSubjects => const SetupStep(
        id: 'subjects',
        titleKey: 'setup_hub_step_subjects_title',
        subtitleKey: 'setup_hub_step_subjects_sub',
        icon: Icons.menu_book_rounded,
        route: subjectsView,
      );

  SetupStep get _stepPackages => const SetupStep(
        id: 'packages',
        titleKey: 'setup_hub_step_packages_title',
        subtitleKey: 'setup_hub_step_packages_sub',
        icon: Icons.payments_rounded,
        route: nurseryPackagesView,
      );

  // ── Navigation ──────────────────────────────────────────────────────────────

  /// Opens a task's management screen, then re-probes completion on return so
  /// the card flips to "done" as soon as the manager adds the first record.
  Future<void> openStep(SetupStep step) async {
    await Get.toNamed(step.route);
    await recompute();
  }

  // ── Completion probes ─────────────────────────────────────────────────────────

  Future<void> recompute() async {
    final done = <String>{};
    final branchId = _session.branchId ?? '';

    // Each probe only needs to know whether a collection has ≥1 record, and none
    // depend on another's result — so fire them all at once instead of awaiting
    // seven round-trips in series. Callbacks mutate `done` on the single UI
    // isolate, so there's no race. Total wait ≈ the slowest single probe.
    await Future.wait([
      // Probes below carry `limit: 1` when the whole result is only tested for
      // existence (or just its first row) with NO further client-side filtering
      // — so they fetch a single row, not the collection. Staff (always filtered
      // by role) and packages/staff for a non-owner (filtered by branch) fetch in
      // full, since a trimmed row might not match the filter.
      _branchService.getAll(limit: 1, callBack: (list) {
        if (list.whereType<BranchModel>().isNotEmpty) done.add('branches');
      }),
      _contactService.getAll(callBack: (list) {
        if (list.whereType<NurseryContactModel>().isNotEmpty) {
          done.add('contacts');
        }
      }),
      _staffService.getAll(callBack: (list) {
        final staff = list.whereType<StaffModel>().where(
              (s) =>
                  s.role != UserType.owner && s.role != UserType.branchManager,
            );
        final scoped = _isOwner
            ? staff
            : staff.where((s) => branchId.isEmpty || s.branchId == branchId);
        if (scoped.isNotEmpty) done.add('staff');
      }),
      _shiftService.getAll(callBack: (list) {
        if (list.whereType<ShiftModel>().isNotEmpty) done.add('shifts');
      }),
      _programService.getAll(limit: 1, callBack: (list) {
        if (list.whereType<ProgramModel>().isNotEmpty) done.add('programs');
      }),
      _classroomService.getAll(limit: 1, callBack: (list) {
        if (list.whereType<ClassroomModel>().isNotEmpty) done.add('classrooms');
      }),
      _subjectService.getAll(limit: 1, callBack: (list) {
        if (list.whereType<SubjectModel>().isNotEmpty) done.add('subjects');
      }),
      _packageService.getAll(
        limit: _isOwner ? 1 : null,
        callBack: (list) {
          final pkgs = list.whereType<PackageModel>();
          final scoped = _isOwner
              ? pkgs
              : pkgs.where((p) => branchId.isEmpty || p.branchId == branchId);
          if (scoped.isNotEmpty) done.add('packages');
        },
      ),
    ]);

    doneIds.assignAll(done);
    isLoading.value = false;
  }

  // ── Complete ────────────────────────────────────────────────────────────────

  Future<void> finish() async {
    if (!allDone) {
      Loader.showError('setup_hub_incomplete'.tr);
      return;
    }
    Loader.show();
    try {
      final uid = _session.userId ?? '';
      await FirebaseDatabase.instance
          .ref('users/$uid')
          .update({'setupDone': true});
      await SetupLocalCheck.markDone(uid);
      Loader.dismiss();
      Get.offAllNamed(mainView);
    } catch (_) {
      Loader.showError('common_error'.tr);
    }
  }
}

import '../../../../index/index_main.dart';

class BusAssignmentController extends GetxController {
  final _session = SessionService();
  final _staffService = StaffParentService();
  final _childService = ChildParentService();

  final isLoading = true.obs;
  final isSaving = false.obs;

  final chaperones = <StaffModel>[].obs;
  final selectedChaperone = Rxn<StaffModel>();

  final _allChildren = <ChildModel>[];
  final children = <ChildModel>[].obs;

  // childKey -> assigned to the currently selected chaperone
  final assigned = <String, bool>{}.obs;

  String get branchId => _session.branchId ?? '';

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    await Future.wait([_loadChaperones(), _loadChildren()]);
    if (chaperones.isNotEmpty) {
      selectChaperone(chaperones.first);
    }
    isLoading.value = false;
  }

  Future<void> _loadChaperones() async {
    final completer = Completer<List<StaffModel?>>();
    await _staffService.getAll(callBack: completer.complete);
    final all = await completer.future;
    chaperones.assignAll(
      all.whereType<StaffModel>().where(
            (s) =>
                s.role == UserType.busChaperone &&
                s.isActive &&
                s.branchId == branchId,
          ),
    );
  }

  Future<void> _loadChildren() async {
    final completer = Completer<List<ChildModel?>>();
    await _childService.getAll(callBack: completer.complete);
    final all = await completer.future;
    _allChildren
      ..clear()
      ..addAll(
        all.whereType<ChildModel>().where((c) => c.branchId == branchId),
      );
    children.assignAll(_allChildren);
  }

  void selectChaperone(StaffModel staff) {
    selectedChaperone.value = staff;
    final map = <String, bool>{};
    for (final c in _allChildren) {
      map[c.key ?? ''] = c.busChaperoneId == staff.uid;
    }
    assigned.assignAll(map);
  }

  void toggle(ChildModel child) {
    final key = child.key ?? '';
    assigned[key] = !(assigned[key] ?? false);
    assigned.refresh();
  }

  int get assignedCount => assigned.values.where((v) => v).length;

  Future<void> save() async {
    final staff = selectedChaperone.value;
    if (staff == null) {
      Loader.showError('bus_assign_pick_chaperone'.tr);
      return;
    }
    isSaving.value = true;
    Loader.show();
    for (final child in _allChildren) {
      final key = child.key ?? '';
      final wantAssigned = assigned[key] ?? false;
      final isAssignedToThis = child.busChaperoneId == staff.uid;

      if (wantAssigned && !isAssignedToThis) {
        await _update(child.copyWith(busChaperoneId: staff.uid));
      } else if (!wantAssigned && isAssignedToThis) {
        await _update(child.copyWith(clearBusChaperone: true));
      }
    }
    await _loadChildren();
    selectChaperone(staff);
    isSaving.value = false;
    Loader.showSuccess('bus_assign_saved'.tr);
  }

  Future<void> _update(ChildModel child) async {
    final completer = Completer<ResponseStatus>();
    await _childService.update(item: child, callBack: completer.complete);
    await completer.future;
  }
}

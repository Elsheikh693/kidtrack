import '../../../../index/index_main.dart';

class ChildListController extends GetxController {
  late final ChildParentService _service;
  late final BranchParentService _branchService;
  late final ClassroomParentService _classroomService;
  late final ParentChildParentService _linkService;
  late final GuardianParentService _guardianService;

  final _session = SessionService();

  final RxList<ChildModel> items = <ChildModel>[].obs;
  final RxList<ChildModel> _all = <ChildModel>[].obs;
  final RxMap<String, String> branchNames = <String, String>{}.obs;
  final RxMap<String, String> classroomNames = <String, String>{}.obs;
  final RxMap<String, String> parentNames = <String, String>{}.obs;
  final RxMap<String, String> parentIds = <String, String>{}.obs;
  final RxMap<String, int> parentCounts = <String, int>{}.obs;
  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;

  // Live nursery↔parent conversations (per child) for the chat entry point on
  // each card: drives the unread badge and lets staff message the guardian.
  final _chatService = ChatService();
  final RxMap<String, ChatConversationModel> chatConvos =
      <String, ChatConversationModel>{}.obs;
  StreamSubscription<List<ChatConversationModel>>? _convoSub;

  // null = all shifts; 'morning' | 'between' | 'evening'
  final RxnString selectedShift = RxnString();
  // 'all' | 'active' | 'inactive'
  final RxString statusFilter = 'all'.obs;

  final searchCtrl = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _service = Get.find<ChildParentService>();
    _branchService = Get.find<BranchParentService>();
    _classroomService = Get.find<ClassroomParentService>();
    _linkService = Get.find<ParentChildParentService>();
    _guardianService = Get.find<GuardianParentService>();
    loadData();
    _convoSub = _chatService.watchConversations().listen((list) {
      chatConvos.value = {for (final c in list) c.childId: c};
    });
    debounce(
      searchQuery,
      (_) => _filter(),
      time: const Duration(milliseconds: 300),
    );
  }

  int get morningCount =>
      _all.where((c) => c.shift == 'morning').length;
  int get betweenCount =>
      _all.where((c) => c.shift == 'between').length;
  int get eveningCount =>
      _all.where((c) => c.shift == 'evening').length;
  int get activeCount => _all.where((c) => c.status == 'active').length;
  int get inactiveCount => _all.where((c) => c.status != 'active').length;
  int get totalCount => _all.length;

  void setShift(String? shift) {
    selectedShift.value = shift;
    _filter();
  }

  void setStatus(String status) {
    statusFilter.value = status;
    _filter();
  }

  String parentName(String? childId) =>
      childId == null ? '' : (parentNames[childId] ?? '');

  int extraParentCount(String? childId) {
    if (childId == null) return 0;
    final c = parentCounts[childId] ?? 0;
    return c > 1 ? c - 1 : 0;
  }

  @override
  void onClose() {
    _convoSub?.cancel();
    searchCtrl.dispose();
    super.onClose();
  }

  /// Unread messages from the guardian for [childId] (nursery/staff side).
  int chatUnread(String? childId) =>
      childId == null ? 0 : (chatConvos[childId]?.unreadManager ?? 0);

  /// Opens the nursery↔guardian conversation for [child] (staff side).
  Future<void> openChat(ChildModel child) => openStaffChat(
        child: child,
        parentId: parentIds[child.key] ?? child.parentId ?? '',
        parentName: parentName(child.key),
      );

  Future<void> _loadLookups() async {
    await _branchService.getAll(
      callBack: (list) {
        final map = <String, String>{};
        for (final b in list.whereType<BranchModel>()) {
          if (b.key != null) map[b.key!] = b.name;
        }
        branchNames.value = map;
      },
    );
    await _classroomService.getAll(
      callBack: (list) {
        final map = <String, String>{};
        for (final c in list.whereType<ClassroomModel>()) {
          if (c.key != null) map[c.key!] = c.name;
        }
        classroomNames.value = map;
      },
    );
  }

  Future<void> _loadParents() async {
    final parentById = <String, String>{};
    await _guardianService.getAll(
      callBack: (list) {
        for (final p in list.whereType<ParentModel>()) {
          parentById[p.uid] = p.name;
        }
      },
    );
    await _linkService.getAll(
      callBack: (list) {
        final map = <String, String>{};
        final ids = <String, String>{};
        final counts = <String, int>{};
        for (final link in list.whereType<ParentChildModel>()) {
          final name = parentById[link.parentId];
          if (name == null) continue;
          counts[link.childId] = (counts[link.childId] ?? 0) + 1;
          // Primary parent wins; otherwise first one found
          if (link.isPrimary || !map.containsKey(link.childId)) {
            map[link.childId] = name;
            ids[link.childId] = link.parentId;
          }
        }
        parentNames.value = map;
        parentIds.value = ids;
        parentCounts.value = counts;
      },
    );
  }

  Future<void> loadData() async {
    isLoading.value = true;
    await Future.wait([_loadLookups(), _loadParents()]);
    await _service.getAll(
      callBack: (list) {
        final all = list.whereType<ChildModel>().toList();
        _all.value = all.where(_inScope).toList()
          ..sort((a, b) => a.fullName.compareTo(b.fullName));
        _filter();
      },
    );
    isLoading.value = false;
  }

  /// When true, non-active children never enter the roster — a withdrawn child
  /// is hard-deleted server-side, so it can't resurface under any filter.
  /// Reception overrides this to hide any lingering inactive record entirely.
  bool get showActiveOnly => false;

  /// Owner/super-admin see every branch; a branch manager (or receptionist)
  /// only sees their own branch and shift.
  bool _inScope(ChildModel c) {
    if (showActiveOnly && c.status != 'active') return false;
    if (_session.isOwner || _session.isSuperAdmin) return true;
    final bId = _session.branchId;
    if (bId != null && bId.isNotEmpty && c.branchId != bId) return false;
    return _session.seesShift(c.shift);
  }

  void _filter() {
    final q = searchQuery.value.trim().toLowerCase();
    final shift = selectedShift.value;
    final status = statusFilter.value;
    items.value = _all.where((c) {
      if (shift != null && c.shift != shift) return false;
      if (status == 'active' && c.status != 'active') return false;
      if (status == 'inactive' && c.status == 'active') return false;
      if (q.isNotEmpty && !c.fullName.toLowerCase().contains(q)) return false;
      return true;
    }).toList();
  }

  String branchName(String id) => branchNames[id] ?? id;

  String classroomName(String? id) =>
      (id == null || classroomNames[id] == null)
          ? 'child_classroom_none'.tr
          : classroomNames[id]!;

  Future<void> openProfile(ChildModel child) async {
    await Get.toNamed(childProfileView,
        arguments: {'childId': child.key ?? ''});
    // A withdrawal hard-deletes the child server-side, so reload from scratch
    // to drop it from the list (partial lookup refresh wouldn't remove it).
    await loadData();
  }

  // Full-page registration flow (receptionist): add child → parent account.
  Future<void> openAddPage() async {
    await Get.toNamed(addChildView);
    loadData();
  }

  void openAdd(HandleKeyboardService keyboardService, List<String> keys) =>
      _openSheet(null, keyboardService, keys);

  void openEdit(
    ChildModel child,
    HandleKeyboardService keyboardService,
    List<String> keys,
  ) => _openSheet(child, keyboardService, keys);

  void _openSheet(
    ChildModel? child,
    HandleKeyboardService keyboardService,
    List<String> keys,
  ) {
    Get.bottomSheet(
      ChildSheet(initial: child, keyboardService: keyboardService, keys: keys),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
    ).then((_) => loadData());
  }

  Future<void> delete(ChildModel child) async {
    Loader.show();
    await _service.delete(
      id: child.key ?? '',
      callBack: (status) {
        Loader.dismiss();
        if (status == ResponseStatus.success) {
          Loader.showSuccess('child_success_deleted'.tr);
          loadData();
        } else {
          Loader.showError('child_error_failed'.tr);
        }
      },
    );
  }
}

import '../../index/index_main.dart';

/// A single child belonging to the logged-in parent. Used to populate the
/// child switcher (siblings) in the parent dashboard header.
class ActiveChildOption {
  final String id;
  final String name;
  final String classroomId;
  final String branchId;
  final String? gender;
  final String? image;

  const ActiveChildOption({
    required this.id,
    required this.name,
    required this.classroomId,
    required this.branchId,
    this.gender,
    this.image,
  });
}

/// Singleton service that holds the active child's identity for the parent
/// role. Restored from SharedPreferences in [onInit] so the child name is
/// available immediately (before any Firebase fetch), then refreshed in the
/// background by [loadFromFirebase].
///
/// All parent-tab AppBars read [childName] and [childStatus] from here.
class ActiveChildService extends GetxService {
  static const _kChildId     = 'active_child_id';
  static const _kChildName   = 'active_child_name';
  static const _kClassroomId = 'active_classroom_id';
  static const _kBranchId    = 'active_child_branch_id';
  static const _kStatus      = 'active_child_status';

  final childId     = ''.obs;
  final childName   = ''.obs;
  final classroomId = ''.obs;
  final branchId    = ''.obs;

  /// All children belonging to the parent (for the sibling switcher).
  final children = <ActiveChildOption>[].obs;

  /// One of: 'checked_in', 'checked_out', 'on_bus', 'in_activity',
  /// 'having_meal', 'sleeping', 'pickup_requested', 'not_arrived'
  final childStatus = 'not_arrived'.obs;

  /// Live unread messages from the nursery for the active child's conversation.
  /// Drives the chat badge on the parent home card and account menu.
  final chatUnread = 0.obs;

  final _chatService = ChatService();
  StreamSubscription<int>? _unreadSub;

  @override
  void onInit() {
    super.onInit();
    _restoreFromCache();
    _watchUnread(childId.value);
    // Re-point the unread stream whenever the active child switches.
    ever(childId, _watchUnread);
  }

  @override
  void onClose() {
    _unreadSub?.cancel();
    super.onClose();
  }

  void _watchUnread(String id) {
    _unreadSub?.cancel();
    if (id.isEmpty) {
      chatUnread.value = 0;
      return;
    }
    _unreadSub = _chatService
        .watchUnread(id, 'parent')
        .listen((n) => chatUnread.value = n);
  }

  // ── Cache restore (synchronous) ─────────────────────────────────────────────

  void _restoreFromCache() {
    final s = StorageService();
    final id        = s.getData(_kChildId)?['v']     as String?;
    final name      = s.getData(_kChildName)?['v']   as String?;
    final classroom = s.getData(_kClassroomId)?['v'] as String?;
    final branch    = s.getData(_kBranchId)?['v']    as String?;
    final status    = s.getData(_kStatus)?['v']      as String?;
    if (id        != null && id.isNotEmpty)   childId.value     = id;
    if (name      != null && name.isNotEmpty) childName.value   = name;
    if (classroom != null)                    classroomId.value = classroom;
    if (branch    != null && branch.isNotEmpty) branchId.value  = branch;
    if (status    != null)                    childStatus.value = status;
  }

  // ── Firebase refresh ────────────────────────────────────────────────────────

  /// Fetches ALL of the parent's children from Firebase, populates [children]
  /// for the sibling switcher, selects the active one (keeping the previously
  /// active child if still valid, otherwise the first), persists it to cache,
  /// and returns the active child's key (or null on failure).
  Future<String?> loadFromFirebase() async {
    try {
      final parentId = SessionService().userId ?? '';
      if (parentId.isEmpty) return null;

      final parentChildSvc = Get.find<ParentChildParentService>();
      final childSvc       = Get.find<ChildParentService>();

      final myChildIds = <String>{};
      await parentChildSvc.getAll(callBack: (list) {
        for (final pc in list.whereType<ParentChildModel>()) {
          if (pc.parentId == parentId) myChildIds.add(pc.childId);
        }
      });
      if (myChildIds.isEmpty) return null;

      final options = <ActiveChildOption>[];
      await childSvc.getAll(callBack: (list) {
        for (final c in list.whereType<ChildModel>()) {
          if (c.key != null &&
              myChildIds.contains(c.key) &&
              c.status == 'active') {
            options.add(ActiveChildOption(
              id: c.key!,
              name: c.fullName,
              classroomId: c.classroomId ?? '',
              branchId: c.branchId,
              gender: c.gender,
              image: c.profileImage,
            ));
          }
        }
      });

      if (options.isEmpty) return null;

      children.assignAll(options);

      // Keep the currently-active child if it's still one of the parent's
      // children; otherwise default to the first one.
      ActiveChildOption active = options.firstWhere(
        (o) => o.id == childId.value,
        orElse: () => options.first,
      );

      await _applyActive(active);
      return active.id;
    } catch (_) {
      return null;
    }
  }

  /// Switches the active child to [child] and persists it. The dashboard
  /// controller re-subscribes its child-scoped streams afterwards.
  Future<void> setActive(ActiveChildOption child) async {
    childStatus.value = 'not_arrived';
    await StorageService().remove(_kStatus);
    await _applyActive(child);
  }

  Future<void> _applyActive(ActiveChildOption child) async {
    // Set the data fields BEFORE childId. Listeners (e.g. the dashboard) react
    // to a `childId` change and immediately read name/classroom/branch — so
    // those must already hold the new child's values, or the header would show
    // the previous child's name. childId is therefore assigned LAST.
    childName.value   = child.name;
    classroomId.value = child.classroomId;
    branchId.value    = child.branchId;
    childId.value     = child.id;

    final s = StorageService();
    await s.setData(_kChildId,     {'v': child.id});
    await s.setData(_kChildName,   {'v': child.name});
    await s.setData(_kClassroomId, {'v': child.classroomId});
    await s.setData(_kBranchId,    {'v': child.branchId});
  }

  // ── Status update (called by dashboard controller) ──────────────────────────

  void updateStatus(String status) {
    childStatus.value = status;
    StorageService().setData(_kStatus, {'v': status});
  }

  // ── Logout cleanup ──────────────────────────────────────────────────────────

  Future<void> clearOnLogout() async {
    childId.value     = '';
    childName.value   = '';
    classroomId.value = '';
    branchId.value    = '';
    children.clear();
    childStatus.value = 'not_arrived';
    _unreadSub?.cancel();
    chatUnread.value = 0;
    final s = StorageService();
    await s.remove(_kChildId);
    await s.remove(_kChildName);
    await s.remove(_kClassroomId);
    await s.remove(_kBranchId);
    await s.remove(_kStatus);
  }
}

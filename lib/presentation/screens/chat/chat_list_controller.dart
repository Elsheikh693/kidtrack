import '../../../index/index_main.dart';

/// Manager-side chat inbox: every in-scope child shown as a chat row (with the
/// linked parent), overlaid with the live conversation summary (last message +
/// unread badge). Children with no conversation yet are still listed so the
/// manager can start one.
class ChatListController extends GetxController {
  final _chatService = ChatService();
  final _session = SessionService();

  late final ChildParentService _childService;
  late final ClassroomParentService _classroomService;
  late final ParentChildParentService _linkService;
  late final GuardianParentService _guardianService;

  final RxList<ChildModel> _all = <ChildModel>[].obs;
  final RxList<ChildModel> items = <ChildModel>[].obs;

  final RxMap<String, String> parentNames = <String, String>{}.obs;
  final RxMap<String, String> parentIds = <String, String>{}.obs;
  final RxMap<String, String> classroomNames = <String, String>{}.obs;
  final RxMap<String, ChatConversationModel> convos =
      <String, ChatConversationModel>{}.obs;

  final RxBool isLoading = true.obs;
  final RxString searchQuery = ''.obs;
  final searchCtrl = TextEditingController();

  StreamSubscription<List<ChatConversationModel>>? _convoSub;

  @override
  void onInit() {
    super.onInit();
    _childService = Get.find<ChildParentService>();
    _classroomService = Get.find<ClassroomParentService>();
    _linkService = Get.find<ParentChildParentService>();
    _guardianService = Get.find<GuardianParentService>();
    _loadData();
    _convoSub = _chatService.watchConversations().listen((list) {
      convos.value = {for (final c in list) c.childId: c};
      _sort();
    });
    debounce(
      searchQuery,
      (_) => _filter(),
      time: const Duration(milliseconds: 300),
    );
  }

  @override
  void onClose() {
    _convoSub?.cancel();
    searchCtrl.dispose();
    super.onClose();
  }

  String parentName(String? childId) =>
      childId == null ? '' : (parentNames[childId] ?? '');

  String classroomName(String? id) => (id == null || classroomNames[id] == null)
      ? 'child_classroom_none'.tr
      : classroomNames[id]!;

  ChatConversationModel? convoFor(String? childId) =>
      childId == null ? null : convos[childId];

  int unreadFor(String? childId) => convoFor(childId)?.unreadManager ?? 0;

  Future<void> _loadData() async {
    isLoading.value = true;
    await Future.wait([_loadClassrooms(), _loadParents()]);
    await _childService.getAll(
      callBack: (list) {
        _all.value = list.whereType<ChildModel>().where(_inScope).toList();
      },
    );
    _sort();
    isLoading.value = false;
  }

  Future<void> _loadClassrooms() async {
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
        final names = <String, String>{};
        final ids = <String, String>{};
        for (final link in list.whereType<ParentChildModel>()) {
          final name = parentById[link.parentId];
          if (name == null) continue;
          if (link.isPrimary || !names.containsKey(link.childId)) {
            names[link.childId] = name;
            ids[link.childId] = link.parentId;
          }
        }
        parentNames.value = names;
        parentIds.value = ids;
      },
    );
  }

  /// Owner/super-admin see every branch; a manager only sees their own branch
  /// and shift. Only active children are messageable.
  bool _inScope(ChildModel c) {
    if (c.status != 'active') return false;
    if (_session.isOwner || _session.isSuperAdmin) return true;
    final bId = _session.branchId;
    if (bId != null && bId.isNotEmpty && c.branchId != bId) return false;
    return _session.seesShift(c.shift);
  }

  void _sort() {
    _all.sort((a, b) {
      final ca = convos[a.key];
      final cb = convos[b.key];
      final aHas = ca != null && ca.hasMessages;
      final bHas = cb != null && cb.hasMessages;
      if (aHas && bHas) return cb.lastAt.compareTo(ca.lastAt);
      if (aHas) return -1;
      if (bHas) return 1;
      return a.fullName.compareTo(b.fullName);
    });
    _filter();
  }

  void _filter() {
    final q = searchQuery.value.trim().toLowerCase();
    items.value = _all.where((c) {
      if (q.isEmpty) return true;
      final pn = parentName(c.key).toLowerCase();
      return c.fullName.toLowerCase().contains(q) || pn.contains(q);
    }).toList();
  }

  /// Opens the conversation for [child], building the meta the thread needs to
  /// upsert on the first message.
  Future<void> openThread(ChildModel child) async {
    final childId = child.key ?? '';
    if (childId.isEmpty) return;
    final meta = ChatConversationModel(
      childId: childId,
      childName: child.fullName,
      childImage: child.profileImage,
      classroomId: child.classroomId,
      branchId: child.branchId,
      parentId: parentIds[childId] ?? child.parentId ?? '',
      parentName: parentName(childId),
    );
    await _chatService.markRead(childId, 'manager');
    Get.toNamed(
      chatThreadView,
      arguments: {
        'meta': meta,
        'senderRole': 'manager',
        'title': child.fullName,
        'subtitle': parentName(childId),
        'image': child.profileImage,
      },
    );
  }
}

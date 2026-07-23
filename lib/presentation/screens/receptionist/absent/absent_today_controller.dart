import '../../../../index/index_main.dart';
import '../../../../Global/services/child_status_service.dart';

/// Shared controller behind the "absent today" section, reused on the reception
/// home and inside the children tab. A child counts as absent when they are an
/// active child in scope with NO dated attendance record for today — the same
/// present-id source of truth the dashboards read ([watchPresentIdsForDay]), so
/// the list flips live the moment a check-in lands.
///
/// The caring "why was your child absent" message is sent automatically at each
/// child's shift end by the `absentShiftEndScan` Cloud Function; this section is
/// the reception-facing view of the same set, and lets staff open the shared
/// parent chat manually too.
class AbsentTodayController extends GetxController {
  late final ChildParentService _childSvc;
  late final ParentChildParentService _linkSvc;
  late final GuardianParentService _guardianSvc;

  final _session = SessionService();
  final _statusSvc = ChildStatusService();

  final RxList<ChildModel> absent = <ChildModel>[].obs;
  final RxBool isLoading = true.obs;

  final _all = <ChildModel>[];
  final _parentNames = <String, String>{};
  final _parentIds = <String, String>{};
  final _parentPhones = <String, String>{};
  Set<String> _presentIds = <String>{};
  StreamSubscription<Set<String>>? _presentSub;

  String get _nurseryId => _session.nurseryId ?? '';
  String get _branchId => _session.branchId ?? '';

  int get count => absent.length;

  @override
  void onInit() {
    super.onInit();
    _childSvc = Get.find<ChildParentService>();
    _linkSvc = Get.find<ParentChildParentService>();
    _guardianSvc = Get.find<GuardianParentService>();
    load();
    _presentSub = _statusSvc.watchPresentIdsForDay(_nurseryId).listen((ids) {
      _presentIds = ids;
      _recompute();
    });
  }

  @override
  void onClose() {
    _presentSub?.cancel();
    super.onClose();
  }

  String parentName(String? childId) =>
      childId == null ? '' : (_parentNames[childId] ?? '');

  String parentPhone(String? childId) =>
      childId == null ? '' : (_parentPhones[childId] ?? '');

  bool hasParentPhone(String? childId) => parentPhone(childId).trim().isNotEmpty;

  Future<void> load() async {
    isLoading.value = true;
    await _loadParents();
    await _childSvc.getAll(callBack: (list) {
      _all
        ..clear()
        ..addAll(list.whereType<ChildModel>().where(_inScope));
    });
    _recompute();
    isLoading.value = false;
  }

  /// Owner/super-admin see every branch; a receptionist only sees their own
  /// branch and shift. Only active children can be "absent".
  bool _inScope(ChildModel c) {
    if (c.status != 'active') return false;
    if (_session.isOwner || _session.isSuperAdmin) return true;
    final b = _branchId;
    if (b.isNotEmpty && c.branchId != b) return false;
    return _session.seesShift(c.shift);
  }

  void _recompute() {
    final list = _all
        .where((c) => !_presentIds.contains(c.key ?? ''))
        .toList()
      ..sort((a, b) => a.fullName.compareTo(b.fullName));
    absent.assignAll(list);
  }

  Future<void> _loadParents() async {
    final nameByUid = <String, String>{};
    final phoneByUid = <String, String>{};
    await _guardianSvc.getAll(callBack: (list) {
      for (final p in list.whereType<ParentModel>()) {
        nameByUid[p.uid] = p.name;
        phoneByUid[p.uid] = p.phone ?? '';
      }
    });
    await _linkSvc.getAll(callBack: (list) {
      final names = <String, String>{};
      final ids = <String, String>{};
      final phones = <String, String>{};
      for (final link in list.whereType<ParentChildModel>()) {
        final name = nameByUid[link.parentId];
        if (name == null) continue;
        // Primary parent wins; otherwise the first one found.
        if (link.isPrimary || !names.containsKey(link.childId)) {
          names[link.childId] = name;
          ids[link.childId] = link.parentId;
          phones[link.childId] = phoneByUid[link.parentId] ?? '';
        }
      }
      _parentNames
        ..clear()
        ..addAll(names);
      _parentIds
        ..clear()
        ..addAll(ids);
      _parentPhones
        ..clear()
        ..addAll(phones);
    });
  }

  /// Opens the shared nursery↔guardian conversation for [child] (staff side).
  Future<void> openChat(ChildModel child) => openStaffChat(
        child: child,
        parentId: _parentIds[child.key] ?? child.parentId ?? '',
        parentName: parentName(child.key),
      );

  /// Opens WhatsApp to the guardian's number with the caring absence note
  /// pre-filled — reception just taps send.
  void openWhatsApp(ChildModel child) {
    final phone = parentPhone(child.key);
    if (phone.trim().isEmpty) return;
    MakeCall.openWhatsApp(phone, message: absenceWhatsAppMessage(child.firstName));
  }
}

/// Warm, informal Egyptian absence note for WhatsApp — kept in sync with the
/// backend chat message in `functions/engagement/absentShiftEnd.js`. Emoji are
/// fine here because WhatsApp renders them.
String absenceWhatsAppMessage(String firstName) {
  final name = firstName.trim().isEmpty ? 'programssu27_default_child'.tr : firstName.trim();
  return 'programssu27_absence_whatsapp'.trParams({'name': name});
}

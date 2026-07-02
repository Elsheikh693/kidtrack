import '../../../../index/index_main.dart';
import '../../../../Global/services/pickup_realtime_service.dart';
import '../../../../Global/services/child_status_service.dart';

class PickupRequestsController extends GetxController {
  final items = <PickupRequestModel>[].obs;
  final filtered = <PickupRequestModel>[].obs;
  final selectedStatus = 'all'.obs;
  final isLoading = true.obs;
  final childNames = <String, String>{}.obs;

  late final PickupRealtimeService _realtimeSvc;

  final _session = SessionService();
  String get _nurseryId => _session.nurseryId ?? '';
  String get _branchId => _session.branchId ?? '';

  StreamSubscription<List<PickupRequestModel>>? _sub;

  static const _statuses = [
    'all',
    'requested',
    'preparing',
    'completed',
    'rejected',
  ];
  List<String> get statuses => _statuses;

  @override
  void onInit() {
    super.onInit();
    _realtimeSvc = Get.find<PickupRealtimeService>();
    _loadChildrenThenStream();
  }

  @override
  void onClose() {
    _sub?.cancel();
    super.onClose();
  }

  Future<void> _loadChildrenThenStream() async {
    isLoading.value = true;
    childNames.value = await _realtimeSvc.loadChildrenNames(_nurseryId);
    _startStream();
    isLoading.value = false;
  }

  void _startStream() {
    _sub?.cancel();
    _sub = _realtimeSvc
        .watchBranchRequests(_nurseryId, _branchId)
        .listen((list) {
      items.value =
          list.where((r) => r.status != 'cancelled').toList();
      _applyFilter();
    });
  }

  void filterByStatus(String status) {
    selectedStatus.value = status;
    _applyFilter();
  }

  void _applyFilter() {
    if (selectedStatus.value == 'all') {
      filtered.value = List.from(items);
    } else {
      filtered.value =
          items.where((p) => p.status == selectedStatus.value).toList();
    }
  }

  String childName(String childId) => childNames[childId] ?? childId;

  Future<void> updateStatus(
    PickupRequestModel request,
    String newStatus,
  ) async {
    Loader.show();
    final ok = await _realtimeSvc.updateStatus(
      _nurseryId,
      request.key ?? '',
      newStatus,
    );
    if (ok && newStatus == 'completed') {
      await ChildStatusService().checkOutChildByPickup(
        nurseryId: _nurseryId,
        branchId: _branchId,
        childId: request.childId,
        staffId: _session.userId ?? '',
      );
    }
    Loader.dismiss();
    if (ok) {
      Loader.showSuccess('pickup_status_updated'.tr);
    } else {
      Loader.showError('common_error'.tr);
    }
  }

  String formatTime(int? ms) {
    if (ms == null) return '--';
    final dt = DateTime.fromMillisecondsSinceEpoch(ms);
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

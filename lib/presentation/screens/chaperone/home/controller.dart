import 'package:geolocator/geolocator.dart';
import '../../../../index/index_main.dart';

class ChaperoneHomeController extends GetxController {
  final _session = SessionService();
  late final BusTrackingService _trackingService;
  late final ChildParentService _childService;

  final children = <BusChildEntry>[].obs;
  final isTracking = false.obs;
  final currentLocation = Rxn<Position>();
  final sessionId = Rxn<String>();
  final isLoadingChildren = false.obs;
  final direction = BusTripDirection.toHome.obs;

  @override
  void onInit() {
    super.onInit();
    _trackingService = BusTrackingService();
    _childService = Get.find<ChildParentService>();
    _loadChildren();
  }

  String get chaperoneName => _session.currentUser?.name ?? '';
  String get chaperoneId => _session.userId ?? '';
  String get branchId => _session.branchId ?? '';
  String get nurseryId => _session.nurseryId ?? '';

  void setDirection(BusTripDirection dir) {
    if (isTracking.value) return; // can't change mid-trip
    direction.value = dir;
  }

  Future<Map<String, ParentModel>> _loadParents() async {
    final service = Get.find<BaseService<ParentModel>>(tag: 'parents');
    final completer = Completer<List<ParentModel?>>();
    await service.getData(data: {}, voidCallBack: completer.complete);
    final list = await completer.future;
    return {
      for (final p in list.whereType<ParentModel>()) p.uid: p,
    };
  }

  Future<void> _loadChildren() async {
    isLoadingChildren.value = true;
    final completer = Completer<List<ChildModel?>>();
    await _childService.getAll(callBack: completer.complete);
    final result = await completer.future;
    final parents = await _loadParents();

    // Only children assigned to THIS chaperone's bus
    final myChildren = result
        .whereType<ChildModel>()
        .where((c) =>
            c.branchId == branchId &&
            c.status == 'active' &&
            c.busChaperoneId == chaperoneId)
        .toList();

    children.value = myChildren.map((c) {
      final parent = c.parentId != null ? parents[c.parentId] : null;
      return BusChildEntry(
        childId: c.key ?? '',
        childName: c.fullName,
        childImage: c.profileImage,
        address: c.homeAddress,
        homeLat: c.homeLat,
        homeLng: c.homeLng,
        parentId: c.parentId,
        parentPhone: parent?.phone,
        status: ChildBusStatus.pending,
      );
    }).toList();
    isLoadingChildren.value = false;
  }

  Future<void> startTracking() async {
    final hasPermission = await _checkLocationPermission();
    if (!hasPermission) return;

    Loader.show();
    final id = await _trackingService.startSession(
      chaperoneId: chaperoneId,
      chaperoneName: chaperoneName,
      branchId: branchId,
      children: children,
      direction: direction.value,
    );
    if (id == null) {
      Loader.showError('tracking_start_error'.tr);
      return;
    }
    sessionId.value = id;
    isTracking.value = true;
    _trackingService.startLocationStream(
      branchId: branchId,
      sessionId: id,
      children: children,
      chaperoneId: chaperoneId,
    );
    Loader.showSuccess('tracking_started'.tr);
  }

  Future<void> stopTracking() async {
    final id = sessionId.value;
    if (id == null) return;
    Loader.show();
    await _trackingService.endSession(branchId: branchId, sessionId: id);
    isTracking.value = false;
    sessionId.value = null;
    Loader.showSuccess('tracking_ended'.tr);
  }

  Future<void> markChildOnBus(BusChildEntry child) async {
    final id = sessionId.value;
    if (id == null) return;
    await _trackingService.markChildOnBus(
      branchId: branchId,
      sessionId: id,
      child: child,
      nurseryId: nurseryId,
      direction: direction.value,
    );
    _updateChildStatus(child.childId, ChildBusStatus.onBus, picked: true);
  }

  Future<void> markChildDelivered(BusChildEntry child) async {
    final id = sessionId.value;
    if (id == null) return;

    await _trackingService.markChildDelivered(
      branchId: branchId,
      sessionId: id,
      child: child,
      nurseryId: nurseryId,
      direction: direction.value,
    );
    _updateChildStatus(child.childId, ChildBusStatus.delivered, delivered: true);
  }

  Future<void> notifyNearHouse(BusChildEntry child) async {
    await _trackingService.notifyNearHouse(
      child: child,
      parentUserId: child.parentId,
      nurseryId: nurseryId,
    );
    Loader.showSuccess('tracking_near_notif_sent'.tr);
  }

  // ── Open external maps navigation to child's home ─────────────────────────

  Future<void> openNavigation(BusChildEntry child) async {
    if (!child.hasLocation) {
      Loader.showError('tracking_no_location'.tr);
      return;
    }
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${child.homeLat},${child.homeLng}',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Loader.showError('tracking_no_location'.tr);
    }
  }

  Future<void> callParent(BusChildEntry child) async {
    final phone = child.parentPhone;
    if (phone == null || phone.isEmpty) {
      Loader.showError('tracking_no_phone'.tr);
      return;
    }
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      Loader.showError('tracking_no_phone'.tr);
    }
  }

  void _updateChildStatus(
    String childId,
    ChildBusStatus status, {
    bool picked = false,
    bool delivered = false,
  }) {
    final index = children.indexWhere((c) => c.childId == childId);
    if (index == -1) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    children[index] = children[index].copyWith(
      status: status,
      updatedAt: now,
      pickedUpAt: picked ? now : null,
      deliveredAt: delivered ? now : null,
    );
    children.refresh();
  }

  Future<bool> _checkLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final req = await Geolocator.requestPermission();
      if (req == LocationPermission.denied ||
          req == LocationPermission.deniedForever) {
        Loader.showError('tracking_location_denied'.tr);
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    _trackingService.dispose();
    super.onClose();
  }
}

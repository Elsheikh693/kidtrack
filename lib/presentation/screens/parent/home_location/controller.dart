import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import '../../../../index/index_main.dart';

class ParentHomeLocationController extends GetxController {
  final _session = SessionService();
  late final ChildParentService _childService;

  // Cairo default center until we know better
  static const _fallback = gmap.LatLng(30.0444, 31.2357);

  final isLoading = true.obs;
  final isSaving = false.obs;
  final selected = Rxn<gmap.LatLng>();
  final addressText = ''.obs;

  final _myChildren = <ChildModel>[];
  gmap.GoogleMapController? mapController;

  String get parentId => _session.userId ?? '';

  gmap.LatLng get initialTarget => selected.value ?? _fallback;

  @override
  void onInit() {
    super.onInit();
    _childService = Get.find<ChildParentService>();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    final completer = Completer<List<ChildModel?>>();
    await _childService.getAll(callBack: completer.complete);
    final all = await completer.future;
    _myChildren.clear();
    _myChildren.addAll(
      all.whereType<ChildModel>().where((c) => c.parentId == parentId),
    );

    final existing = _myChildren.firstWhereOrNull((c) => c.hasHomeLocation);
    if (existing != null) {
      selected.value = gmap.LatLng(existing.homeLat!, existing.homeLng!);
      addressText.value = existing.homeAddress ?? '';
    }
    isLoading.value = false;
  }

  void onCameraMove(gmap.CameraPosition pos) {
    selected.value = pos.target;
  }

  Future<void> useCurrentLocation() async {
    final ok = await _ensurePermission();
    if (!ok) return;
    Loader.show();
    try {
      final pos = await Geolocator.getCurrentPosition();
      final target = gmap.LatLng(pos.latitude, pos.longitude);
      selected.value = target;
      mapController?.animateCamera(
        gmap.CameraUpdate.newLatLngZoom(target, 16),
      );
      Loader.dismiss();
    } catch (_) {
      Loader.showError('home_loc_current_error'.tr);
    }
  }

  Future<void> save() async {
    final loc = selected.value;
    if (loc == null) {
      Loader.showError('home_loc_pick_first'.tr);
      return;
    }
    if (_myChildren.isEmpty) {
      Loader.showError('home_loc_no_children'.tr);
      return;
    }
    isSaving.value = true;
    Loader.show();
    final addr = addressText.value.trim();
    for (final child in _myChildren) {
      final updated = child.copyWith(
        homeLat: loc.latitude,
        homeLng: loc.longitude,
        homeAddress: addr.isEmpty ? null : addr,
      );
      final completer = Completer<ResponseStatus>();
      await _childService.update(item: updated, callBack: completer.complete);
      await completer.future;
    }
    isSaving.value = false;
    Loader.showSuccess('home_loc_saved'.tr);
    Get.back();
  }

  Future<bool> _ensurePermission() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Loader.showError('tracking_location_denied'.tr);
      return false;
    }
    return true;
  }

  @override
  void onClose() {
    mapController?.dispose();
    super.onClose();
  }
}

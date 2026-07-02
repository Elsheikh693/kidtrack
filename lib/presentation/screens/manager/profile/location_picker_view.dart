import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import '../../../../index/index_main.dart';

class LocationPickerView extends StatefulWidget {
  const LocationPickerView({super.key, this.initial});

  final gmap.LatLng? initial;

  @override
  State<LocationPickerView> createState() => _LocationPickerViewState();
}

class _LocationPickerViewState extends State<LocationPickerView> {
  static const _fallback = gmap.LatLng(30.0444, 31.2357); // Cairo

  gmap.GoogleMapController? _map;
  late gmap.LatLng _target;

  @override
  void initState() {
    super.initState();
    _target = widget.initial ?? _fallback;
  }

  @override
  void dispose() {
    _map?.dispose();
    super.dispose();
  }

  Future<void> _useCurrent() async {
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      Loader.showError('tracking_location_denied'.tr);
      return;
    }
    Loader.show();
    try {
      final pos = await Geolocator.getCurrentPosition();
      _target = gmap.LatLng(pos.latitude, pos.longitude);
      await _map?.animateCamera(gmap.CameraUpdate.newLatLngZoom(_target, 16));
      Loader.dismiss();
    } catch (_) {
      Loader.showError('home_loc_current_error'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: HomeAppBar(title: 'manager_profile_pick_location'.tr),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  gmap.GoogleMap(
                    initialCameraPosition:
                        gmap.CameraPosition(target: _target, zoom: 15),
                    onMapCreated: (c) => _map = c,
                    onCameraMove: (pos) => _target = pos.target,
                    myLocationButtonEnabled: false,
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 36),
                    child: Icon(Icons.location_on,
                        size: 48, color: AppColors.primary),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    child: FloatingActionButton(
                      heroTag: 'manager_loc_my_location',
                      backgroundColor: AppColors.white,
                      foregroundColor: AppColors.primary,
                      onPressed: _useCurrent,
                      child: const Icon(Icons.my_location_rounded),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              color: AppColors.white,
              child: PrimaryTextButton(
                label: AppText(
                  text: 'manager_profile_confirm_location'.tr,
                  textStyle: context.typography.smSemiBold
                      .copyWith(color: AppColors.white),
                ),
                appButtonSize: AppButtonSize.large,
                onTap: () => Get.back(result: _target),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

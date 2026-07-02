import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import '../../../../../index/index_main.dart';

class LiveMapWidget extends StatefulWidget {
  const LiveMapWidget({super.key, required this.session});

  final BusSession session;

  @override
  State<LiveMapWidget> createState() => _LiveMapWidgetState();
}

class _LiveMapWidgetState extends State<LiveMapWidget> {
  gmap.GoogleMapController? _mapController;

  gmap.LatLng? get _busLatLng {
    final loc = widget.session.location;
    if (loc == null) return null;
    return gmap.LatLng(loc.lat, loc.lng);
  }

  Set<gmap.Marker> get _markers {
    final pos = _busLatLng;
    if (pos == null) return {};
    return {
      gmap.Marker(
        markerId: const gmap.MarkerId('bus'),
        position: pos,
        icon: gmap.BitmapDescriptor.defaultMarkerWithHue(
          gmap.BitmapDescriptor.hueOrange,
        ),
        infoWindow: gmap.InfoWindow(title: 'tracking_bus_marker'.tr),
      ),
    };
  }

  @override
  void didUpdateWidget(LiveMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    final pos = _busLatLng;
    if (pos != null && _mapController != null) {
      _mapController!.animateCamera(gmap.CameraUpdate.newLatLng(pos));
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pos = _busLatLng;
    if (pos == null) {
      return Container(
        height: 280.h,
        alignment: Alignment.center,
        color: AppColors.backgroundNeutral100,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_searching_rounded,
              size: 40.sp,
              color: AppColors.textSecondaryParagraph),
            SizedBox(height: 8.h),
            Text(
              'tracking_waiting_location'.tr,
              style: context.typography.smRegular.copyWith(
                color: AppColors.textSecondaryParagraph,
              ),
            ),
          ],
        ));
    }

    return SizedBox(
      height: 280.h,
      child: gmap.GoogleMap(
        initialCameraPosition: gmap.CameraPosition(target: pos, zoom: 15),
        markers: _markers,
        myLocationEnabled: false,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        onMapCreated: (c) => _mapController = c,
      ),
    );
  }
}

import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class LocationManager {
  /// 🔹 Check & Request Permission
  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 🔥 Check if GPS is enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar("Location Disabled", "Please enable GPS");
      await Geolocator.openLocationSettings();
      return false;
    }

    // 🔥 Check Permission
    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        Get.snackbar("Permission Denied", "Location permission is required");
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        "Permission Permanently Denied",
        "Please enable location from settings",
      );
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  /// 🔹 Get Current Position
  Future<Position?> getCurrentPosition() async {
    final hasPermission = await _handlePermission();
    if (!hasPermission) return null;

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  /// 🔹 Get Lat & Long
  Future<Map<String, double>?> getLatLng() async {
    final position = await getCurrentPosition();
    if (position == null) return null;

    return {"lat": position.latitude, "lng": position.longitude};
  }

  /// 🔹 Calculate Distance (meters)
  double calculateDistance({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }
}

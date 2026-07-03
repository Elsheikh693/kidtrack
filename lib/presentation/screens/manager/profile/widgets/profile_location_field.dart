import 'package:geolocator/geolocator.dart';
import '../../../../../index/index_main.dart';

class ProfileLocationField extends StatelessWidget {
  const ProfileLocationField({super.key, required this.controller});

  final ManagerNurseryProfileController controller;

  Future<void> _pick() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      Loader.showError('tracking_location_denied'.tr);
      await Geolocator.openLocationSettings();
      return;
    }
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
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      controller.setLocation(pos.latitude, pos.longitude);
      Loader.dismiss();
    } catch (_) {
      Loader.showError('home_loc_current_error'.tr);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _pick,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: AppColors.grayLight),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_rounded, color: AppColors.primary),
            SizedBox(width: 12.w),
            Expanded(
              child: Obx(
                () => AppText(
                  text: controller.hasLocation
                      ? '${controller.lat.value!.toStringAsFixed(5)}, ${controller.lng.value!.toStringAsFixed(5)}'
                      : 'manager_profile_location_hint'.tr,
                  textStyle: context.typography.smRegular.copyWith(
                    color: controller.hasLocation
                        ? AppColors.textPrimaryParagraph
                        : AppColors.textSecondaryParagraph,
                  ),
                ),
              ),
            ),
            Icon(Icons.my_location_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

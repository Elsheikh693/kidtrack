import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import '../../../../../index/index_main.dart';
import '../location_picker_view.dart';

class ProfileLocationField extends StatelessWidget {
  const ProfileLocationField({super.key, required this.controller});

  final ManagerNurseryProfileController controller;

  Future<void> _pick() async {
    final initial = controller.hasLocation
        ? gmap.LatLng(controller.lat.value!, controller.lng.value!)
        : null;
    final result = await Get.to<gmap.LatLng>(
      () => LocationPickerView(initial: initial),
    );
    if (result != null) {
      controller.setLocation(result.latitude, result.longitude);
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
            Icon(Icons.chevron_right_rounded, color: AppColors.grayMedium),
          ],
        ),
      ),
    );
  }
}

import 'package:google_maps_flutter/google_maps_flutter.dart' as gmap;
import '../../../../index/index_main.dart';

class ParentHomeLocationView extends StatefulWidget {
  const ParentHomeLocationView({super.key});

  @override
  State<ParentHomeLocationView> createState() =>
      _ParentHomeLocationViewState();
}

class _ParentHomeLocationViewState extends State<ParentHomeLocationView> {
  late final ParentHomeLocationController controller;

  @override
  void initState() {
    super.initState();
    controller = initController(() => ParentHomeLocationController());
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: appTextDirection,
      child: Scaffold(
        backgroundColor: AppColors.backgroundNeutral100,
        appBar: HomeAppBar(title: 'home_loc_title'.tr),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    gmap.GoogleMap(
                      initialCameraPosition: gmap.CameraPosition(
                        target: controller.initialTarget,
                        zoom: 15,
                      ),
                      onMapCreated: (c) => controller.mapController = c,
                      onCameraMove: controller.onCameraMove,
                      myLocationButtonEnabled: false,
                      myLocationEnabled: true,
                      zoomControlsEnabled: false,
                    ),
                    // fixed center pin
                    Padding(
                      padding: const EdgeInsets.only(bottom: 36),
                      child: Icon(
                        Icons.location_on,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    // current-location FAB
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: FloatingActionButton(
                        heroTag: 'home_loc_my_location',
                        backgroundColor: AppColors.white,
                        foregroundColor: AppColors.primary,
                        onPressed: controller.useCurrentLocation,
                        child: const Icon(Icons.my_location_rounded),
                      ),
                    ),
                  ],
                ),
              ),
              _BottomPanel(controller: controller),
            ],
          );
        }),
      ),
    );
  }
}

class _BottomPanel extends StatefulWidget {
  const _BottomPanel({required this.controller});
  final ParentHomeLocationController controller;

  @override
  State<_BottomPanel> createState() => _BottomPanelState();
}

class _BottomPanelState extends State<_BottomPanel> {
  late final TextEditingController _addressCtrl;

  @override
  void initState() {
    super.initState();
    _addressCtrl =
        TextEditingController(text: widget.controller.addressText.value);
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'home_loc_hint'.tr,
            style: context.typography.smRegular
                .copyWith(color: AppColors.textSecondaryParagraph),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: (v) => controller.addressText.value = v,
            controller: _addressCtrl,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              hintText: 'home_loc_address_hint'.tr,
              prefixIcon: Icon(Icons.home_outlined, color: AppColors.primary),
              filled: true,
              fillColor: AppColors.backgroundNeutral100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
                  onPressed: controller.isSaving.value
                      ? null
                      : controller.save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    'home_loc_save'.tr,
                    style: context.typography.mdBold
                        .copyWith(color: AppColors.white),
                  ),
                )),
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import '../../index/index_main.dart';

class Loader {
  static void show() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 3000)
      ..loadingStyle = EasyLoadingStyle.custom
      ..indicatorSize = 100
      ..radius = 10
      ..lineWidth = 10
      ..maskColor = AppColors.grayMedium
      ..indicatorColor = ColorResources.COLOR_Primary
      ..userInteractions = false
      ..dismissOnTap = true
      ..backgroundColor = Colors.transparent
      ..textColor = ColorResources.COLOR_Primary
      ..boxShadow = <BoxShadow>[]
      ..indicatorType = EasyLoadingIndicatorType.chasingDots;
    EasyLoading.show(status: '');
  }

  static void dismiss() {
    EasyLoading.dismiss();
  }

  /// **Show Information Message (Uses Overlay like Error)**
  static void showInfo(String txt) {
    EasyLoading.dismiss(); // Dismiss any active loaders

    Future.delayed(const Duration(milliseconds: 100), () {
      final overlay = Overlay.of(Get.context!);

      final overlayEntry = OverlayEntry(
        builder: (context) => AnimatedInfoMessage(txt: txt),
      );

      overlay.insert(overlayEntry);

      Future.delayed(const Duration(seconds: 3), () {
        overlayEntry.remove();
      });
    });
  }

  /// **Show Success Message (Uses Overlay like Error)**
  static void showSuccess(String txt) {
    EasyLoading.dismiss(); // Dismiss any active loaders

    Future.delayed(const Duration(milliseconds: 100), () {
      final overlay = Overlay.of(Get.context!);

      final overlayEntry = OverlayEntry(
        builder: (context) => AnimatedSuccessMessage(txt: txt),
      );

      overlay.insert(overlayEntry);

      Future.delayed(const Duration(seconds: 3), () {
        overlayEntry.remove();
      });
    });
  }

  /// **Show Error Message (Already Uses Overlay)**
  static void showError(String txt) {
    EasyLoading.dismiss(); // Dismiss any active loaders

    Future.delayed(const Duration(milliseconds: 100), () {
      final overlay = Overlay.of(Get.context!);

      final overlayEntry = OverlayEntry(
        builder: (context) => AnimatedErrorMessage(txt: txt),
      );

      overlay.insert(overlayEntry);

      Future.delayed(const Duration(seconds: 3), () {
        overlayEntry.remove();
      });
    });
  }

  // ─── Upload Progress ──────────────────────────────────────────────────────

  static final _uploadProgress = ValueNotifier<double>(0.0);
  static OverlayEntry? _progressOverlay;

  static void showUploadProgress() {
    _uploadProgress.value = 0.0;
    if (_progressOverlay != null) return;
    Future.delayed(const Duration(milliseconds: 50), () {
      if (Get.context == null) return;
      _progressOverlay = OverlayEntry(
        builder: (_) => _UploadProgressOverlay(progress: _uploadProgress),
      );
      Overlay.of(Get.context!).insert(_progressOverlay!);
    });
  }

  static void updateUploadProgress(double value) {
    _uploadProgress.value = value.clamp(0.0, 1.0);
  }

  static void hideUploadProgress() {
    Future.delayed(const Duration(milliseconds: 400), () {
      _progressOverlay?.remove();
      _progressOverlay = null;
      _uploadProgress.value = 0.0;
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Upload Progress Overlay
// ─────────────────────────────────────────────────────────────────────────────

class _UploadProgressOverlay extends StatelessWidget {
  final ValueNotifier<double> progress;

  const _UploadProgressOverlay({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            20.w,
            16.h,
            20.w,
            MediaQuery.of(context).padding.bottom + 16.h,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C1E).withValues(alpha: 0.94),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.cloud_upload_rounded,
                      color: AppColors.white,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'globalserv8_uploading_image'.tr,
                      style: context.typography.smMedium.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ),
                  ValueListenableBuilder<double>(
                    valueListenable: progress,
                    builder: (_, v, __) => Text(
                      '${(v * 100).toInt()}%',
                      style: context.typography.smSemiBold.copyWith(
                        color: const Color(0xFF34D399),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              ValueListenableBuilder<double>(
                valueListenable: progress,
                builder: (_, v, __) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: v,
                    backgroundColor: AppColors.white.withValues(alpha: 0.15),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF34D399),
                    ),
                    minHeight: 7,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

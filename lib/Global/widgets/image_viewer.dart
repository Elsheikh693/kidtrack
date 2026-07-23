import '../../index/index_main.dart';

/// Opens [url] full-screen on a dark scrim with pinch-to-zoom and a clear
/// circular close (✕) button in the corner. Tapping the background or the
/// button dismisses. Used anywhere a stored image (e.g. a transfer-proof
/// screenshot) needs a proper viewer instead of a cramped thumbnail.
void showFullImage(String url) {
  Get.dialog(
    Stack(
      children: [
        // Dark backdrop — tap anywhere to close.
        Positioned.fill(
          child: GestureDetector(
            onTap: Get.back,
            child: const ColoredBox(color: Color(0xF2000000)),
          ),
        ),
        // The image, zoomable.
        Positioned.fill(
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4,
            child: Center(
              child: AppNetworkImage(url: url, fit: BoxFit.contain),
            ),
          ),
        ),
        // Clear circular close button.
        SafeArea(
          child: Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: GestureDetector(
                onTap: Get.back,
                child: Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Icon(Icons.close_rounded,
                      color: Colors.white, size: 24.sp),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
    barrierColor: Colors.transparent,
    useSafeArea: false,
  );
}

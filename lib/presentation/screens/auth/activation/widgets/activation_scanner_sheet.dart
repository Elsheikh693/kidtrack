import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../../index/index_main.dart';

/// Opens a full-screen QR scanner for the activation screen. Resolves with the
/// decoded string on the first successful scan, or null if the user backs out.
Future<String?> openActivationScanner() async {
  return Get.to<String>(
    () => const _ActivationScannerPage(),
    fullscreenDialog: true,
  );
}

class _ActivationScannerPage extends StatefulWidget {
  const _ActivationScannerPage();

  @override
  State<_ActivationScannerPage> createState() => _ActivationScannerPageState();
}

class _ActivationScannerPageState extends State<_ActivationScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _handled = false;

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .where((v) => v != null && v.trim().isNotEmpty)
        .firstOrNull;
    if (raw == null) return;
    _handled = true;
    Get.back<String>(result: raw.trim());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          'activation_scan_title'.tr,
          style: context.typography.mdBold.copyWith(color: AppColors.white),
        ),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          Container(
            width: 240.w,
            height: 240.w,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.white, width: 3),
              borderRadius: BorderRadius.circular(24.r),
            ),
          ),
          Positioned(
            left: 24.w,
            right: 24.w,
            bottom: 56.h,
            child: Text(
              'activation_scan_hint'.tr,
              textAlign: TextAlign.center,
              style: context.typography.smRegular.copyWith(
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

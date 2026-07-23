import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../index/index_main.dart';

/// Renders [card] off-screen at a fixed [width], captures it as a high-res PNG,
/// and opens the OS share sheet with the image + [shareText]. Used to turn a
/// child's assessment result into a branded, shareable image (nursery + app).
Future<void> captureAndShareAssessment({
  required Widget card,
  required String shareText,
  double width = 380,
}) async {
  final ctx = Get.overlayContext ?? Get.context;
  if (ctx == null) return;

  final boundaryKey = GlobalKey();
  final entry = OverlayEntry(
    builder: (_) => Positioned(
      // Painted inside the viewport (so it is never culled) but at ~0 opacity
      // for the one frame it lives — imperceptible, yet the child still paints
      // so the RepaintBoundary has a layer to capture.
      left: 0,
      top: 0,
      child: Opacity(
        opacity: 0.01,
        child: Material(
          type: MaterialType.transparency,
          child: Directionality(
            textDirection: appTextDirection,
            child: RepaintBoundary(
              key: boundaryKey,
              child: SizedBox(width: width, child: card),
            ),
          ),
        ),
      ),
    ),
  );

  var removed = false;
  void safeRemove() {
    if (removed) return;
    removed = true;
    try {
      entry.remove();
    } catch (_) {}
  }

  Loader.show();
  final overlay = Overlay.of(ctx, rootOverlay: true);
  overlay.insert(entry);

  final box = ctx.findRenderObject() as RenderBox?;
  final Rect? shareOrigin =
      box != null ? box.localToGlobal(Offset.zero) & box.size : null;

  try {
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 120));

    final boundary =
        boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    safeRemove();
    Loader.dismiss();
    if (byteData == null) return;

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/kidtrack_assessment_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    await file.writeAsBytes(byteData.buffer.asUint8List());
    await Share.shareXFiles(
      [XFile(file.path)],
      text: shareText,
      sharePositionOrigin: shareOrigin,
    );
  } catch (e, s) {
    debugPrint('captureAndShareAssessment failed: $e\n$s');
    safeRemove();
    Loader.dismiss();
    Loader.showError('assessment_share_error'.tr);
  }
}

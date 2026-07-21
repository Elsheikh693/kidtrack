import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A brief bottom snackbar with an "undo" action — shown after logging an
/// instant child event so a mis-tap (easy with 25 kids) can be reversed.
void showUndoSnackbar({
  required String message,
  required VoidCallback onUndo,
}) {
  Get.closeAllSnackbars();
  Get.rawSnackbar(
    messageText: Text(
      message,
      style: const TextStyle(color: Colors.white, fontSize: 14),
    ),
    mainButton: TextButton(
      onPressed: () {
        Get.closeCurrentSnackbar();
        onUndo();
      },
      child: Text(
        'common_undo'.tr,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
      ),
    ),
    duration: const Duration(seconds: 4),
    snackPosition: SnackPosition.BOTTOM,
    margin: const EdgeInsets.all(12),
    borderRadius: 12,
    backgroundColor: const Color(0xFF1E293B),
  );
}

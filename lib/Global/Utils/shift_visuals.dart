import 'package:flutter/material.dart';

/// Icon + colors for a shift, derived from its start time so nursery-defined
/// (dynamic) shifts still get sensible morning / mid-day / evening visuals.
/// Buckets: before 12:00 → morning, 12:00–15:00 → between, 15:00+ → evening.
({Color color, Color bg, IconData icon}) shiftVisuals(int startMinutes) {
  if (startMinutes < 720) {
    return (
      color: const Color(0xFFF59E0B),
      bg: const Color(0xFFFEF6E7),
      icon: Icons.wb_sunny_rounded,
    );
  }
  if (startMinutes < 900) {
    return (
      color: const Color(0xFF14B8A6),
      bg: const Color(0xFFE6FAF7),
      icon: Icons.brightness_6_rounded,
    );
  }
  return (
    color: const Color(0xFF6366F1),
    bg: const Color(0xFFEEF0FE),
    icon: Icons.bedtime_rounded,
  );
}

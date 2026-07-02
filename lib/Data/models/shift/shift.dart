import 'package:flutter/material.dart';

/// A work shift within a single branch. A child attends one of three: the
/// morning shift, the evening shift, or [between] (spans both — visible to
/// morning and evening staff alike). Staff and classrooms use [ShiftScope]
/// instead. Stored in Firebase as the enum `.name` ('morning' / 'between' /
/// 'evening') so it matches the legacy [ChildModel.shift] string.
enum Shift {
  morning,
  between,
  evening;

  static Shift? fromName(String? value) {
    if (value == null) return null;
    for (final s in Shift.values) {
      if (s.name == value) return s;
    }
    return null;
  }

  /// Parse a stored list of shift names, dropping anything unrecognized.
  static List<Shift> parseList(dynamic raw) {
    final names = <String>[];
    if (raw is List) {
      names.addAll(raw.map((e) => e.toString()));
    } else if (raw is Map) {
      names.addAll(raw.values.map((e) => e.toString()));
    }
    return names.map(Shift.fromName).whereType<Shift>().toList();
  }

  /// Translation key — call `.tr` in the UI layer.
  String get labelKey {
    switch (this) {
      case Shift.morning:
        return 'shift_morning';
      case Shift.between:
        return 'shift_between';
      case Shift.evening:
        return 'shift_evening';
    }
  }

  IconData get icon {
    switch (this) {
      case Shift.morning:
        return Icons.wb_sunny_rounded;
      case Shift.between:
        return Icons.brightness_6_rounded;
      case Shift.evening:
        return Icons.nightlight_round;
    }
  }
}

/// Which shift(s) a staff member or classroom is assigned to. Unlike a child
/// (who attends exactly one [Shift]), staff and classrooms can serve [both].
/// Stored in Firebase as the enum `.name` ('morning' / 'evening' / 'both').
enum ShiftScope {
  morning,
  evening,
  both;

  static ShiftScope? fromName(String? value) {
    if (value == null) return null;
    for (final s in ShiftScope.values) {
      if (s.name == value) return s;
    }
    return null;
  }

  /// True when this scope is active during [shift] — used for filtering.
  bool covers(Shift shift) {
    if (this == ShiftScope.both) return true;
    return name == shift.name;
  }

  /// Translation key — call `.tr` in the UI layer.
  String get labelKey {
    switch (this) {
      case ShiftScope.morning:
        return 'shift_morning';
      case ShiftScope.evening:
        return 'shift_evening';
      case ShiftScope.both:
        return 'shift_both';
    }
  }

  IconData get icon {
    switch (this) {
      case ShiftScope.morning:
        return Icons.wb_sunny_rounded;
      case ShiftScope.evening:
        return Icons.nightlight_round;
      case ShiftScope.both:
        return Icons.brightness_6_rounded;
    }
  }
}

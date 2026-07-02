import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../design_constants/colors/app_colors.dart';

/// Shared iOS-style date picker used across the app.
///
/// Returns the picked [DateTime] when the user taps "تم", or `null` if they
/// cancel. Replaces the Material `showDatePicker` everywhere for a consistent
/// light Cupertino look.
Future<DateTime?> showAppDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  DateTime? minimumDate,
  DateTime? maximumDate,
  bool showTodayButton = true,
}) {
  final now = DateTime.now();
  final max = maximumDate ?? DateTime(now.year + 5, 12, 31);
  final min = minimumDate ?? DateTime(2020);
  DateTime temp = initialDate.isAfter(max)
      ? max
      : initialDate.isBefore(min)
          ? min
          : initialDate;

  const border = Color(0xFFE5E7EB);
  const muted = Color(0xFF6B7280);

  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 340,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('إلغاء',
                          style: TextStyle(color: muted, fontSize: 15)),
                    ),
                    if (showTodayButton && !now.isAfter(max) && !now.isBefore(min))
                      CupertinoButton(
                        onPressed: () => Navigator.pop(ctx, now),
                        child: const Text('اليوم',
                            style: TextStyle(fontSize: 15)),
                      ),
                    CupertinoButton(
                      onPressed: () => Navigator.pop(ctx, temp),
                      child: Text(
                        'تم',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: temp,
                  minimumDate: min,
                  maximumDate: max,
                  onDateTimeChanged: (d) => temp = d,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Shared iOS-style time picker used across the app.
///
/// Returns the picked [TimeOfDay] when the user taps "تم", or `null` if they
/// cancel. Replaces the Material `showTimePicker` everywhere for a consistent
/// light Cupertino look.
Future<TimeOfDay?> showAppTimePicker(
  BuildContext context, {
  required TimeOfDay initialTime,
  bool use24hFormat = true,
}) {
  final now = DateTime.now();
  DateTime temp = DateTime(
    now.year,
    now.month,
    now.day,
    initialTime.hour,
    initialTime.minute,
  );

  const border = Color(0xFFE5E7EB);
  const muted = Color(0xFF6B7280);

  return showCupertinoModalPopup<TimeOfDay>(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: 340,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('إلغاء',
                          style: TextStyle(color: muted, fontSize: 15)),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.pop(
                        ctx,
                        TimeOfDay(hour: temp.hour, minute: temp.minute),
                      ),
                      child: Text(
                        'تم',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  use24hFormat: use24hFormat,
                  initialDateTime: temp,
                  onDateTimeChanged: (d) => temp = d,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

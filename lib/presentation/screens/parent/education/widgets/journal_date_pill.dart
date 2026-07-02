import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'journal_meta.dart';

/// Compact tappable date selector for the Daily Journal hero.
class JournalDatePill extends StatelessWidget {
  const JournalDatePill({super.key, required this.date, required this.onDate});

  final DateTime date;
  final ValueChanged<DateTime> onDate;

  void _openPicker(BuildContext context) {
    DateTime temp = date;
    final now = DateTime.now();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (ctx) => Container(
        height: 340,
        color: CupertinoColors.systemBackground.resolveFrom(ctx),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: kJBorder)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('إلغاء',
                          style: TextStyle(color: kJMuted)),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onDate(DateTime.now());
                      },
                      child: const Text('اليوم'),
                    ),
                    CupertinoButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        onDate(temp);
                      },
                      child: const Text('تم',
                          style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: date,
                  maximumDate: now,
                  minimumYear: 2020,
                  maximumYear: now.year,
                  onDateTimeChanged: (d) => temp = d,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openPicker(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_rounded, size: 13, color: kJInk),
            const SizedBox(width: 6),
            Text(
              journalDateLabel(date),
              style: const TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w800, color: kJInk),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded,
                size: 16, color: kJMuted),
          ],
        ),
      ),
    );
  }
}

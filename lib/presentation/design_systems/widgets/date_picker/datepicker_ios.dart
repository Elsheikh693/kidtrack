
import 'package:flutter/cupertino.dart';
import '../../../../index/index.dart';


class AppDateIosPicker extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;

  const AppDateIosPicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });

  void _showCupertinoDatePicker(BuildContext context) {
    final datePickerTheme = context.appDatePickerTheme;

    showCupertinoModalPopup(
      context: context,
      builder: (_) => Container(
        height: 300,
        decoration: BoxDecoration(
          color: datePickerTheme.backgroundColor,
          borderRadius: datePickerTheme.borderRadius,
        ),
        child: Column(
          children: [
            Container(
              height: 50,
              color: datePickerTheme.buttonColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CupertinoButton(
                    child: Text(
                      "Done",
                      style: TextStyle(color: datePickerTheme.buttonTextColor),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CupertinoDatePicker(
                mode: CupertinoDatePickerMode.date,
                initialDateTime: selectedDate ?? DateTime.now(),
                minimumDate: DateTime(2000),
                maximumDate: DateTime(2100),
                onDateTimeChanged: (date) {
                  onDateSelected(date);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final datePickerTheme = context.appDatePickerTheme;

    return GestureDetector(
      onTap: () => _showCupertinoDatePicker(context),
      child: Container(
        padding: datePickerTheme.padding,
        decoration: BoxDecoration(
          color: datePickerTheme.backgroundColor,
          borderRadius: datePickerTheme.borderRadius,
        ),
        child: Text(
          selectedDate?.toLocal().toString().split(' ')[0] ?? "Select Date",
          style: TextStyle(color: datePickerTheme.textColor),
        ),
      ),
    );
  }
}

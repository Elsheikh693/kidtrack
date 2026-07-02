import '../../../../index/index.dart';

class AppDateAndroidPicker extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime) onDateSelected;
  final String hint;

  const AppDateAndroidPicker({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
    this.hint = "Select a date",
  });

  @override
  Widget build(BuildContext context) {
    final datePickerTheme = context.appDatePickerTheme;

    return GestureDetector(
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: selectedDate ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: datePickerTheme.selectedDateColor,
                  onPrimary: datePickerTheme.buttonTextColor,
                  onSurface: datePickerTheme.textColor,
                ),
                dialogTheme: DialogThemeData(backgroundColor: datePickerTheme.backgroundColor),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          onDateSelected(date);
        }
      },
      child: Container(
        padding: datePickerTheme.padding,
        decoration: BoxDecoration(
          color: datePickerTheme.backgroundColor,
          borderRadius: datePickerTheme.borderRadius,
          border: Border.all(color: datePickerTheme.borderColor),
        ),
        child: Text(
          selectedDate?.toLocal().toString().split(' ')[0] ?? hint,
          style: TextStyle(color: datePickerTheme.textColor),
        ),
      ),
    );
  }
}

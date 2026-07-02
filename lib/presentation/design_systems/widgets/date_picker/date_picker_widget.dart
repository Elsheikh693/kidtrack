
import '../../../../index/index_main.dart';

class GenericDatePicker extends StatefulWidget {
  final ValueChanged<int> onDateSelected;
  final DateTime? initialDate;

  const GenericDatePicker({
    super.key,
    required this.onDateSelected,
    this.initialDate,
  });

  @override
  State<GenericDatePicker> createState() => _GenericDatePickerState();
}

class _GenericDatePickerState extends State<GenericDatePicker> {
  late int selectedDay;
  late String selectedMonth;
  late int selectedYear;

  static List<String> get _months => [
    'month_jan'.tr, 'month_feb'.tr, 'month_mar'.tr, 'month_apr'.tr, 'month_may'.tr, 'month_jun'.tr,
    'month_jul'.tr, 'month_aug'.tr, 'month_sep'.tr, 'month_oct'.tr, 'month_nov'.tr, 'month_dec'.tr,
  ];
  final List<int> _years = List.generate(80, (index) => 2020 + index);

  @override
  void initState() {
    super.initState();
    final now = widget.initialDate ?? DateTime.now();
    selectedDay = now.day;
    selectedMonth = _months[now.month - 1];
    selectedYear = now.year;
  }

  List<int> get _days {
    int monthIndex = _months.indexOf(selectedMonth) + 1;
    return List.generate(
        _daysInMonth(selectedYear, monthIndex), (index) => index + 1);
  }

  int _daysInMonth(int year, int month) {
    if (month == 2) {
      return _isLeapYear(year) ? 29 : 28;
    } else if ([4, 6, 9, 11].contains(month)) {
      return 30;
    } else {
      return 31;
    }
  }

  bool _isLeapYear(int year) {
    return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0);
  }



  void _notifyDateSelected() {
    final monthIndex = _months.indexOf(selectedMonth) + 1;
    final date = DateTime(selectedYear, monthIndex, selectedDay);
    widget.onDateSelected(date.millisecondsSinceEpoch);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 300,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              color: ColorMappingImpl().borderDisabled.withValues(alpha: 0.7),
              padding: const EdgeInsets.only(top: 10.0, bottom: 10, right: 15),
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () {
                  Get.back();
                },
                child: Text(
                  "تم",
                  style: context.typography.mdBold,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildYearPicker(),
                    _buildMonthPicker(),
                    _buildDayPicker(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildYearPicker() {
    return PickerWidget<int>(
      items: _years,
      selectedItem: selectedYear,
      initialIndex: _years.indexOf(selectedYear),
      onSelectedItemChanged: (value) {
        setState(() {
          selectedYear = value;
          _adjustSelectedDay();
        });
      },
      displayBuilder: (item, isSelected) => PickerContainer(
        text: item.toString(),
        isSelected: isSelected,
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: Border(
          top: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5),
          right: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5),
          bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5),
        ),
      ),
    );
  }

  Widget _buildMonthPicker() {
    return PickerWidget<String>(
      items: _months,
      selectedItem: selectedMonth,
      initialIndex: _months.indexOf(selectedMonth),
      onSelectedItemChanged: (value) {
        setState(() {
          selectedMonth = value;
          _adjustSelectedDay();
        });
      },
      displayBuilder: (item, isSelected) => PickerContainer(
        text: item,
        isSelected: isSelected,
        borderRadius: BorderRadius.zero,
        border: Border.symmetric(
          horizontal: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDayPicker() {
    return PickerWidget<int>(
      items: _days,
      selectedItem: selectedDay,
      initialIndex: _days.indexOf(selectedDay),
      onSelectedItemChanged: (value) {
        setState(() {
          selectedDay = value;
          _notifyDateSelected();
        });
      },
      displayBuilder: (item, isSelected) => PickerContainer(
        text: item.toString(),
        isSelected: isSelected,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          bottomLeft: Radius.circular(12),
        ),
        border: Border(
          top: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5),
          left: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5),
          bottom: BorderSide(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 1.5),
        ),
      ),
    );
  }

  void _adjustSelectedDay() {
    // Adjust the selected day if it exceeds the number of days in the new month/year
    if (selectedDay >
        _daysInMonth(selectedYear, _months.indexOf(selectedMonth) + 1)) {
      selectedDay =
          _daysInMonth(selectedYear, _months.indexOf(selectedMonth) + 1);
    }
    _notifyDateSelected();
  }
}

class PickerWidget<T> extends StatelessWidget {
  final List<T> items;
  final T selectedItem;
  final int initialIndex;
  final ValueChanged<T> onSelectedItemChanged;
  final Widget Function(T, bool) displayBuilder;

  const PickerWidget({
    super.key,
    required this.items,
    required this.selectedItem,
    required this.initialIndex,
    required this.onSelectedItemChanged,
    required this.displayBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListWheelScrollView.useDelegate(
        controller: FixedExtentScrollController(initialItem: initialIndex),
        itemExtent: 35,
        physics: const FixedExtentScrollPhysics(),
        onSelectedItemChanged: (index) {
          onSelectedItemChanged(items[index]);
        },
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final item = items[index];
            final isSelected = selectedItem == item;

            return displayBuilder(item, isSelected);
          },
          childCount: items.length,
        ),
      ),
    );
  }
}

class PickerContainer extends StatelessWidget {
  final String text;
  final bool isSelected;
  final BorderRadius borderRadius;
  final Border border;

  const PickerContainer({
    super.key,
    required this.text,
    required this.isSelected,
    required this.borderRadius,
    required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: isSelected ? border : null,
        borderRadius: borderRadius,
        color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isSelected ? 18 : 15,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected
              ? AppColors.primary
              : Colors.black
                  .withValues(alpha: 0.6), // Faint color for non-selected text
        ),
      ),
    );
  }
}

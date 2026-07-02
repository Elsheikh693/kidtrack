
import '../../../../index/index_main.dart';

class GenericTimePicker extends StatefulWidget {
  final ValueChanged<TimeOfDay> onTimeSelected;
  final TimeOfDay? initialTime;

  const GenericTimePicker({
    super.key,
    required this.onTimeSelected,
    this.initialTime,
  });

  @override
  State<GenericTimePicker> createState() => _GenericTimePickerState();
}

class _GenericTimePickerState extends State<GenericTimePicker> {
  late int selectedHour;
  late int selectedMinute;

  static final List<int> _hours = List.generate(24, (i) => i);
  static final List<int> _minutes = List.generate(60, (i) => i);

  @override
  void initState() {
    super.initState();
    final now = widget.initialTime ?? TimeOfDay.now();
    selectedHour = now.hour;
    selectedMinute = now.minute;
  }

  void _notify() {
    widget.onTimeSelected(TimeOfDay(hour: selectedHour, minute: selectedMinute));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              color: ColorMappingImpl().borderDisabled.withValues(alpha: 0.7),
              padding: const EdgeInsets.only(top: 10.0, bottom: 10, right: 15),
              margin: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: Get.back,
                child: Text('done'.tr, style: context.typography.mdBold),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 60.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildHourPicker(),
                    _Separator(),
                    _buildMinutePicker(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHourPicker() {
    return PickerWidget<int>(
      items: _hours,
      selectedItem: selectedHour,
      initialIndex: selectedHour,
      onSelectedItemChanged: (val) {
        setState(() => selectedHour = val);
        _notify();
      },
      displayBuilder: (item, isSelected) => PickerContainer(
        text: item.toString().padLeft(2, '0'),
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

  Widget _buildMinutePicker() {
    return PickerWidget<int>(
      items: _minutes,
      selectedItem: selectedMinute,
      initialIndex: selectedMinute,
      onSelectedItemChanged: (val) {
        setState(() => selectedMinute = val);
        _notify();
      },
      displayBuilder: (item, isSelected) => PickerContainer(
        text: item.toString().padLeft(2, '0'),
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
}

class _Separator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        ':',
        style: context.typography.lgBold.copyWith(
          color: AppColors.primary,
          fontSize: 24,
        ),
      ),
    );
  }
}

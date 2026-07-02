import '../../../../../index/index_main.dart';
import '../activity_end_controller.dart';

class EndDueDatePicker extends StatelessWidget {
  const EndDueDatePicker({super.key, required this.endCtrl});
  final ActivityEndController endCtrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final date = endCtrl.dueDate.value;
      final label = date != null
          ? '${date.day}/${date.month}/${date.year}'
          : 'teacher_end_hw_due_none'.tr;
      return GestureDetector(
        onTap: () async {
          final picked = await showAppDatePicker(
            context,
            initialDate: date ?? DateTime.now().add(const Duration(days: 1)),
            minimumDate: DateTime.now(),
            maximumDate: DateTime.now().add(const Duration(days: 90)),
          );
          if (picked != null) endCtrl.dueDate.value = picked;
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: date != null
                ? AppColors.activityPurple.withValues(alpha: 0.05)
                : Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: date != null
                  ? AppColors.activityPurple.withValues(alpha: 0.3)
                  : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 16,
                color: date != null
                    ? AppColors.activityPurple
                    : Colors.grey.shade400,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${'teacher_end_hw_due'.tr}: $label',
                  style: context.typography.xsMedium.copyWith(
                    color: date != null
                        ? AppColors.activityPurple
                        : Colors.grey.shade500,
                  ),
                ),
              ),
              if (date != null)
                GestureDetector(
                  onTap: () => endCtrl.dueDate.value = null,
                  child: Icon(Icons.close_rounded,
                      size: 16, color: Colors.grey.shade400),
                ),
            ],
          ),
        ),
      );
    });
  }
}

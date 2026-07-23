import '../../../../../index/index_main.dart';

/// Selectable school-day chips. Stores Dart weekday ints (Mon=1 … Sun=7);
/// displayed in the local week order starting Saturday.
class ProfileWorkingDaysEditor extends StatelessWidget {
  const ProfileWorkingDaysEditor({super.key, required this.controller});
  final ManagerNurseryProfileController controller;

  static const _days = <int, String>{
    6: 'managerpro18_day_saturday',
    7: 'managerpro18_day_sunday',
    1: 'managerpro18_day_monday',
    2: 'managerpro18_day_tuesday',
    3: 'managerpro18_day_wednesday',
    4: 'managerpro18_day_thursday',
    5: 'managerpro18_day_friday',
  };

  @override
  Widget build(BuildContext context) {
    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _days.entries.map((e) {
            final selected = controller.workingDays.contains(e.key);
            return GestureDetector(
              onTap: () => controller.toggleWorkingDay(e.key),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.backgroundNeutral100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary.withValues(alpha: 0.5)
                        : AppColors.borderNeutralPrimary.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      selected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: 16,
                      color:
                          selected ? AppColors.primary : AppColors.grayMedium,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      e.value.tr,
                      style: context.typography.smMedium.copyWith(
                        color: selected
                            ? AppColors.primary
                            : AppColors.textPrimaryParagraph,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ));
  }
}

import '../../../../../index/index_main.dart';

/// Selectable school-day chips. Stores Dart weekday ints (Mon=1 … Sun=7);
/// displayed in the local week order starting Saturday.
class ProfileWorkingDaysEditor extends StatelessWidget {
  const ProfileWorkingDaysEditor({super.key, required this.controller});
  final ManagerNurseryProfileController controller;

  static const _days = <int, String>{
    6: 'السبت',
    7: 'الأحد',
    1: 'الاثنين',
    2: 'الثلاثاء',
    3: 'الأربعاء',
    4: 'الخميس',
    5: 'الجمعة',
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
                      e.value,
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

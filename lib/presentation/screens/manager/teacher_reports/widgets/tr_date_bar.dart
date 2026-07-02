import '../../../../../index/index_main.dart';
import '../models/teacher_report_models.dart';
import 'tr_format.dart';

/// Anchor-day picker + range selector (اليوم / آخر ٧ أيام / آخر ٣٠ يوم).
class TrDateBar extends StatelessWidget {
  const TrDateBar({super.key, required this.controller, required this.accent});

  final ManagerTeacherReportsController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Obx(
          () => InkWell(
            onTap: controller.pickDate,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE8EBF0)),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 18.sp, color: accent),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      controller.isToday
                          ? '${'tr_today'.tr} · ${trDayLabel(controller.anchorDate.value)}'
                          : trDayLabel(controller.anchorDate.value),
                      style: context.typography.displaySmBold.copyWith(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDefault,
                      ),
                    ),
                  ),
                  Icon(Icons.keyboard_arrow_down_rounded,
                      size: 22.sp, color: AppColors.textSecondaryParagraph),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 12.h),
        Obx(
          () => Row(
            children: [
              for (final r in TrRange.values) ...[
                Expanded(child: _chip(r)),
                if (r != TrRange.values.last) SizedBox(width: 8.w),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _chip(TrRange range) {
    final selected = controller.selectedRange.value == range;
    return GestureDetector(
      onTap: () => controller.setRange(range),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 11.h),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? accent : Colors.white,
          borderRadius: BorderRadius.circular(13.r),
          border: Border.all(
            color: selected ? accent : const Color(0xFFE8EBF0),
          ),
        ),
        child: Text(
          range.labelKey.tr,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: selected ? Colors.white : AppColors.textSecondaryParagraph,
          ),
        ),
      ),
    );
  }
}

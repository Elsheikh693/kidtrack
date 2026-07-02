import '../../../../../index/index_main.dart';

// Shift palette (matches the approved mock).
const _morning = Color(0xFFF59E0B);
const _morningBg = Color(0xFFFEF6E7);
const _between = Color(0xFF14B8A6);
const _betweenBg = Color(0xFFE6FAF7);
const _evening = Color(0xFF6366F1);
const _eveningBg = Color(0xFFEEF0FE);
const _line = Color(0xFFEEF0F4);
const _ink = Color(0xFF111827);
const _muted = Color(0xFF8A93A4);

class ShiftSwitcher extends StatelessWidget {
  final ChildListController controller;
  const ShiftSwitcher({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: _ShiftCard(
                value: 'morning',
                label: 'shift_morning'.tr,
                count: controller.morningCount,
                icon: Icons.wb_sunny_rounded,
                color: _morning,
                bg: _morningBg,
                selected: controller.selectedShift.value == 'morning',
                onTap: () => _toggle('morning'),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _ShiftCard(
                value: 'between',
                label: 'shift_between'.tr,
                count: controller.betweenCount,
                icon: Icons.brightness_6_rounded,
                color: _between,
                bg: _betweenBg,
                selected: controller.selectedShift.value == 'between',
                onTap: () => _toggle('between'),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: _ShiftCard(
                value: 'evening',
                label: 'shift_evening'.tr,
                count: controller.eveningCount,
                icon: Icons.bedtime_rounded,
                color: _evening,
                bg: _eveningBg,
                selected: controller.selectedShift.value == 'evening',
                onTap: () => _toggle('evening'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggle(String shift) {
    controller.setShift(
      controller.selectedShift.value == shift ? null : shift,
    );
  }
}

class _ShiftCard extends StatelessWidget {
  final String value;
  final String label;
  final int count;
  final IconData icon;
  final Color color;
  final Color bg;
  final bool selected;
  final VoidCallback onTap;

  const _ShiftCard({
    required this.value,
    required this.label,
    required this.count,
    required this.icon,
    required this.color,
    required this.bg,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.fromLTRB(12.w, 13.h, 12.w, 13.h),
        decoration: BoxDecoration(
          color: selected ? bg : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: selected ? color : _line,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  '$count',
                  style: context.typography.xsBold.copyWith(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: _ink,
                  ),
                ),
                const Spacer(),
                Container(
                  width: 34.w,
                  height: 34.h,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Icon(icon, color: color, size: 19.sp),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: context.typography.displaySmBold.copyWith(
                fontSize: 13,
                color: selected ? _ink : _muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
